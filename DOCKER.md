# Docker Setup for Ohloh UI

## Quick Start (Development)

```bash
# Using Makefile (recommended - handles cleanup automatically)
make up-build    # First time: build and start all services
make up          # Subsequent runs (no rebuild)

# Or using docker-compose directly
docker-compose -f docker-compose.dev.yml up --build

# Access the app at: http://localhost:3000
```

The first run automatically:
- Creates the database
- Loads the schema from `db/structure.sql`
- Starts all services

## Subsequent Runs

```bash
# Just start (no rebuild needed, database persists)
make up

# Or in background
make up-d
```

You should see "Database ready, starting application..." on subsequent runs.

## Makefile Commands

The Makefile provides shortcuts with automatic cleanup of stuck processes:

| Command | Description |
|---------|-------------|
| `make up-build` | Clean, build, and start (recommended for first run) |
| `make up` | Start services (no rebuild) |
| `make up-d` | Start in background |
| `make down` | Stop services |
| `make restart` | Stop and start |
| `make build` | Build images only |
| `make clean` | Full cleanup (removes volumes/data) |
| `make logs` | Follow all logs |
| `make logs-web` | Follow web logs only |
| `make shell` | Bash shell in web container |
| `make console` | Rails console |
| `make test` | Run tests |

## Services and Ports

| Service  | Port | Description           |
|----------|------|-----------------------|
| web      | 3000 | Rails application     |
| postgres | 5432 | PostgreSQL database   |
| redis    | 6379 | Redis (cache/sidekiq) |

## Useful Commands

```bash
# View logs (or: make logs-web)
docker-compose -f docker-compose.dev.yml logs -f web

# Rails console (or: make console)
docker-compose -f docker-compose.dev.yml exec web bundle exec rails c

# Run tests (or: make test)
docker-compose -f docker-compose.dev.yml exec web bundle exec rake test

# Stop services (or: make down)
docker-compose -f docker-compose.dev.yml down

# Stop and reset database (or: make clean)
docker-compose -f docker-compose.dev.yml down -v
```

## Reset Database

To start fresh (removes all data):

```bash
docker-compose -f docker-compose.dev.yml down -v
docker-compose -f docker-compose.dev.yml up --build
```

## Production Build

```bash
# Build production image
docker build -f Dockerfile.prod -t ohloh-ui:latest .

# Run production container
docker run -d \
  -p 3000:3000 \
  -e RAILS_ENV=production \
  -e SECRET_KEY_BASE=your_secret_key \
  -e DB_HOST=your_db_host \
  -e DB_NAME=your_db_name \
  -e DB_USERNAME=your_db_user \
  -e DB_PASSWORD=your_db_password \
  -e REDIS_HOST=your_redis_host \
  ohloh-ui:latest
```

## Troubleshooting

### Build seems stuck at "Building web"

**First, check for stuck processes** (most common cause):
```bash
# Kill any stuck docker build processes
make clean-builds

# Or manually:
pkill -f "docker build.*ohloh-ui"
pkill -f "docker-compose.*ohloh-ui.*build"
```

If no stuck processes, the initial build can take 15-20+ minutes due to gem installation. To see detailed progress:

```bash
# Build with verbose output
docker-compose -f docker-compose.dev.yml build --progress=plain web
```

Common slow steps:
- `bundle install` - compiles native extensions (nokogiri, pg, imagemagick)
- Package downloads from rubygems.org

If builds are consistently slow:
1. **Increase Docker resources** - Docker Desktop → Settings → Resources → increase CPU/RAM
2. **Check network** - slow gem downloads can cause timeouts
3. **Note**: BuildKit is disabled by default (in `.env`) because it causes hangs with docker-compose v1

### Database connection errors

If you see "connection refused" errors:
- Ensure the `db` service is healthy: `docker-compose -f docker-compose.dev.yml ps`
- Check postgres logs: `docker-compose -f docker-compose.dev.yml logs db`
- Try restarting: `docker-compose -f docker-compose.dev.yml restart db`

### Port already in use

If port 3000, 5432, or 6379 is already in use:
```bash
# Find what's using the port
lsof -i :3000

# Or change the port in docker-compose.dev.yml (e.g., "3001:3000")
```

## Environment Variables

The docker-compose.dev.yml sets defaults for local development. For production, configure:
- `DB_HOST`, `DB_NAME`, `DB_USERNAME`, `DB_PASSWORD` - PostgreSQL connection
- `REDIS_HOST`, `REDIS_PORT` - Redis connection
- `SECRET_KEY_BASE` - Rails secret (required for production)
