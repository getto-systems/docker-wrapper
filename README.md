# docker-wrapper

docker wrapper scripts for development


## Usage

### run command

```bash
# mix
#!/bin/bash

. docker-wrapper.sh
. docker-wrapper-image.sh

# variables and defaults
docker_wrapper_hostname=$(hostname) # using host, name prefix
docker_wrapper_user=1000:1000
docker_wrapper_home=$HOME
docker_wrapper_work_dir=$(pwd)
docker_wrapper_volumes=$DOCKER_VOLUMES # DOCKER_VOLUMES="volume:/path/to/volume volume2:/path/to/volume2"
docker_wrapper_shared_volume=shared # if [ $home == $HOME ]; then -v shared:$HOME

docker_wrapper_cmd elixir mix "$@"
```

```bash
$ mix deps.get
$ mix compile MIX_ENV=prod
```

### start/stop server

```bash
# phx
#!/bin/bash

. docker-wrapper.sh
. docker-wrapper-image.sh

# variables and defaults
docker_wrapper_hostname=$(hostname) # using host, name prefix
docker_wrapper_name=$@ # using host, name suffix : default: command arguments
docker_wrapper_user=1000:1000
docker_wrapper_home=$APP_ROOT or /
docker_wrapper_work_dir=$APP_ROOT or /
docker_wrapper_volume=$DOCKER_VOLUMES # DOCKER_VOLUMES="volume:/path/to/volume volume2:/path/to/volume2"
docker_wrapper_ports="" # "80:80 443:443"
docker_wrapper_start_hooks=(
  "-u 1000:1000 -w / -- /path/to/hook"
)

docker_wrapper_server elixir mix phoenix.server -- "$@"
```

```bash
$ phx # start
$ phx start MIX_ENV=dev
$ phx stop
$ phx restart
$ phx logs
$ phx status
$ phx ps
```


## Install

* add `path/to/docker-wrapper/bin` to PATH
* setup docker-wrapper-image.sh

### setup docker-wrapper-image.sh

```bash
# docker-wrapper-image.sh

docker_wrapper_image elixir 1.4.2
```

