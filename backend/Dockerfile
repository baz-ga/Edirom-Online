#####################################
# Multi-stage Dockerfile
# 1. Set up the build environment
# 2. Build Edirom-Online packages
# 3. Run the eXist-db and deploy XARs
#####################################


#########################
# 1. Build Environment
#########################

FROM edirom-online-edirom-builder:latest AS eo-builder

ARG SOURCE=https://github.com/Edirom/Edirom-Online-Backend.git
ARG BRANCH=v1.3.0
ARG EDITION
ARG ROASTER_VERSION=1.11.0


###########################
# 2. Edirom-Online Backend
###########################

# Get build for Edirom-Online Backend
WORKDIR /opt/eo-backend

RUN echo "Cloning from repo $SOURCE" && \
    git clone --recurse-submodules "$SOURCE" --branch "$BRANCH" --single-branch . && \
    echo "Building Backend XAR..." && \
    ant

RUN if [ -n "$EDITION" ]; then \
        echo "Downloading Edition XAR from $EDITION" && \
        mkdir -p /opt/eo-editions && \
        cd /opt/eo-editions && \
        curl -L -O "$EDITION"; \
    else \
        mkdir -p /opt/eo-editions && \
        echo "Note: EDITION_XAR not provided. Please add manually to eXist-db."; \
    fi

RUN echo "Downloading dependencies..." && \
    mkdir -p /opt/roaster && \
    cd /opt/roaster && \
    curl -L -O "https://exist-db.org/exist/apps/public-repo/public/roaster-${ROASTER_VERSION}.xar";


#########################
# 3. Run/deploy eXist-db
#########################

FROM stadlerpeter/existdb:6
ENV EXIST_PASSWORD=changeme

# add XARs to autodeploy directory of exist
ADD ./autodeploy ${EXIST_HOME}/autodeploy/

# copy built XARs to autodeploy directory of exist
COPY --from=eo-builder /opt/eo-backend/build-xar/*.xar ${EXIST_HOME}/autodeploy/
COPY --from=eo-builder /opt/eo-editions/*.xar ${EXIST_HOME}/autodeploy/
COPY --from=builder /opt/roaster/*.xar ${EXIST_HOME}/autodeploy/
