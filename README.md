# Eco Ride Setup

## Before starting
we need to create the .env file with those variables for compatibility

# This file is for credentials it's a hidden file that should never be shared in github
MYSQL_ROOT_PASSWORD=
MYSQL_DATABASE=
MYSQL_USER=
MYSQL_PASSWORD=
MYSQL_HOST=
MYSQL_PORT=

## 1. Install dependencies

No manual installation needed. Dependencies are handled by Docker.

## 2. Start MySQL with Docker

```bash
make up,m
```

## 3. Seed the database (using Docker)

```bash
make seed
```

## 4. Connect to MySQL

```bash
make run_db
```

## 5. Stop containers

```bash
make down
```

## Generate large datasets

Use env vars to control volumes (forwarded to the seeder container):

```bash
SEED_USERS=5000 SEED_BRANDS=300 SEED_CARS=2000 SEED_CARPOOLS=5000 SEED_REVIEWS=5000 make seed
```

Tune batch size if needed:

```bash
SEED_CHUNK_SIZE=2000 make seed
```

Notes:

- Seeding runs inside the Compose network and waits for MySQL to be healthy.
