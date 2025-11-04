import mysql.connector
from faker import Faker
import random
from datetime import datetime, timedelta
from dotenv import load_dotenv
import os
import sys
import string
import time

# Load environment variables
load_dotenv()
DEBUG = os.getenv("SEED_DEBUG", "0") == "1"

if DEBUG:
    print("DB ENV:", {
        "host": os.getenv("MYSQL_HOST", "localhost"),
        "port": os.getenv("MYSQL_PORT", "3307"),
        "user": os.getenv("MYSQL_USER", "dylan"),
        "database": os.getenv("MYSQL_DATABASE", "codrive")
    })

# DB connection info
DB_CONFIG = {
    "host": os.getenv("MYSQL_HOST", "localhost"),
    "port": int(os.getenv("MYSQL_PORT", "3307")),
    "user": os.getenv("MYSQL_USER", "dylan"),
    "password": os.getenv("MYSQL_PASSWORD", "dylan123"),
    "database": os.getenv("MYSQL_DATABASE", "codrive")
}

fake = Faker()

# Helpers
def get_int_env(key, default):
    try:
        return int(os.getenv(key, default))
    except (TypeError, ValueError):
        return default

CHUNK_SIZE = get_int_env("SEED_CHUNK_SIZE", 1000)

def chunked(iterable, size):
    for i in range(0, len(iterable), size):
        yield iterable[i:i+size]

def connect_with_retry(cfg, retries=30, delay=2):
    last_err = None
    for i in range(retries):
        try:
            conn = mysql.connector.connect(**cfg)
            if DEBUG:
                print(f"DB connected on try {i+1}")
            return conn
        except Exception as e:
            last_err = e
            if DEBUG:
                print(f"DB connect failed (try {i+1}/{retries}): {e}")
            time.sleep(delay)
    raise last_err

# --- Database Connection ---
try:
    conn = connect_with_retry(DB_CONFIG)
    conn.autocommit = False
    cursor = conn.cursor()
except Exception as e:
    print("❌ Could not connect to database:", e)
    sys.exit(1)

print("✅ Connected to database")

# --- Helper to clear tables (optional if you re-run) ---
def clear_tables():
    try:
        cursor.execute("SET FOREIGN_KEY_CHECKS = 0;")
        for table in ["has_param", "participates", "uses", "manages", "owns", "submits",
                      "review", "carpool", "car", "brand", "configuration", "parameter",
                      "role", "user"]:
            cursor.execute(f"TRUNCATE TABLE `{table}`;")
        cursor.execute("SET FOREIGN_KEY_CHECKS = 1;")
        conn.commit()
        print("🧹 All tables cleared!")
    except Exception as e:
        print("❌ Error clearing tables:", e)

# --- Data generation functions ---
def create_roles():
    roles = ["Driver", "Passenger", "Admin"]
    for label in roles:
        try:
            cursor.execute("INSERT INTO `role` (`label`) VALUES (%s)", (label,))
        except Exception as e:
            print(f"❌ Error inserting role {label}:", e)
    conn.commit()
    print(f"✅ Inserted {len(roles)} roles")

def create_users(n=100):
    users = []
    for _ in range(n):
        first = fake.first_name()
        last = fake.last_name()
        email = fake.email()
        username = f"{first.lower()}{random.randint(1,999)}"
        users.append((
            last,
            first,
            email,
            fake.password(length=10),
            fake.phone_number(),
            fake.address().replace("\n", " "),
            fake.date_of_birth(minimum_age=18, maximum_age=70).isoformat(),
            username
        ))
    for batch in chunked(users, CHUNK_SIZE):
        cursor.executemany("""
            INSERT INTO `user` (`last_name`, `first_name`, `email`, `password`, `phone`, `address`, `birth_date`, `username`)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s)
        """, batch)
    conn.commit()
    cursor.execute("SELECT `user_id` FROM `user`")
    user_ids = [row[0] for row in cursor.fetchall()]
    print(f"✅ Inserted {len(user_ids)} users")
    return user_ids

