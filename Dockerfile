# Minimial Debian 10 (Buster) base image (~68mb)
FROM bitnami/minideb:buster

# Install wget
RUN apt-get update && apt-get install -y wget screen \
  && rm -rf /var/lib/apt/lists/*

# Install linux node binaries
RUN mkdir -p /usr/local/bin \
  && wget https://static.connectblockchain.net/softnode/linux-headless-node.tar.gz \
  && tar xvf linux-headless-node.tar.gz \
  && mv linux-headless-node /usr/local/bin/gala-headless-node \
  && rm linux-headless-node.tar.gz

# Make gala working directory and copy scripts
RUN mkdir -p /gala
WORKDIR /gala
COPY startup.sh .

# Default environment variables
ENV GALA_EMAIL          user@nowhere.com
ENV GALA_PASSWORD       x
ENV NODE_SPECIFIER      1

# Start the gala node
ENTRYPOINT ["screen", "-dm", "bash", "startup.sh"]
