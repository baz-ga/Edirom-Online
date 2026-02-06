#############################################################
# Builder Environment Dockerfile
# Interactive build environment for local development
# Keeps build tools and dependencies alive for fast iteration
#############################################################

FROM eclipse-temurin:21

ARG ANT_VERSION=1.10.12

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
        curl \
        sudo \
        wget \
        git \
        unzip \
        libfreetype6 \
        fontconfig \
        ruby-full \
        vim \
        less \
    && rm -rf /var/lib/apt/lists/*

# Download and extract Apache Ant to opt folder
RUN wget --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz && \
    wget --no-check-certificate --no-cookies http://archive.apache.org/dist/ant/binaries/apache-ant-${ANT_VERSION}-bin.tar.gz.sha512 && \
    echo "$(cat apache-ant-${ANT_VERSION}-bin.tar.gz.sha512) apache-ant-${ANT_VERSION}-bin.tar.gz" | sha512sum -c && \
    tar -zvxf apache-ant-${ANT_VERSION}-bin.tar.gz -C /opt/ && \
    ln -s /opt/apache-ant-${ANT_VERSION} /opt/ant && \
    unlink apache-ant-${ANT_VERSION}-bin.tar.gz && \
    unlink apache-ant-${ANT_VERSION}-bin.tar.gz.sha512

# Download and install SenchaCmd Community Edition
RUN curl --silent http://cdn.sencha.com/cmd/7.0.0.40/no-jre/SenchaCmd-7.0.0.40-linux-amd64.sh.zip -o /tmp/senchaCmd.zip && \
    unzip /tmp/senchaCmd.zip -d /tmp  && \
    unlink /tmp/senchaCmd.zip  && \
    chmod o+x /tmp/SenchaCmd-7.0.0.40-linux-amd64.sh && \
    /tmp/SenchaCmd-7.0.0.40-linux-amd64.sh -Dall=true -q -dir /opt/Sencha/Cmd/7.0.0.40 && \
    unlink /tmp/SenchaCmd-7.0.0.40-linux-amd64.sh

# Put ant and sencha in the path
ENV PATH="/opt/ant/bin:/opt/Sencha/Cmd:${PATH}"

# Set working directory where source will be mounted
WORKDIR /opt/eo-frontend

# Keep container running with bash
CMD ["/bin/bash"]
