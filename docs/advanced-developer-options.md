# Advanced Developer Options

This document covers advanced configuration options for developers working on the development of Edirom-Online-Backend or Edirom-Online-Frontend with the Edirom Online Docker Compose setup.

## Prerequisites

### Docker BuildKit

The builder image uses BuildKit features for optimized caching of build dependencies. BuildKit is enabled by default in Docker Compose v2+, which is required by the `docker compose` command (without hyphen) used throughout this documentation — no manual configuration should be needed on current Docker installations.

**Verify BuildKit is available:**
```bash
docker buildx version
```

The builder image uses BuildKit cache mounts to persist downloads across builds. See [Download Cache](#download-cache) for details on managing this cache, or [Build Failures: BuildKit Not Available](#build-failures-buildkit-not-available) if you encounter related build errors.

## Docker Compose Profiles for Local Backend and Frontend Development

Aside from the standard `docker compose --profile default up` command, which runs Edirom Online as described in the [README](../README.md), Edirom Online supports Docker Compose profiles for development scenarios with local source code.

> [!NOTE]
> **Key Benefit: Test before committing and pushing**
>
> The profiles for local frontend and backend source code will allow you to build and run your local changes before committing and pushing them to source control.

### Profile Matrix

The Docker Compose configuration uses profiles to ensure mutual exclusivity between regular and local development services. This prevents port conflicts and ensures only the intended services are running.

| Command | Backend Service | Frontend Service |
|---------|----------------|------------------|
| `docker compose --profile default up` | Regular (from remote repo) | Regular (from remote repo) |
| `docker compose --profile local-backend-source up` | **Local** (from `BE_LOCAL_SOURCE`) | Regular (from remote repo) |
| `docker compose --profile local-frontend-source up` | Regular (from remote repo) | **Local** (from `FE_LOCAL_SOURCE`) |
| `docker compose --profile local-backend-source --profile local-frontend-source up` | **Local** (from `BE_LOCAL_SOURCE`) | **Local** (from `FE_LOCAL_SOURCE`) |

**Key Features:**
- **Automatic pairing**: Each local profile automatically includes the regular version of the other service
- **No conflicts**: Regular and local versions of the same service never run simultaneously
- **Port safety**: Prevents port binding conflicts between services
- **Intuitive workflow**: Simply specify which component you're developing locally, the complement service starts automatically

> [!TIP]
> Combine with the [Shared Builder Architecture](#shared-builder-architecture)’s `local-dev-builder` to interactively build and deploy changes without restarting the Docker Compose setup.

### Profile for Local Backend Development

The `local-backend-source` profile facilitates local development of the Edirom-Online-Backend.

> [!NOTE]
>
> **Profile Benefits**
>   
>1. **Building**
>
>    When starting the Docker Compose or when rebuilding the backend service, your local source code of Edirom-Online-Backend will be built and deployed.
>
> 2. **Source Code Mounting**
>
>    The Docker Compose setup will mount your local backend source code to `/opt/eo-backend` in the container; this is especially useful in combination with the [Interactive Builder Profile](#interactive-builder-profile).

**Prerequisites**
* Acquire a local clone of [Edirom Online](https://github.com/Edirom/Edirom-Online.git)
* Acquire a local clone of [Edirom-Online-Backend](https://github.com/Edirom/Edirom-Online-Backend.git)

**Example Development Workflow**
```bash
# Clone the Edirom Online repository locally
git clone https://github.com/Edirom/Edirom-Online.git ~/projects/Edirom-Online

# Clone the Edirom-Online-Backend repository locally
git clone https://github.com/Edirom/Edirom-Online-Backend.git ~/projects/Edirom-Online-Backend

# Switch to the Edirom Online clone
cd ~/projects/Edirom-Online

# Set the backend source path (absolute path recommended)
export BE_LOCAL_SOURCE=~/projects/Edirom-Online-Backend

# Build the shared builder (first time only)
docker compose build builder

# Build and start Edirom Online with local backend
# This will build the backend from your local source code
docker compose --profile local-backend-source up --build
```

If you have made changes in your local clone of Edirom-Online-Backend and want to redeploy these after building, please refer to [Deploying Backend Changes](#deploying-backend-changes).

//TODO test just running this profile
//TODO test running instead of regular backend

### Profile for Local Frontend Development

The `local-frontend-source` profile facilitates local development of the Edirom-Online-Backend.

> [!NOTE]
>
> **Profile Benefits**
>
> 1. **Build Directory Mounting**
>
>    The nginx service will directly serve the build directory of your local Edirom-Online-Frontend clone.
>
> 2. **Live Development**
>
>    When rebuilding the Edirom-Online-Frontend, changes to your local source code will be reflected in the running application.
>
> 3. **Source Code Mounting**:
>
>    The Docker Compose setup will mount your local backend source code to `/opt/eo-backend` in the container; this is especially useful in combination with the [Interactive Builder Profile](#interactive-builder-profile).

Prerequisites:
* Acquire a local clone of [Edirom Online](https://github.com/Edirom/Edirom-Online.git)
* Acquire a local clone of [Edirom-Online-Frontend](https://github.com/Edirom/Edirom-Online-Frontend.git)

**Example Frontend Development Workflow**
```bash
# Clone the Edirom Online repository locally
git clone https://github.com/Edirom/Edirom-Online.git ~/projects/Edirom-Online

# Clone the Edirom-Online-Frontend repository locally
git clone https://github.com/Edirom/Edirom-Online-Frontend.git ~/projects/Edirom-Online-Frontend

# Switch to the Edirom Online clone
cd ~/projects/Edirom-Online

# Set the frontend source path (absolute path recommended)
export FE_LOCAL_SOURCE=~/projects/Edirom-Online-Frontend

# Build the shared builder (first time only)
docker compose build builder

# Build and start Edirom Online with local frontend
# This will build the frontend from your local source code
docker compose --profile local-frontend-source up --build
```

//TODO test standlaone
//TODO test no-deps

You can rebuild in any way you want, whether natively on your host or by rebuilding the frontend service, for example, using the [Interactive Builder Profile](#interactive-builder-profile).

### Example Full Stack Development Workflow
```bash
# Clone all three repositories
git clone https://github.com/Edirom/Edirom-Online.git ~/projects/Edirom-Online
git clone https://github.com/Edirom/Edirom-Online-Frontend.git ~/projects/Edirom-Online-Frontend
git clone https://github.com/Edirom/Edirom-Online-Backend.git ~/projects/Edirom-Online-Backend

export FE_LOCAL_SOURCE=~/projects/Edirom-Online-Frontend
export BE_LOCAL_SOURCE=~/projects/Edirom-Online-Backend

# Build the shared builder (first time only)
docker compose build builder

# Start both local development services
docker compose --profile local-frontend-source --profile local-backend-source up
```

> [!TIP]
> There’s even more candy when combined with the interactive builder ;-)

## Shared Builder Architecture

Edirom Online offers a shared builder architecture to optimise build times and minimise duplication in the Docker build process. Both the frontend and backend Dockerfiles use it for building; i.e., it serves as the _shared_ base for all builds in the Docker Compose setup.

The shared builder provides a build environment containing:
- Java 8 JRE
- Apache Ant
- SenchaCmd (for frontend builds)
- Build dependencies (curl, wget, git, etc.)
- Development tools (vim, less)

### Architecture Details

The shared builder architecture consists of:

1. **`builder/Dockerfile`**: Defines the common build environment
2. **`frontend/Dockerfile.local`**: Uses shared builder + copies frontend source
3. **`backend/Dockerfile.local`**: Uses shared builder + copies backend source
4. **Docker Compose**: Orchestrates build dependencies and contexts
5. **Interactive Builder Profile**: As standlaone service or for live development

### Docker Compose Build Process Flow

1. **Builder Stage**: Docker Compose automatically builds the shared builder first
2. **Source Context**: The local source directory of Edirom-Online-Frontend or Edirom-Online-Backend becomes the build context
3. **Build Execution**: The Dockerfile copies your source and runs the build
4. **Final Stage**: Build artifacts are copied to the final runtime image


### Interactive Builder Profile

The `local-dev-builder` profile facilitates interactive development with a persistent build environment. Because the builder mounts the local source code of Edirom-Online-Backend and Edirom-Online-Frontend to `/opt/eo-backend` and `/opt/eo-frontend` respectively, you can use it standalone to build your local clones of Edirom-Online-Backend and Edirom-Online-Frontend. The builder will create the build artifacts in the respective directories on your host system.

> [!NOTE]
> Running the interactive builder profile standalone is helpful if you want to make changes to the build processes. For frontend and backend development, we recommend [Combined Usage with Local Development Profiles](combined-usage-with-local-development-profiles).

```bash
export FE_LOCAL_SOURCE=/path/to/your/frontend
export BE_LOCAL_SOURCE=/path/to/your/backend

# Start the persistent interactive builder
docker compose --profile local-dev-builder up -d edirom-builder

# Access the interactive shell
docker compose exec edirom-builder bash
```

**Inside the interactive builder container:**
- Frontend source: `/opt/eo-frontend`
- Backend source: `/opt/eo-backend`
- All build tools available in PATH
- Run builds manually:
    - Edirom-Online-Frontend: `./build.sh`
    - Edirom-Online-Backend: `ant`

#### Combined Usage with Local Development Profiles

```bash
# 1. Set source paths (absolute paths recommended)
export FE_LOCAL_SOURCE=/path/to/your/frontend
export BE_LOCAL_SOURCE=/path/to/your/backend

# 2. Build all three services
docker compose --profile local-frontend-source --profile local-backend-source --profile local-dev-builder build

# 3. Start ONLY local development services in detached mode (avoids conflicts with regular services)
docker compose --profile local-frontend-source --profile local-backend-source --profile local-dev-builder up -d --no-deps edirom-online-frontend-local-source edirom-online-backend-local-source edirom-builder

docker compose --profile local-dev-builder up -d edirom-builder
# 4. Enter edirom-builder interactive shell

docker compose exec edirom-builder bash
```

Fastlane:
```bash
 docker compose up -d edirom-online-frontend-local-source edirom-online-backend-local-source edirom-builder --build --no-deps
 ```

#### Deploying Frontend Changes

Redeploying frontend changes is not necessary and only needs a browser refresh. Nevertheless, there are some caveats to consider. Here’s a recommended workflow:

```bash
# After having made your changes to the source code
# In the interactive builder, switch to the mounted frontend directory
cd /opt/eo-frontend

# Recommended build command (avoids cleaning mounted build directory)
sencha app build testing && ant inject-properties

# Alternative: Use full build script (may interfere with nginx mount due to clean step)
# ./build.sh

# The changes are automatically available since /opt/eo-frontend/build is mounted to nginx
# No deployment or container rebuild needed – just refresh your browser!
```

**Alternative: Container Rebuild (if needed)**

If you prefer a clean rebuild or encounter caching issues:

```bash
# Rebuild the frontend container with your changes
docker compose --profile local-frontend-source build edirom-online-frontend-local-source

# Restart the frontend service
docker compose restart edirom-online-frontend-local-source
```

#### Deploying Backend Changes

As the XAR artefact of the Edirom-Online-Backend needs to be deployed to eXist-db, this involves some additional steps. The following provides some options for you to choose your preferred method.

**Method 1: eXist-db Dashboard (Web Interface)**

> [!IMPORTANT]
> The actual value for the backend port and credentials might depend on your environment variables; please adjust them accordingly.

1. Open the eXist-db Dashboard
   Navigate to: http://localhost:8080/exist/apps/dashboard
2. Log in with the administrator account
    User: admin
    Password: changeme
3. Select “Package Manager“ from the menu on the left side
4. Upload the XAR from your filesystem

**Method 2: Copy XAR to Autodeploy Directory + Container Restart**

> [!IMPORTANT]
> eXist-db only processes the autodeploy directory when it starts up, so you need to restart the container after copying the XAR

//TODO following doesn’t work from interactive builder but from native terminal
```bash
# After having made your changes to the source code
# In your native terminal, switch to the mounted backend directory ($BE_LOCAL_SOURCE)
cd "$BE_LOCAL_SOURCE"

# List contents of build-xar directory to select the correct build
ls build-xar

# Optional: Find the name of your backend container for the subsequent command
docker ps | grep eXist-db-local

# Copy the built XAR to the eXist-db autodeploy directory
docker cp edirom-builder:/opt/eo-backend/build-xar/[your-xar-file].xar eXist-db-local:/opt/exist/autodeploy/

# Restart eXist-db to process the new XAR
docker compose restart edirom-online-backend-local-source

# Monitor eXist-db logs to see deployment
docker compose logs -f edirom-online-backend-local-source
```

**Method 3: REST API Deployment**

Deploy directly via eXist-db’s REST API. 

- Package version must be different from the currently installed version
- Consult [eXist-db package repository documentation](https://exist-db.org/exist/apps/doc/repo.xml) for complete details

```bash
# After having made your changes to the source code
# In the interactive builder, switch to the mounted backend directory
cd /opt/eo-backend

# Optional: clean build-xar directory (avoid problems with wildcard command below)
rm 

# Build the backend
ant

# Upload XAR
# Generic command (using wildcard - see troubleshooting below)
curl -u admin:changeme -X PUT \
 -H "Content-Type: application/octet-stream" \
  -T "build-xar/Edirom-Online-Backend-*.xar" \
 "http://eXist-db-local:8080/exist/rest/db/system/repo/Edirom-Online-Backend-*.xar"

# Install XAR (using wildcard - see troubleshooting below)
curl -u admin:changeme -X POST \
 -H "Content-Type: application/xml" \
  -d '<query xmlns="http://exist.sourceforge.net/NS/exist">
 <text>repo:install-and-deploy-from-db("/db/system/repo/Edirom-Online-Backend-*.xar")</text>
 </query>' \
 "http://eXist-db-local:8080/exist/rest/db"
 ```

> [!WARNING]
> The above wildcard command would upload any backend XAR; this can be problematic because the build script of Edirom-Online-Backend keeps XARs from individual builds alongside each other.

**Troubleshooting**

If the above command worked out for you but you don’t see the changes deployed to eXist-db this might have several resaons, e.g.:

1. The above wildcard command uploaded and deployed multiple packages. Try being explicit about the XAR name.

    ```bash
    # Check available XAR filenames and versions
    ls -la build-xar/

    # Upload XAR
    # Modify the above wildcard command to include a specific filename
    curl -u admin:changeme -X PUT \
    -H "Content-Type: application/octet-stream" \
    -T "build-xar/Edirom-Online-Backend-1.0.1-20250924-2320.xar" \
    "http://eXist-db-local:8080/exist/rest/db/system/repo/Edirom-Online-Backend-1.0.1-20250924-2320.xar"

    # Install XAR
    # Modified the above wildcard command to include a specific filename
    curl -u admin:changeme -X POST \
    -H "Content-Type: application/xml" \
    -d '<query xmlns="http://exist.sourceforge.net/NS/exist">
    <text>repo:install-and-deploy-from-db("/db/system/repo/Edirom-Online-Backend-1.0.1-20250924-2320.xar")</text>
    </query>' \
    "http://eXist-db-local:8080/exist/rest/db"
    ```

2. The version of your new package and the the already installed package match. In this case eXist-db will not install the new package. You might want to uninstall the previous version before deploying the new package.

    ```bash
    curl -u admin:changeme -X POST \
    -H "Content-Type: application/xml" \
    -d '<query xmlns="http://exist.sourceforge.net/NS/exist">
    <text>repo:undeploy("http://www.edirom.de/apps/EdiromOnlineBackend")</text>
    </query>' \
    "http://eXist-db-local:8080/exist/rest/db"
    ```

//TODO test
**Option 3: Container Rebuild (Clean Deployment)**

For a complete fresh deployment:

```bash
# Rebuild the backend service with your updated source
docker compose --profile local-backend-source build edirom-online-backend-local-source

# Restart the backend service
docker compose restart edirom-online-backend-local-source
```

# Quick Reference

## Build Commands

### Build Individual Services
```bash
# Set source paths (absolute paths recommended)
export FE_LOCAL_SOURCE=/path/to/frontend
export BE_LOCAL_SOURCE=/path/to/backend

# Build frontend only
docker compose --profile local-frontend-source build edirom-online-frontend-local-source

# Build backend only  
docker compose --profile local-backend-source build edirom-online-backend-local-source

# Build both together (automatic dependency resolution)
docker compose --profile local-frontend-source --profile local-backend-source build
```

## Run Complete Local Development Stack
```bash
# Build and start both frontend and backend with local source
docker compose --profile local-frontend-source --profile local-backend-source up
```

```bash
# Start ONLY local development services (recommended to avoid conflicts with regular services)
docker compose --profile local-frontend-source --profile local-backend-source up --no-deps edirom-online-frontend-local-source edirom-online-backend-local-source
```

## Service Management
```bash
# Stop local development services
docker compose stop edirom-online-frontend-local-source edirom-online-backend-local-source

# Restart a specific service
docker compose restart edirom-online-frontend-local-source

# View logs for specific service
docker compose logs -f edirom-online-frontend-local-source
```

## Troubleshooting Deployment
//TODO rework
- **Wildcard issues**: Using `*` in filenames may select multiple XARs if you have multiple versions built - use `ls build-xar/` to check
- **No changes visible**: Check if package version in `expath-pkg.xml` was updated
- **Version conflicts**: eXist-db may not install the new package if the version number is the same as the one currently installed
- **Dashboard limitations**: Method B requires manual uninstall/reinstall if the package version hasn’t changed
- **XQuery method advantage**: Method A (XQuery) can handle same-version updates better than Dashboard
- **Installation vs Upload**: REST API only uploads the file - you must use one of the methods above to install it
- **XQuery errors**: Check eXist-db logs if the XQuery installation command fails



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
docker compose logs -f edirom-online-backend-local-source

# Check deployed applications via eXist-db dashboard
# Navigate to http://localhost:8080/exist/apps/dashboard

# Quick frontend development cycle
docker compose exec edirom-builder bash
cd /opt/eo-frontend
# make changes to source files
sencha app build testing && ant inject-properties
# refresh browser to see changes

# Quick backend development cycle
docker compose exec edirom-builder bash
cd /opt/eo-backend

# make changes to source files
ant
docker cp edirom-builder:/opt/eo-backend/build-xar/[xar-file].xar eXist-db-local:/opt/exist/autodeploy/
```




//put to a separate file

## Environment Variables

### Local Development Variables

- `FE_LOCAL_SOURCE`: Path to local frontend source code (required for `local-frontend-source` profile)
- `BE_LOCAL_SOURCE`: Path to local backend source code (required for `local-backend-source` profile)
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

## Volume Mount Issues

If you encounter permission issues with volume mounts:

1. Ensure the `FE_LOCAL_SOURCE` and/or `BE_LOCAL_SOURCE` directories exist and are readable
2. Check Docker Desktop file sharing settings (macOS/Windows)
3. Verify the build directory exists: `${FE_LOCAL_SOURCE}/build` (for frontend development)

## Profile Not Working

Make sure you’re using the correct syntax:

```bash
# Correct
docker compose --profile local-frontend-source up
docker compose --profile local-backend-source up

# Incorrect (missing --profile flag)
docker compose local-frontend-source up
```

## Environment Variables Not Applied

Remember to export environment variables or use inline assignment:

```bash
# Export first
export FE_LOCAL_SOURCE=/my/frontend/path
export BE_LOCAL_SOURCE=/my/backend/path

# Then start the Docker Compose
docker compose --profile local-frontend-source --profile local-backend-source up

# Or inline
FE_LOCAL_SOURCE=/my/frontend/path BE_LOCAL_SOURCE=/my/backend/path docker compose --profile local-frontend-source --profile local-backend-source up
```


# TODOs
## test
 docker compose --profile local-frontend-source --profile
 local-backend-source --profile local-dev-builder up -d --no-deps
 edirom-online-frontend-local-source
 edirom-online-backend-local-source edirom-builder
  

# For Pull request
## Benefits of Shared Builder Approach

- **Faster Build Times**: Build environment is cached and reused
- **Consistent Environment**: Same build tools across frontend and backend
- **Interactive Development**: Persistent container for manual builds and debugging
- **Efficient Resource Usage**: Single builder image instead of duplicated environments
- **Automatic Dependency Resolution**: Docker Compose builds in optimal order
- **Source Context Integration**: Local source code properly integrated into the build process
