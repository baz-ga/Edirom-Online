
# Quick Reference

## Build Commands

### Build Individual Services
```bash
# Set source paths (absolute paths recommended)
export FE_LOCAL_SOURCE=/path/to/frontend
export BE_LOCAL_SOURCE=/path/to/backend

# Build frontend only
docker compose --profile local-frontend build local-edirom-online-frontend

# Build backend only  
docker compose --profile local-backend build local-edirom-online-backend

# Build both together (automatic dependency resolution)
docker compose --profile local-frontend --profile local-backend build
```

## Run Complete Local Development Stack
```bash
# Build and start both frontend and backend with local source
docker compose --profile local-frontend --profile local-backend up
```

## Service Management

### Stopping Services

> [!IMPORTANT]
> **Always use the same profile for `down` as you used for `up`**
>
> Docker Compose requires the profile to be specified when stopping services. Running `docker compose down` without the `--profile` flag will not properly stop services that were started with a profile.

**Stop services for each profile:**

```bash
# Stop default profile services
docker compose --profile default down

# Stop local frontend development
docker compose --profile local-frontend down

# Stop local backend development
docker compose --profile local-backend down

# Stop both local profiles
docker compose --profile local-frontend --profile local-backend down

# Stop and remove volumes (clean slate)
docker compose --profile default down --volumes --remove-orphans
```

### Other Service Commands

```bash
# Stop without removing containers (can restart quickly)
docker compose stop local-edirom-online-frontend local-edirom-online-backend

# Restart a specific service
docker compose restart local-edirom-online-frontend

# View logs for specific service
docker compose logs -f local-edirom-online-frontend

# View logs for all services in a profile
docker compose --profile default logs -f
```

## Troubleshooting Deployment

- **Wildcard issues**: Using `*` in filenames may select multiple XARs if you have multiple versions built - use `ls build-xar/` to check
- **No changes visible**: Check if package version in `expath-pkg.xml` was updated
- **Version conflicts**: eXist-db may not install the new package if the version number is the same as the one currently installed
- **Dashboard limitations**: Method B requires manual uninstall/reinstall if the package version hasn’t changed
- **XQuery method advantage**: Method A (XQuery) can handle same-version updates better than Dashboard
- **Installation vs Upload**: REST API only uploads the file - you must use one of the methods above to install it
- **XQuery errors**: Check eXist-db logs if the XQuery installation command fails



<!-- TODO maybe split file here -->
---
## Development Workflow Recommendations

**For Frontend Development:**
- Use the interactive builder for immediate live updates
- Run `sencha app build testing && ant inject-properties` for safe incremental builds
- Avoid `./build.sh` in live development as it cleans the mounted build directory
- Container rebuild only needed for clean state testing or caching issues

**For Backend Development:**
- Use Option 2 (REST API upload + XQuery deploy) for the quickest iterations - can be run entirely from the builder
- Use Option 1 (copy to autodeploy + restart) when the REST API is not available
- Use Option 3 (container rebuild) for clean state testing
- Consider Option 4 (shared volume) if making frequent backend changes and don’t mind restarts

**Live Development Tips:**
```bash
# Watch eXist-db logs for deployment status
docker compose logs -f local-edirom-online-backend

# Check deployed applications via eXist-db dashboard
# Navigate to http://localhost:8080/exist/apps/dashboard

# Quick frontend development cycle
docker compose exec interactive-edirom-online-builder bash
cd /opt/eo-frontend
# make changes to source files
sencha app build testing && ant inject-properties
# refresh browser to see changes

# Quick backend development cycle
docker compose exec interactive-edirom-online-builder bash
cd /opt/eo-backend

# make changes to source files
ant
docker cp interactive-edirom-online-builder:/opt/eo-backend/build-xar/[xar-file].xar local-eXist-db:/opt/exist/autodeploy/
```

<!-- TODO: maybe put to a separate file -->

## Speeding up the Build Process

Docker Compose builds can be time-consuming, especially when working with profiles. Here are strategies to optimize your build times:

### Avoid Building Inactive Profiles

When using `--build` flag with `docker compose up`, Docker Compose may attempt to build images for services in inactive profiles. To build only what you need:

**Option 1: Build explicitly before starting**
```bash
# Build only the services for the active profile
docker compose --profile default build

# Then start without rebuilding
docker compose --profile default up
```

**Option 2: Use `--no-build` flag**
```bash
# Start services without rebuilding (uses existing images)
docker compose --profile default up --no-build
```

### Leverage Docker Build Cache

Docker uses layer caching to speed up builds. To maximize cache usage:

1. **Don't use `--no-cache` unless necessary**
   ```bash
   # This rebuilds everything from scratch (slow)
   docker compose build --no-cache

   # This uses cached layers when possible (faster)
   docker compose build
   ```

2. **Only rebuild changed services**
   ```bash
   # Rebuild just the frontend
   docker compose --profile default build edirom-online-frontend

   # Rebuild just the backend
   docker compose --profile default build edirom-online-backend
   ```

