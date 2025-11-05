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

# add path to dependency check script
DEPS_SCRIPT := ./check_deps.sh

# run dependency checks before Docker actions (skip on error)
check_deps:
	@bash $(DEPS_SCRIPT) || true

# Or create a simpler docker-only check
check_docker:
	@command -v docker >/dev/null 2>&1 || { echo "Docker not found. Please install Docker."; exit 1; }
	@command -v docker-compose >/dev/null 2>&1 || docker compose version >/dev/null 2>&1 || { echo "Docker Compose not found."; exit 1; }

# Use simpler check for docker operations
up: check_docker
	$(call info,Starting Docker containers...)
	@sudo docker compose up -d

down: check_docker
	$(call warn,Stopping and removing containers...)
	@sudo docker compose down

logs: check_deps
	$(call info,Showing logs for db service...)
	@sudo docker compose logs db

ps: check_deps
	$(call info,Listing running containers...)
	@sudo docker compose ps

re:
	$(call warn,Resetting database and containers...)
	-@sudo docker compose down -v 2>/dev/null || true
	@bash $(DEPS_SCRIPT) --start

run_db:
	$(call info,Connect mysql running in the docker container via port $(PORT))
	@mysql -h localhost -P $(PORT) -u root -p

seed: check_deps
	$(call info,Seeding the database with fake data using Docker Compose...)
	@sudo docker compose run --rm \
		-e MYSQL_HOST=db -e MYSQL_PORT=3306 \
		-e SEED_USERS -e SEED_BRANDS -e SEED_CARS -e SEED_CARPOOLS -e SEED_REVIEWS -e PARTICIPANTS_MAX -e SEED_CHUNK_SIZE \
		seeder

clean: check_deps
	$(call warn,Removing stopped containers, dangling images, and unused volumes...)
	@sudo docker compose down
	@sudo docker system prune -f
	@sudo docker volume prune -f

fclean: check_deps
	@echo "$(RED)[FCLEAN]$(NC) Removing all containers, images, and persistent volumes for this project..."
	@sudo docker compose down -v --remove-orphans
	@sudo docker system prune -a -f
	@sudo docker volume rm -f eco_ride_db_data || true

deps:
	$(call info,Running dependency checks...)
	@bash $(DEPS_SCRIPT)

.PHONY: check_deps seed run_db re ps logs down up deps