def assign_roles(user_ids):
    rows = []
    for uid in user_ids:
        roles = random.sample([1, 2, 3], k=random.randint(1, 2))
        for rid in roles:
            rows.append((uid, rid))
    for batch in chunked(rows, CHUNK_SIZE):
        cursor.executemany("INSERT INTO `owns` (`user_id`, `role_id`) VALUES (%s, %s)", batch)
    conn.commit()
    print("✅ Roles assigned to users")

def create_brands(n=200):
    base = ["Toyota", "Ford", "BMW", "Renault", "Tesla", "Peugeot", "Honda", "Citroen"]
    labels = set(base)
    while len(labels) < n:
        labels.add(f"{fake.company()} {random.randint(100,999)}")
    data = [(label,) for label in list(labels)[:n]]
    for batch in chunked(data, CHUNK_SIZE):
        cursor.executemany("INSERT INTO `brand` (`label`) VALUES (%s)", batch)
    conn.commit()
    cursor.execute("SELECT `brand_id` FROM `brand`")
    brand_ids = [row[0] for row in cursor.fetchall()]
    print(f"✅ Inserted {len(brand_ids)} brands")
    return brand_ids

def rand_plate():
    letters = ''.join(random.choices(string.ascii_uppercase, k=2))
    letters2 = ''.join(random.choices(string.ascii_uppercase, k=2))
    return f"{letters}-{random.randint(100,999)}-{letters2}"

def create_cars(brand_ids, n=500):
    cars = []
    energies = ["Diesel", "Gasoline", "Electric", "Hybrid"]
    for _ in range(n):
        cars.append((
            fake.word().capitalize(),
            rand_plate(),
            random.choice(energies),
            fake.color_name(),
            fake.date_between(start_date='-10y', end_date='today').isoformat(),
            random.choice(brand_ids)
        ))
    for batch in chunked(cars, CHUNK_SIZE):
        cursor.executemany("""
            INSERT INTO `car` (`model`, `license_plate`, `energy`, `color`, `first_registration_date`, `brand_id`)
            VALUES (%s,%s,%s,%s,%s,%s)
        """, batch)
    conn.commit()
    cursor.execute("SELECT `car_id` FROM `car`")
    car_ids = [row[0] for row in cursor.fetchall()]
    print(f"✅ Inserted {len(car_ids)} cars")
    return car_ids

def link_manages(user_ids, car_ids):
    links = [(random.choice(user_ids), cid) for cid in car_ids]
    for batch in chunked(links, CHUNK_SIZE):
        cursor.executemany("INSERT INTO `manages` (`user_id`, `car_id`) VALUES (%s,%s)", batch)
    conn.commit()
    print("✅ Linked users to cars (manages)")

def create_carpools(car_ids, n=1000):
    carpools = []
    for _ in range(n):
        departure = fake.future_datetime(end_date='+30d')
        arrival = departure + timedelta(hours=random.randint(1,6))
        carpools.append((
            departure.date(),
            departure.time(),
            fake.city(),
            arrival.date(),
            arrival.time(),
            fake.city(),
            random.choice(["open", "closed", "cancelled"]),
            random.randint(1,6),
            round(random.uniform(5.0, 50.0), 2)
        ))
    for batch in chunked(carpools, CHUNK_SIZE):
        cursor.executemany("""
            INSERT INTO `carpool` (`departure_date`, `departure_time`, `departure_place`,
                                   `arrival_date`, `arrival_time`, `arrival_place`,
                                   `status`, `seats_available`, `price_per_person`)
            VALUES (%s,%s,%s,%s,%s,%s,%s,%s,%s)
        """, batch)
    conn.commit()
    cursor.execute("SELECT `carpool_id` FROM `carpool`")
    carpool_ids = [row[0] for row in cursor.fetchall()]
    print(f"✅ Inserted {len(carpool_ids)} carpools")
    return carpool_ids