### Use the Shared Builder Efficiently

The shared builder image (`edirom-online-builder:latest`) only needs to be built once:

```bash
# Check if builder exists
docker image inspect edirom-online-builder:latest

# Only rebuild if needed (e.g., after builder configuration changes)
docker compose build edirom-online-builder
```

### Parallel Builds

Docker Compose builds services in parallel by default. Ensure you have sufficient system resources:

- **CPU**: More cores = faster parallel builds
- **Memory**: Ensure Docker Desktop has adequate memory allocation
- **Disk**: SSD significantly faster than HDD

### Profile-Specific Build Tips

**For local development:**
```bash
# First time: build everything needed
docker compose --profile local-frontend build

# Subsequent builds: only rebuild what changed
docker compose --profile local-frontend build local-edirom-online-frontend
```

**For testing multiple profiles:**
```bash
# Build all profiles at once (if you'll use them)
docker compose --profile default --profile local-frontend --profile local-backend build

# Then switch between profiles without rebuilding
docker compose --profile default up
docker compose --profile local-frontend up
```

### Troubleshooting Slow Builds

If builds are unexpectedly slow:

1. **Check Docker Desktop resources**
   - Increase CPUs and memory allocation in Docker Desktop settings

2. **Prune build cache periodically**
   ```bash
   # Remove unused build cache
   docker builder prune
   ```

3. **Monitor build progress**
   ```bash
   # See detailed build output
   docker compose build --progress=plain
   ```

4. **Use BuildKit** (should be enabled by default)
   ```bash
   # Verify BuildKit is enabled
   docker buildx version
   ```

## Environment Variables

### Local Development Variables

- `FE_LOCAL_SOURCE`: Path to local frontend source code (required for `local-frontend` profile)
- `BE_LOCAL_SOURCE`: Path to local backend source code (required for `local-backend` profile)
- `FE_REPO`: Frontend repository URL (default: official Edirom-Online-Frontend repo)
- `FE_BRANCH`: Frontend branch to use (default: `develop`)
- `FE_PORT`: Port to expose frontend on (default: `8089`)

### Backend Development Variables

- `BE_REPO`: Backend repository URL (default: official Edirom-Online-Backend repo)
- `BE_BRANCH`: Backend branch to use (default: `v1.0.1`)
- `BE_PORT`: Port to expose backend on (default: `8080`)

### Edition Variables

- `EDITION_XAR`: URL to downloadable XAR package for edition data
- `FE_XAR`: Frontend XAR package
- `BE_XAR`: Backend XAR package


// delete candidate
# Troubleshooting

## Build Failures: BuildKit Not Available

The builder image uses `RUN --mount=type=cache` (a BuildKit feature). If builds fail with errors about unsupported Dockerfile syntax, you may be running an outdated Docker version.

BuildKit is enabled by default in Docker Compose v2+ (released April 2022). The `docker compose` command (without hyphen) already requires v2+, so this should not affect most users.

**Check your version:**
```bash
docker compose version
```

**Verify BuildKit is available:**
```bash
docker buildx version
```

If either command fails or returns v1.x, upgrade Docker Desktop.

## Volume Mount Issues

If you encounter permission issues with volume mounts:

1. Ensure the `FE_LOCAL_SOURCE` and/or `BE_LOCAL_SOURCE` directories exist and are readable
2. Check Docker Desktop file sharing settings (macOS/Windows)
3. Verify the build directory exists: `${FE_LOCAL_SOURCE}/build` (for frontend development)

## Profile Not Working

Make sure you’re using the correct syntax:

```bash
# Correct
docker compose --profile local-frontend up
docker compose --profile local-backend up

# Incorrect (missing --profile flag)
docker compose local-frontend up
```

## Environment Variables Not Applied

Remember to export environment variables or use inline assignment:

```bash
# Export first
export FE_LOCAL_SOURCE=/my/frontend/path
export BE_LOCAL_SOURCE=/my/backend/path

# Then start the Docker Compose
docker compose --profile local-frontend --profile local-backend up

# Or inline
FE_LOCAL_SOURCE=/my/frontend/path BE_LOCAL_SOURCE=/my/backend/path docker compose --profile local-frontend --profile local-backend up
```


# TODOs
## test
 docker compose --profile local-frontend --profile
 local-backend --profile interactive-builder up -d --no-deps
 local-edirom-online-frontend
 local-edirom-online-backend interactive-edirom-online-builder


# For Pull request
## Benefits of Shared Builder Approach

- **Faster Build Times**: Build environment is cached and reused
- **Consistent Environment**: Same build tools across frontend and backend
- **Interactive Development**: Persistent container for manual builds and debugging
- **Efficient Resource Usage**: Single builder image instead of duplicated environments
- **Automatic Dependency Resolution**: Docker Compose builds in optimal order
- **Source Context Integration**: Local source code properly integrated into the build process
