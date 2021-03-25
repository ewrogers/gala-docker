# Gala Node Dockerfile

This repo has been updated to work on the latest Gala Node v1.1.0 software. If you are looking to upgrade your existing nodes, check out the section below.

## Table of Contents
1. [Overview](#overview)
2. [Installation](#installation)
3. [Building the Container](#building-the-container)
4. [Configuration](#configuration)
5. [Running the Container](#running-the-container)
6. [Checking Node Progress](#checking-node-progress)
7. [Upgrading the Container](#upgrading-the-container)
8. [Frequently Asked Questions](#frequently-asked-questions)

## Overview

This Dockerfile is used to run a [Gala Node](https://gala.fan/9yqaqUonx) containerized in Docker. It uses a lean Debian 10 (Buster) image but should run on any Docker host that can run Linux containers (including Windows and MacOS).

If this guide is helpful to you, I'd appreciate if you used my Gala [referal link](https://gala.fan/9yqaqUonx) if you decide to buy a node. Thanks, it really helps! :smiley:

### System Requirements

- 1 CPU Core
- 256MB RAM (512MB Recommended)
- 10GB Disk Space (Solid State Recommended)
- IPv4 Address (IPv6 not supported)
- Stable Broadband Connection (50+ Mbit)

**NOTE:** These requirements are subject to change as the Gala Network grows. IPFS will be used in the near future, meaning these requirements will increase **significantly** from what they are now. Most important will be your bandwidth (namely upstream). Prepare accordingly.

### Why not use the Linux instructions from Gala Games?

Unfortunately, at the time of writing their Linux guide is fairly poor and not very scalable. It creates a `systemd` service and offers very little in terms of logging output and seeing the progress of your node throughout the day. For anyone who has tried to deploy a Linux node, it has been frustrating.

Docker solves both of these problems. Each container is run in an entirely isolated environment, allowing muliple nodes to easily be run on the same machine via the `NODE_SPECIFIER` variable. It also allows us to peek into the container and see the UI progress of each node. Since we no longer rely on `systemd`, we can run on a lot more Linux distros as well.

For more advanced setups, this could be run in a Docker Swarm cluster and be given CPU/memory limitations per container. As requirements grow, this will likely become more ideal for hosting multiple nodes across multiple VPS/machines but for now it is not required.

**NOTE: The Gala Node does NOT support IPv6 networking!** You must use IPv4 networking for it work properly.

## Installation

### Docker

You will first need to install Docker on your host machine (including VPS instances).

I personally find [Vultr](https://www.vultr.com/?ref=8809552-6G) to be one of the most affordable VPS providers, feel free to signup with the link for a $50 ~~$100~~ credit.

- **Windows**: [Install Docker on Windows](https://docs.docker.com/docker-for-windows/install/)
- **macOS**:
    - Intel Macs: [Install Docker on Intel Macs](https://docs.docker.com/docker-for-mac/install/)
    - M1 Macs: [Install Docker on Apple Silicon](https://docs.docker.com/docker-for-mac/apple-m1/)
- **Linux**:
    - Ubuntu: [Install Docker on Ubuntu](https://docs.docker.com/engine/install/ubuntu/)
    - Debian: [Install Docker on Debian](https://docs.docker.com/engine/install/debian/)
    - Fedora: [Install Docker on Fedora](https://docs.docker.com/engine/install/fedora/)
    - CentOS: [Install Docker on CentOS](https://docs.docker.com/engine/install/centos/)

**Gala node is currently only supported on the x86/64 architecture.** Sorry, no Raspberry PIs or other ARMv7 devices yet!

#### Windows Users

Make sure you are running Linux containers, you can check here:
![Windows Switch Daemon](screenshots/switchdaemon.png?raw=true)

If it says "Switch to Windows containers..." that means you're already set to use Linux containers (which is good).

## Building the Container

You will need to build the simple container on your Docker host machine. Once you build the container you can publish it to your own Docker container repository for reuse across installations.

```
$ git clone https://github.com/ewrogers/gala-docker.git
$ cd gala-docker
$ docker build -t gala-node:1.1.0 .
$ docker build -t gala-node:latest .
```

We run the build command twice so that we have both an explicit `1.1.0` version and a `latest` alias to that. This allows us to rollback to previous versions if something were to go wrong when using `latest`.

Verify the image was successfully built:

```
$ docker images | grep gala
> gala-node         1.1.0     7240420ada66   2 minutes ago      236MB
> gala-node         latest    7240420ada66   2 minutes ago      236MB
```

## Configuration

### Gala Account

Once you have Docker installed and built the container image, you will need to configure the nodes with your Gala credentials:

```
$ ./configure
```

If you have issues with the command above, try the following:

`bash configure.sh` or `sh configure.sh` depending on your shell.

You will be prompted to enter your Gala email and password for running the node. You can verify them by checking the `.env` file generated. You can either modify them there or re-run the `configure` script to overwrite them at any time.

If you *still* cannot run the script (or are on Windows), create the `.env` file manually with the following contents:

```
GALA_EMAIL=<your email login>
GALA_PASSWORD=<your password>
NODE_SPECIFIER=1
```

**NOTE:** You will need stop -> remove -> recreate any existing Gala node containers for them to take your new credentials (such as updating your password).

### Multiple Gala Accounts

If you are trying to run nodes across multiple Gala accounts, you will need to create separate `.env` files for each one. For example, let's pretend I have a total of six nodes spread across three separate gala accounts (3x2).

#### Configuring Accounts

Setting up each account credentials:
```
$ ./configure
$ mv .env .env.first
$ ./configure
$ mv .env .env.second
$ ./configure
$ mv .env .env.third
```

#### Configuring Machine IDs

Since each Gala account expects a unique machine ID for their node(s), we'll generate one for each account instead of using the standard `/etc/machine-id`:
```
$ dbus-uuidgen > machine-id-first
$ dbus-uuidgen > machine-id-second
$ dbus-uuidgen > machine-id-third
```

## Running the Container

Now you are ready to run the container! Here are the commands for running a single node.

### Linux/macOS:
```
$ docker run -itd --name "gala-node-1" \
  --restart=unless-stopped \
  --env-file .env \
  -v /etc/machine-id:/etc/machine-id \
  gala-node:latest
```

**NOTE:** The `-v /etc/machine-id:/etc/machine-id` line is very important! If you omit this, every time your container starts up it will have a different machine ID and you will lose progress across restarts! This mount ensures that you retain the same machine ID across reboots/restarts and always get proper credit.

### Windows:

You won't have an `/etc/machine-id` file locally. Instead you should run `wmic csproduct get UUID` and copy that `UUID` (without dashes) into a file called `machine-id.txt` and modify the command above to use `-v machine-id.txt:/etc/machine-id` instead.

```
$ docker run -itd --name "gala-node-1" --restart=unless-stopped --env-file .env -v machine-id.txt:/etc/machine-id gala-node:latest
```

### Multiple Nodes - Same Account

If you want to run multiple nodes for the same Gala account, you will use the `NODE_SPECIFIER` variable for the second (and beyond) node for that account. To do that, update the `NODE_SPECIFIER`, append the `-e NODE_SPECIFIER=x` argument in the command above when running the additional nodes. This is not required for the first node, as it defaults to `1` automatically.

For example, on the second node for my account:
```
$ docker run -itd --name "gala-node-2" \
  --restart=unless-stopped \
  --e NODE_SPECIFIER=2 \
  --env-file .env \
  -v /etc/machine-id:/etc/machine-id \
  gala-node:latest
```

You must also update the name of the container to be unique.

### Nodes Across Gala Accounts

If you are trying to run nodes across multiple Gala accounts, you will need to create separate `.env` files for each one. For example, let's pretend I have a total of six nodes spread across three separate gala accounts (2x3).

This assumes you've follow the steps from the [Configuration](#configuration) section on multiple env files and machine IDs.

Now it's just a matter of starting up each container:
```
$ docker run -itd --name "gala-node-first-1" \
  --restart=unless-stopped \
  --e NODE_SPECIFIER=1 \
  --env-file .env.first \
  -v machine-id-first:/etc/machine-id \
  gala-node:latest
  
$ docker run -itd --name "gala-node-first-2" \
  --restart=unless-stopped \
  --e NODE_SPECIFIER=2 \
  --env-file .env.first \
  -v machine-id-first:/etc/machine-id \
  gala-node:latest
```

Repeat the following while changing the `--name`, `-e NODE_SPECIFIER=`, `--env-file=` and `-v machine-id-xxx:/etc/machine-id` values as necessary. You can do this for as many accounts and nodes as you need per account. If you are just running a single node for an account, you can leave off the `NODE_SPECIFIER` argument, as the default of `1` will suffice.

## Checking Node Progress

You may be wondering why we specified the `-it` command line arguments while also using the `-d` (daemon) background flag. This gives an interactive TTY terminal that we can use to "peek" and see how the node is running.

```
$ docker attach gala-node-1
```

This should show you a simple terminal-based UI of the node's progress. Press <kbd>Ctrl</kbd> + <kbd>P</kbd>, <kbd>Q</kbd> to dettach from the container's TTY.

![Linux terminal UI](screenshots/ui.png?raw=true)

**NOTE:** Despite the program displaying "ESC to exit", you should not use that as it will terminate the node. Fortunately, it will automatically be restarted (assuming you used the `--restart=unless-stopped` argument when creating the container). Not a big deal, just avoid restarting your node unncessarily, but you won't lose progress for the day.

## Upgrading the Container

If you already have existing containers running the older Gala node software, it is easy to upgrade your nodes.

### Rebuild the Container

First run the steps from the [Building the Container](#building-the-container) section. If you already have the repo cloned you can use `git pull` to just get the latest files, no need to clone again.

### Removing the Containers

These commands will stop and remove the running container so it can be replaced.
```
$ docker stop gala-node-1
$ docker rm gala-node-1
```

### Recreating the Container

Then it is just a matter of recreating the containers using the same commands as you did the first time around. See [Running the Container](#running-the-container) for details.

## Frequently Asked Questions

### How is the credit calculated?

Your Gala node will contact the Gala server periodically throughout the day. Each time it does, you gain credit for the day **by unique machine ID**. This is why is important that you retain the same machine ID each time your node runs, so you don't split up credit across several IDs. **To get credit for the daily distribution, you must reach 100% for that machine ID**. Meaning, if you get 95% on one and 5% on another, you do not receive credit.

### What is the NODE_SPECIFIER for?

This is only used when you are running more than one Gala node on the same machine (or VPS). By default, this value is `1`, and is appended to your machine ID when contacting the Gala server for daily distribution credit. Since each machine has its own unique ID, you do not need it when running a single node on that machine.

However, when you are running multiple nodes on a single machine you should increment this for each node. For example, the second one would be `-e NODE_SPECIFIER=2`, and so on. This way you can get multiple node credit for the same machine ID without needing to spin up multiple VPS instances or physical machines.

### My containers are crashing or constantly restarting, why?

First step should be to check your logs, via `docker logs <container>`. You may see errors regarding account authentication or network problems here. Next step would be to check your `.env` file that you have the correct and up to date credentials. Remember to stop -> remove -> recreate any containers if you recently updated this file.

### How can I be sure I am getting credit for my node?

You should check your [Account Page](https://app.gala.games/account) under `Node Info` and see the expected number of nodes online. If the number remains incorrect after 5 minutes, check your containers for any errors (see next question).

### My node is running but I'm not getting credit, what's the deal?
The problem is likely that your machine ID is not unique in the Gala network. This is common when using Linux on VPS providers, but can be fixed easily.

Try the following in a **root** shell:
```
# rm /etc/machine-id /var/lib/dbus/machine-id
# dbus-uuidgen > /etc/machine-id
# cp /etc/machine-id /var/lib/dbus/machine-id
```

You will also need to restart any running Gala node Docker containers for the machine ID changes to be seen by them.
