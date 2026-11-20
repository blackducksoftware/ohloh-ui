.PHONY: build up down restart clean logs shell console test

# Disable BuildKit - causes hangs with docker-compose v1
export DOCKER_BUILDKIT=0

# Development commands
build: clean-builds
	docker-compose -f docker-compose.dev.yml build

up:
	docker-compose -f docker-compose.dev.yml up

up-build: clean-builds
	docker-compose -f docker-compose.dev.yml up --build

up-d:
	docker-compose -f docker-compose.dev.yml up -d

down:
	docker-compose -f docker-compose.dev.yml down

restart: down up

# Clean up stuck build processes before building
clean-builds:
	@echo "Cleaning up any stuck docker build processes..."
	@pkill -f "docker build.*ohloh-ui" 2>/dev/null || true
	@pkill -f "docker-compose.*ohloh-ui.*build" 2>/dev/null || true
	@docker builder prune -f 2>/dev/null || true

# Full cleanup (removes volumes too)
clean: down
	docker-compose -f docker-compose.dev.yml down -v --remove-orphans
	docker system prune -f

# Logs
logs:
	docker-compose -f docker-compose.dev.yml logs -f

logs-web:
	docker-compose -f docker-compose.dev.yml logs -f web

# Shell access
shell:
	docker-compose -f docker-compose.dev.yml exec web bash

console:
	docker-compose -f docker-compose.dev.yml exec web bundle exec rails c

# Tests
test:
	docker-compose -f docker-compose.dev.yml exec web bundle exec rake test
