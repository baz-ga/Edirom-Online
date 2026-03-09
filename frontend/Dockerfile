#######################################
# Multi-stage Dockerfile
# 1. Set up the build environment
# 2. Build Edirom-Online packages
# 3. Run the nginx and deploy frontend
#######################################


#########################
# 1. Build Environment
#########################

# Use shared builder image
FROM edirom-online-builder:latest AS eo-builder

ARG SOURCE=https://github.com/Edirom/Edirom-Online-Frontend.git
ARG BRANCH=v1.3.0
ARG BE_PORT
ARG SENCHA_BUILD_ENV=production


############################
# 2. Edirom-Online Frontend
############################

# Get build for Edirom-Online Frontend
WORKDIR /opt/eo-frontend

RUN echo "Cloning from repo $SOURCE" && \
    git clone --recurse-submodules "$SOURCE" --branch "$BRANCH" --single-branch . && \
    if [ -n "$BE_PORT" ] && [ "$BE_PORT" != "8080" ]; then \
        echo "Writing backend.port=$BE_PORT to local.properties…"; \
        if [ -f "./local.properties" ]; then \
            sed -i '/^backend\.port=/d' local.properties; \
            echo "backend.port=$BE_PORT" >> local.properties; \
        else \
            echo "backend.port=$BE_PORT" >> local.properties; \
        fi \
    fi && \
    echo "Building Frontend XAR..." && \
    sencha app build ${SENCHA_BUILD_ENV}

#########################
# 3. Run/deploy nginx
#########################

# Use nginx as the base image
FROM nginx:alpine

# copy build files to directory
COPY --from=eo-builder /opt/eo-frontend/build/ /usr/share/nginx/html/