def link_uses(carpool_ids, car_ids):
    rows = [(cpid, random.choice(car_ids)) for cpid in carpool_ids]
    for batch in chunked(rows, CHUNK_SIZE):
        cursor.executemany("INSERT INTO `uses` (`carpool_id`, `car_id`) VALUES (%s,%s)", batch)
    conn.commit()
    print("✅ Linked cars to carpools (uses)")

def link_participates(user_ids, carpool_ids, max_per_carpool=5):
    rows = []
    for cp_id in carpool_ids:
        participants = random.sample(user_ids, k=random.randint(1, max_per_carpool))
        rows.extend([(uid, cp_id) for uid in participants])
    for batch in chunked(rows, CHUNK_SIZE):
        cursor.executemany("INSERT IGNORE INTO `participates` (`user_id`, `carpool_id`) VALUES (%s,%s)", batch)
    conn.commit()
    print("✅ Linked users to carpools (participates)")

def create_reviews(user_ids, n=1000):
    reviews = []
    for _ in range(n):
        reviews.append((
            fake.sentence(),
            random.choice(["1", "2", "3", "4", "5"]),
            random.choice(["published", "pending", "hidden"])
        ))
    for batch in chunked(reviews, CHUNK_SIZE):
        cursor.executemany("INSERT INTO `review` (`comment`, `rating`, `status`) VALUES (%s,%s,%s)", batch)
    conn.commit()
    cursor.execute("SELECT `review_id` FROM `review`")
    review_ids = [row[0] for row in cursor.fetchall()]

    submits = [(random.choice(user_ids), rid) for rid in review_ids]
    for batch in chunked(submits, CHUNK_SIZE):
        cursor.executemany("INSERT INTO `submits` (`user_id`, `review_id`) VALUES (%s,%s)", batch)
    conn.commit()
    print(f"✅ Inserted {len(review_ids)} reviews and linked them to users")

def create_config_params():
    cursor.execute("INSERT INTO `configuration` VALUES ()")
    config_id = cursor.lastrowid
    parameters = [
        ("theme", random.choice(["light", "dark"])),
        ("language", random.choice(["en", "fr", "es"])),
        ("currency", random.choice(["EUR", "USD", "GBP"])),
        ("notifications", random.choice(["on", "off"]))
    ]
    param_ids = []
    for prop, val in parameters:
        cursor.execute("INSERT INTO `parameter` (`property`, `value`) VALUES (%s,%s)", (prop, val))
        param_ids.append(cursor.lastrowid)
    for pid in param_ids:
        cursor.execute("INSERT INTO `has_param` (`config_id`, `parameter_id`) VALUES (%s,%s)", (config_id, pid))
    conn.commit()
    print("✅ Configuration and parameters added")

# --- RUN EVERYTHING ---
if __name__ == "__main__":
    USERS_N = get_int_env("SEED_USERS", 1000)
    BRANDS_N = get_int_env("SEED_BRANDS", 200)
    CARS_N = get_int_env("SEED_CARS", 500)
    CARPOOLS_N = get_int_env("SEED_CARPOOLS", 1000)
    REVIEWS_N = get_int_env("SEED_REVIEWS", 1000)
    PARTICIPANTS_MAX = get_int_env("PARTICIPANTS_MAX", 5)

    clear_tables()
    create_roles()
    users = create_users(USERS_N)
    assign_roles(users)
    brands = create_brands(BRANDS_N)
    cars = create_cars(brands, CARS_N)
    link_manages(users, cars)
    carpools = create_carpools(cars, CARPOOLS_N)
    link_uses(carpools, cars)
    link_participates(users, carpools, PARTICIPANTS_MAX)
    create_reviews(users, REVIEWS_N)
    create_config_params()

    print("🎉 Database seeding completed successfully!")
    cursor.close()
    conn.close()
