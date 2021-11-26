# Minimial Debian 11 (Bullseye) base image
FROM bitnami/minideb:bullseye

ARG DEBIAN_FRONTEND=noninteractive
ENV GALA_CONFIG_DIR /opt/gala-headless-node
ENV GALA_CONFIG_FILE $GALA_CONFIG_DIR/config.json

# Install wget
RUN apt-get update && apt-get install -y \
    wget \
    jq \
    dbus-bin \
  && rm -rf /var/lib/apt/lists/*

# Install gala-node linux binaries
RUN mkdir -p /usr/local/bin \
  && mkdir -p $GALA_CONFIG_DIR \
  && wget https://static.gala.games/node/gala-node.tar.gz \
  && tar xvf gala-node.tar.gz --directory=/usr/local/bin \
  && rm gala-node.tar.gz

# Add default config
ADD config.json $GALA_CONFIG_DIR

# Create directory for gala node config
RUN mkdir -p /gala
WORKDIR /gala

# Copy scripts and make executable
ADD entrypoint.sh .
RUN chmod +x entrypoint.sh

# IPFS ports
EXPOSE 4001 5001

# Start the gala node
ENTRYPOINT ["/bin/bash"]
CMD ["entrypoint.sh"]
