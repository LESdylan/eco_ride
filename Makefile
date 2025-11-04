PORT ?= 3307

# Color codes
GREEN  = \033[0;32m
YELLOW = \033[1;33m
RED    = \033[0;31m
BLUE   = \033[0;34m
NC     = \033[0m

# Logging functions
define info
	@echo "$(BLUE)[INFO]$(NC) $(1)"
endef

define success
	@echo "$(GREEN)[SUCCESS]$(NC) $(1)"
endef

define warn
	@echo "$(YELLOW)[WARN]$(NC) $(1)"
endef

define error
	@echo "$(RED)[ERROR]$(NC) $(1)"
endef

up:
	$(call info,Starting Docker containers...)
	@sudo docker compose up -d

down:
	$(call warn,Stopping and removing containers...)
	@sudo docker compose down

logs:
	$(call info,Showing logs for db service...)
	@sudo docker compose logs db

ps:
	$(call info,Listing running containers...)
	@sudo docker compose ps

re:
	$(call warn,Resetting database and containers...)
	@sudo docker compose down -v
	@sudo docker compose up -d

run_db:
	$(call info,Connect mysql running in the docker container via port $(PORT))
	@mysql -h localhost -P $(PORT) -u root -p

seed:
	$(call info,Seeding the database with fake data using Docker Compose...)
	@sudo docker compose run --rm \
		-e MYSQL_HOST=db -e MYSQL_PORT=3306 \
		-e SEED_USERS -e SEED_BRANDS -e SEED_CARS -e SEED_CARPOOLS -e SEED_REVIEWS -e PARTICIPANTS_MAX -e SEED_CHUNK_SIZE \
		seeder

clean:
	$(call warn,Removing stopped containers, dangling images, and unused volumes...)
	@sudo docker compose down
	@sudo docker system prune -f
	@sudo docker volume prune -f

fclean:
	@echo "$(RED)[FCLEAN]$(NC) Removing all containers, images, and persistent volumes for this project..."
	@sudo docker compose down -v --remove-orphans
	@sudo docker system prune -a -f
	@sudo docker volume rm -f eco_ride_db_data || true

deps:
	$(call info,Dependencies are handled by Docker. No manual installation needed.)

.PHONY: seed run_db re ps logs down up