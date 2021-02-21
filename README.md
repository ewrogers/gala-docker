# Gala Node Dockerfile

This Dockerfile is used to run a [Gala Node](https://gala.fan/9yqaqUonx) containerized in Docker. It uses a lean Debian 10 (Buster) image but should run on any Docker host that can run Linux containers (including Windows and MacOS).

If this guide is helpful to you, I'd appreciate if you used my Gala [referal link](https://gala.fan/9yqaqUonx) if you decide to buy a node. Thanks, it really helps! :smiley:

## Why not use the Linux instructions from Gala Games?

Unfortunately, at the time of writing their Linux guide is fairly poor and not very scalable. It creates a `systemd` service and offers very little in terms of logging output and seeing the progress of your node throughout the day. For anyone who has tried to deploy a Linux node, it has been frustrating.

Docker solves both of these problems. Each container is run in an entirely isolated environment, allowing muliple nodes to easily be run on the same machine via the `NODE_SPECIFIER` variable. It also allows us to peek into the container and see the UI progress of each node. Since we no longer rely on `systemd`, we can run on a lot more Linux distros as well.

For more advanced setups, this could be run in a Docker Swarm cluster and be given CPU/memory limitations per container.

## Installation

### Docker

You will first need to install Docker on your host machine (including VPS instances).

- **Windows**: [Install Docker on Windows](https://docs.docker.com/docker-for-windows/install/)
- **macOS**:
    - Intel Macs: [Install Docker on Intel Macs](https://docs.docker.com/docker-for-mac/install/)
    - M1 Macs: [Install Docker on Apple Silicon](https://docs.docker.com/docker-for-mac/apple-m1/)
- **Linux**:
    - Ubuntu: [Install Docker on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
    - Debian: [Install Docker on Debian](https://docs.docker.com/engine/install/debian/)
    - Fedora: [Install Docker on Fedora](https://docs.docker.com/engine/install/fedora/)
    - CentOS: [Install Docker on CentOS](https://docs.docker.com/engine/install/centos/)

### Build Container

You will need to build the simple container on your Docker host machine. Once you build the container you can publish it to your own Docker container repository for reuse across installations.

```
$ git clone https://github.com/ewrogers/gala-docker.git
$ cd gala-docker
$ docker build -t gala-node:latest .
```

Verify the image was successfully built:

```
$ docker images | grep gala
> gala-node         latest    7240420ada66   2 minutes ago      236MB
```

## Usage

### Configure Node

Once you have Docker installed and built the container image, you will need to configure the nodes with your Gala credentials:

```
$ ./configure
```

You will be prompted to enter your Gala email and password for running the node. You can verify them by checking the `.env` file generated. You can either modify them there or re-run the `configure` script to overwrite them at any time.

**NOTE:** You will need delete and recreate any existing Gala node containers for them to take your new credentials.

### Running the Container

Now you are ready to run the container! Use the following command:

```
$ docker run -itd --name "gala-node-1" \
  --restart=unless-stopped \
  --env-file .env \
  -v /etc/machine-id:/etc/machine-id \
  gala-node:latest
```

If you want to update the `NODE_SPECIFIER`, append the `-e NODE_SPECIFIER=x` argument in the command above. This should only be used when running more than one container on the same Docker host.

**NOTE:** The `-v /etc/machine-id:/etc/machine-id` line is very important! If you omit this, every time your container starts up it will have a different machine ID and you will lose progress across restarts! This mount ensures that you retain the same machine ID across reboots/restarts and always get proper credit.

### Peeking into the Container

You may be wondering why we specified the `-it` command line arguments while also using the `-d` (daemon) background flag. This gives an interactive TTY terminal that we can use to "peek" and see how the node is running.

```
$ docker attach gala-node-1
```

This should show you a simple terminal-based UI of the node's progress. Press <kbd>Ctrl</kbd> + <kbd>P</kbd>, <kbd>Ctrl</kbd> + <kbd>Q</kbd> to dettach from the container's TTY.

![Linux terminal UI](screenshots/ui.png?raw=true)

**NOTE:** Despite the program displaying "ESC to exit", you should not use that as it will terminate the node. Fortunately, it will automatically be restarted (assuming you used the `--restart=unless-stopped` argument when creating the container). Not a big deal, just avoid restarting your node unncessarily, but you won't lose progress for the day.

## Troubleshooting

### My containers are crashing or constantly restarting, why?

First step should be to check your logs, via `docker logs <container>`. You may see errors regarding account authentication or network problems here. Next step would be to check your `.env` file that you have the correct and up to date credentials. Remember to stop -> remove -> recreate any containers if you recently updated this file.

### How can I be sure I am getting credit for my node?

You should check your [Account Page](https://app.gala.games/account) under `Node Info` and see the expected number of nodes online. If the number remains incorrect after 5 minutes, check your containers for any errors (see next question).

### My node is running but I'm not getting credit, what's the deal?
The problem is likely that your machine ID is not unique in the Gala network. This is common when using VPS providers, but can be fixed easily.

Try the following in a **root** shell:
```
# rm /etc/machine-id /var/lib/dbus/machine-id
# dbus-uuidgen > /etc/machine-id
# cp /etc/matchine-id /var/lib/dbus/machine-id
```

You will also need to restart any running Gala node Docker containers for the machine ID changes to be seen by them.

