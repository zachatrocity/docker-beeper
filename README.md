# Beeper Desktop in yor web browser!

<p align="center">
  <a href="https://www.beeper.com/">
    <img src="https://avatars.githubusercontent.com/u/74791520?s=300&v=4" alt="beeper">
  </a>
</p>

| Beta App | Legacy App |
|:--------:|:----------:|
| ![Beta App](https://gist.githubusercontent.com/zachatrocity/e0246929ef65bb738bcf7a74c42b1bbf/raw/6cdff01bc3e713e28e885460ea4e51f64b8bbe59/IMG_0294.jpeg) | ![Legacy App](https://gist.githubusercontent.com/zachatrocity/e0246929ef65bb738bcf7a74c42b1bbf/raw/6cdff01bc3e713e28e885460ea4e51f64b8bbe59/IMG_0293.jpeg) |


> **Note:** This repo was a fork of the [LinuxServer.io](https://linuxserver.io) container obsidian image and has been repurposed for Beeper. Support for linux server mods and ecosystem might limited. If you expose this to the public internet you do so at your own risk

[Beeper](https://www.beeper.com/) is a universal chat app that connects 15 different chat networks including WhatsApp, Signal, Telegram, Slack, Discord, and more.

## tldr installation 
Docker compose `compose.yml`:

```yaml
---
services:
  beeper:
    image: ghcr.io/zachatrocity/docker-beeper:latest
    container_name: beeper
    security_opt:
      - seccomp:unconfined #optional
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
    volumes:
      - /path/to/config:/config
    ports:
      - 3000:3000
      - 3001:3001
    devices:
      - /dev/dri:/dev/dri #optional
    shm_size: "1gb"
    restart: unless-stopped
```

## Legacy and Beta Apps

⚠️ Beeper has removed the download links for v3 as far as I can tell. The last version of this image that is compatible with `USE_LEGACY_BIN` is [b16f940](https://github.com/zachatrocity/docker-beeper/pkgs/container/docker-beeper/393086004?tag=sha-b16f940b40f8e2f04d9ecd587d780d407b385ca2) 

This Docker image supports both the legacy and beta (v4) versions of Beeper. You can switch between them using the `USE_LEGACY_BIN` environment variable in your docker-compose file:

- Set `USE_LEGACY_BIN=true` to use the legacy version
- Set `USE_LEGACY_BIN=false` or omit the variable to use the beta version

The legacy version is the stable, older release of Beeper, while the beta version includes newer features but may be less stable. Choose the version that best suits your needs.

## Application Setup

The application can be accessed at:

* http://yourhost:3000/
* https://yourhost:3001/

**Modern GUI desktop apps have issues with the latest Docker and syscall compatibility, you can use Docker with the `--security-opt seccomp=unconfined` setting to allow these syscalls on hosts with older Kernels or libseccomp**

### Security

>[!WARNING]
>Do not put this on the Internet if you do not know what you are doing.

By default this container has no authentication and the optional environment variables `CUSTOM_USER` and `PASSWORD` to enable basic http auth via the embedded NGINX server should only be used to locally secure the container from unwanted access on a local network. If exposing this to the Internet we recommend putting it behind a reverse proxy and ensuring a secure authentication solution is in place. From the web interface a terminal can be launched and it is configured for passwordless sudo, so anyone with access to it can install and run whatever they want along with probing your local network.

### Options in all KasmVNC based GUI containers

This container is based on [Docker Baseimage KasmVNC](https://github.com/linuxserver/docker-baseimage-kasmvnc) which means there are additional environment variables and run configurations to enable or disable specific functionality.

#### Optional environment variables

| Variable | Description |
| :----: | --- |
| CUSTOM_PORT | Internal port the container listens on for http if it needs to be swapped from the default 3000. |
| CUSTOM_HTTPS_PORT | Internal port the container listens on for https if it needs to be swapped from the default 3001. |
| CUSTOM_USER | HTTP Basic auth username, abc is default. |
| PASSWORD | HTTP Basic auth password, abc is default. If unset there will be no auth |
| SUBFOLDER | Subfolder for the application if running a subfolder reverse proxy, need both slashes IE `/subfolder/` |
| TITLE | The page title displayed on the web browser, default "KasmVNC Client". |
| FM_HOME | This is the home directory (landing) for the file manager, default "/config". |
| START_DOCKER | If set to false a container with privilege will not automatically start the DinD Docker setup. |
| DRINODE | If mounting in /dev/dri for [DRI3 GPU Acceleration](https://www.kasmweb.com/kasmvnc/docs/master/gpu_acceleration.html) allows you to specify the device to use IE `/dev/dri/renderD128` |
| DISABLE_IPV6 | If set to true or any value this will disable IPv6 | 
| LC_ALL | Set the Language for the container to run as IE `fr_FR.UTF-8` `ar_AE.UTF-8` |
| NO_DECOR | If set the application will run without window borders in openbox for use as a PWA. |
| NO_FULL | Do not autmatically fullscreen applications when using openbox. |

#### Optional run configurations

| Variable | Description |
| :----: | --- |
| `--privileged` | Will start a Docker in Docker (DinD) setup inside the container to use docker in an isolated environment. For increased performance mount the Docker directory inside the container to the host IE `-v /home/user/docker-data:/var/lib/docker`. |
| `-v /var/run/docker.sock:/var/run/docker.sock` | Mount in the host level Docker socket to either interact with it via CLI or use Docker enabled applications. |
| `--device /dev/dri:/dev/dri` | Mount a GPU into the container, this can be used in conjunction with the `DRINODE` environment variable to leverage a host video card for GPU accelerated applications. Only **Open Source** drivers are supported IE (Intel,AMDGPU,Radeon,ATI,Nouveau) |

### Language Support - Internationalization

The environment variable `LC_ALL` can be used to start this container in a different language than English simply pass for example to launch the Desktop session in French `LC_ALL=fr_FR.UTF-8`. Some languages like Chinese, Japanese, or Korean will be missing fonts needed to render properly known as cjk fonts, but others may exist and not be installed inside the container depending on what underlying distribution you are running. We only ensure fonts for Latin characters are present. Fonts can be installed with a mod on startup.

To install cjk fonts on startup as an example pass the environment variables (Alpine base):

```
-e DOCKER_MODS=linuxserver/mods:universal-package-install 
-e INSTALL_PACKAGES=fonts-noto-cjk
-e LC_ALL=zh_CN.UTF-8
```

The web interface has the option for "IME Input Mode" in Settings which will allow non english characters to be used from a non en_US keyboard on the client. Once enabled it will perform the same as a local Linux installation set to your locale.

### DRI3 GPU Acceleration (KasmVNC interface)

For accelerated apps or games, render devices can be mounted into the container and leveraged by applications using:

`--device /dev/dri:/dev/dri`

This feature only supports **Open Source** GPU drivers:

| Driver | Description |
| :----: | --- |
| Intel | i965 and i915 drivers for Intel iGPU chipsets |
| AMD | AMDGPU, Radeon, and ATI drivers for AMD dedicated or APU chipsets |
| NVIDIA | nouveau2 drivers only, closed source NVIDIA drivers lack DRI3 support |

The `DRINODE` environment variable can be used to point to a specific GPU.
Up to date information can be found [here](https://www.kasmweb.com/kasmvnc/docs/master/gpu_acceleration.html)

### Nvidia GPU Support (KasmVNC interface)

**Nvidia support is not compatible with Alpine based images as Alpine lacks Nvidia drivers**

Nvidia support is available by leveraging Zink for OpenGL support. This can be enabled with the following run flags:

| Variable | Description |
| :----: | --- |
| --gpus all | This can be filtered down but for most setups this will pass the one Nvidia GPU on the system |
| --runtime nvidia | Specify the Nvidia runtime which mounts drivers and tools in from the host |

The compose syntax is slightly different for this as you will need to set nvidia as the default runtime:

```
sudo nvidia-ctk runtime configure --runtime=docker --set-as-default
sudo service docker restart
```

And to assign the GPU in compose:

```
services:
  beeper:
    image: ghcr.io/zachatrocity/docker-beeper:latest
    deploy:
      resources:
        reservations:
          devices:
            - driver: nvidia
              count: 1
              capabilities: [compute,video,graphics,utility]
```

### Application management

#### PRoot Apps

If you run system native installations of software IE `sudo apt-get install filezilla` and then upgrade or destroy/re-create the container that software will be removed and the container will be at a clean state. For some users that will be acceptable and they can update their system packages as well using system native commands like `apt-get upgrade`. If you want Docker to handle upgrading the container and retain your applications and settings we have created [proot-apps](https://github.com/linuxserver/proot-apps) which allow portable applications to be installed to persistent storage in the user's `$HOME` directory and they will work in a confined Docker environment out of the box. These applications and their settings will persist upgrades of the base container and can be mounted into different flavors of KasmVNC based containers on the fly. This can be achieved from the command line with:

```
proot-apps install filezilla
```

PRoot Apps is included in all KasmVNC based containers, a list of supported applications is located [HERE](https://github.com/linuxserver/proot-apps?tab=readme-ov-file#supported-apps).

#### Native Apps

It is possible to install extra packages during container start using [universal-package-install](https://github.com/linuxserver/docker-mods/tree/universal-package-install). It might increase starting time significantly. PRoot is preferred.

```yaml
  environment:
    - DOCKER_MODS=linuxserver/mods:universal-package-install
    - INSTALL_PACKAGES=libfuse2|git|gdb
```

## Usage

To help you get started creating a container from this image you can either use docker-compose or the docker cli.

>[!NOTE]
>Unless a parameter is flaged as 'optional', it is *mandatory* and a value must be provided.

### docker-compose (recommended)

```yaml
---
services:
  beeper:
    image: ghcr.io/zachatrocity/docker-beeper:latest
    container_name: beeper
    environment:
      - PUID=1000
      - PGID=1000
      - TZ=Etc/UTC
      - DARK_MODE=true #optional
      - USE_LEGACY_BIN=false
    volumes:
      - ./config:/config
    ports:
      - 3003:3000
      - 3005:3001
    shm_size: "1gb"
    restart: unless-stopped
```

### docker cli

```bash
docker run -d \
  --name=beeper \
  -e PUID=1000 \
  -e PGID=1000 \
  -e TZ=Etc/UTC \
  -p 3000:3000 \
  -p 3001:3001 \
  -v /path/to/config:/config \
  --device /dev/dri:/dev/dri `#optional` \
  --shm-size="1gb" \
  --restart unless-stopped \
  ghcr.io/zachatrocity/docker-beeper:latest
```

## Parameters

Containers are configured using parameters passed at runtime (such as those above). These parameters are separated by a colon and indicate `<external>:<internal>` respectively. For example, `-p 8080:80` would expose port `80` from inside the container to be accessible from the host's IP on port `8080` outside the container.

| Parameter | Function |
| :----: | --- |
| `-p 3000:3000` | Beeper desktop gui. |
| `-p 3001:3001` | Beeper desktop gui HTTPS. |
| `-e PUID=1000` | for UserID - see below for explanation |
| `-e PGID=1000` | for GroupID - see below for explanation |
| `-e TZ=Etc/UTC` | specify a timezone to use, see this [list](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones#List). |
| `-v /config` | Users home directory in the container, stores program settings and files. |
| `--device /dev/dri` | Add this for GL support (Linux hosts only) |
| `--shm-size=` | This is needed for electron applications to function properly. |
| `--security-opt seccomp=unconfined` | For Docker Engine only, many modern gui apps need this to function on older hosts as syscalls are unknown to Docker. |

## Environment variables from files (Docker secrets)

You can set any environment variable from a file by using a special prepend `FILE__`.

As an example:

```bash
-e FILE__MYVAR=/run/secrets/mysecretvariable
```

Will set the environment variable `MYVAR` based on the contents of the `/run/secrets/mysecretvariable` file.

## Umask for running applications

For all of our images we provide the ability to override the default umask settings for services started within the containers using the optional `-e UMASK=022` setting.
Keep in mind umask is not chmod it subtracts from permissions based on it's value it does not add. Please read up [here](https://en.wikipedia.org/wiki/Umask) before asking for support.

## User / Group Identifiers

When using volumes (`-v` flags), permissions issues can arise between the host OS and the container, we avoid this issue by allowing you to specify the user `PUID` and group `PGID`.

Ensure any volume directories on the host are owned by the same user you specify and any permissions issues will vanish like magic.

In this instance `PUID=1000` and `PGID=1000`, to find yours use `id your_user` as below:

```bash
id your_user
```

Example output:

```text
uid=1000(your_user) gid=1000(your_user) groups=1000(your_user)
```

## Docker Mods

[![Docker Universal Mods](https://img.shields.io/badge/dynamic/yaml?color=94398d&labelColor=555555&logoColor=ffffff&style=for-the-badge&label=universal&query=%24.mods%5B%27universal%27%5D.mod_count&url=https%3A%2F%2Fraw.githubusercontent.com%2Flinuxserver%2Fdocker-mods%2Fmaster%2Fmod-list.yml)](https://mods.linuxserver.io/?mod=universal "view available universal mods.")

We publish various [Docker Mods](https://github.com/linuxserver/docker-mods) to enable additional functionality within the containers. The list of Mods available for this image (if any) as well as universal mods that can be applied to any one of our images can be accessed via the dynamic badges above.

## Support Info

* Shell access whilst the container is running:

    ```bash
    docker exec -it beeper /bin/bash
    ```

* To monitor the logs of the container in realtime:

    ```bash
    docker logs -f beeper
    ```

* Container version number:

    ```bash
    docker inspect -f '{{ index .Config.Labels "build_version" }}' beeper
    ```

* Image version number:

    ```bash
    docker inspect -f '{{ index .Config.Labels "build_version" }}' ghcr.io/zachatrocity/docker-beeper:latest
    ```

## Updating Info

Most of our images are static, versioned, and require an image update and container recreation to update the app inside. With some exceptions (noted in the relevant readme.md), we do not recommend or support updating apps inside the container. Please consult the [Application Setup](#application-setup) section above to see if it is recommended for the image.

Below are the instructions for updating containers:

### Via Docker Compose

* Update images:
    * All images:

        ```bash
        docker-compose pull
        ```

    * Single image:

        ```bash
        docker-compose pull beeper
        ```

* Update containers:
    * All containers:

        ```bash
        docker-compose up -d
        ```

    * Single container:

        ```bash
        docker-compose up -d beeper
        ```

* You can also remove the old dangling images:

    ```bash
    docker image prune
    ```

### Via Docker Run

* Update the image:

    ```bash
    docker pull ghcr.io/zachatrocity/docker-beeper:latest
    ```

* Stop the running container:

    ```bash
    docker stop beeper
    ```

* Delete the container:

    ```bash
    docker rm beeper
    ```

* Recreate a new container with the same docker run parameters as instructed above (if mapped correctly to a host folder, your `/config` folder and settings will be preserved)
* You can also remove the old dangling images:

    ```bash
    docker image prune
    ```

### Image Update Notifications - Diun (Docker Image Update Notifier)

>[!TIP]
>We recommend [Diun](https://crazymax.dev/diun/) for update notifications. Other tools that automatically update containers unattended are not recommended or supported.
