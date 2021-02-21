# Minimial Debian 10 (Buster) base image (~68mb)
FROM bitnami/minideb:buster

# Install wget
RUN apt-get update && apt-get install -y wget \
  && rm -rf /var/lib/apt/lists/*

# Make gala working directory
RUN mkdir -p /gala
WORKDIR /gala

# Install linux node binaries
RUN mkdir -p /usr/local/bin \
  && wget https://static.connectblockchain.net/softnode/linux-headless-node.tar.gz \
  && tar xvf linux-headless-node.tar.gz \
  && mv linux-headless-node /usr/local/bin/gala-node-linux \
  && rm linux-headless-node.tar.gz

# Default environment variables
ENV GALA_EMAIL          user@nowhere.com
ENV GALA_PASSWORD       x
ENV NODE_SPECIFIER      1

# Start the gala node
ENTRYPOINT gala-node-linux email=$GALA_EMAIL password=$GALA_PASSWORD specifier=$NODE_SPECIFIER
