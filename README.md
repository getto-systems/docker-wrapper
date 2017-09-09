# docker-wrapper

utility for wrap `docker run` command


## Usage

```bash
. docker-wrapper.sh
```

### image

```bash
DOCKER_WRAPPER_IMAGE_ruby=2.4.1
$(docker_wrapper_image ruby) # => ruby:2.4.1
```

```bash
DOCKER_WRAPPER_IMAGE_ruby=my/image:2.4.1
$(docker_wrapper_image ruby) # => my/image:2.4.1
```

### volumes

```bash
DOCKER_WRAPPER_VOLUMES=dotfiles:/home/labo,apps:/apps
$(docker_wrapper_volumes) # => -v dotfiles:/home/labo -v apps:/apps
```

### envs

```bash
${docker_wrapper_envs[@]} # => -e ... ( all env vars in current env )
```

```bash
ENV_FILES=my.env,other.env
${docker_wrapper_envs[@]} # => --env-file my.env --env-file other.env
```

### server envs

```bash
DOCKER_WRAPPER_SERVER_OPTS_phoenix=-p 4000:4000
docker_wrapper_server phoenix
${docker_wrapper_envs[@]} # => -p 4000:4000
```

### server hostname

```bash
DOCKER_WRAPPER_SERVER_HOSTNAME=myhost
docker_wrapper_server phoenix
$(docker_wrapper_server_name) # => --name myhost-phoenix --host myhost-phoenix
```

### tty

```bash
$(docker_wrapper_tty) # => -it -detach-keys ctrl-@,ctrl-@ # if [ -t 1 ]
```

## Environment variables

### DOCKER_WRAPPER_EXCLUDE_ENVS : PATH,LANG

list of env-name that don't take over to docker from current-env

### DOCKER_WRAPPER_VOLUMES

list of volume-spec

### DOCKER_WRAPPER_IMAGE_image-name

specify image-name's image

### DOCKER_WRAPPER_SERVER_HOSTNAME_server-name

specify server-name's hostname

### DOCKER_WRAPPER_SERVER_OPTS_server-name

specify server-name's additional options


## Examples

- [docker-wrapper-commands](https://github.com/getto-systems/docker-wrapper-commands)

### command-line tool

```bash
#!/bin/bash
. docker-wrapper.sh
docker run \
  --rm \
  -u 1000:1000 \
  -w $(pwd) \
  $(docker_wrapper_tty) \
  $(docker_wrapper_volumes) \
  "${docker_wrapper_envs[@]}" \
  $(docker_wrapper_image ruby) \
  ruby "$@" \
;
```

### server

```bash
#!/bin/bash
. docker-wrapper.sh
docker_wrapper_server phoenix "$@"
if [ "$docker_wrapper_server_cmd" == start ]; then
  docker run \
    -d \
    -u 1000:1000 \
    -w $APP_ROOT \
    $(docker_wrapper_server_name) \
    $(docker_wrapper_volumes) \
    "${docker_wrapper_envs[@]}" \
    $(docker_wrapper_image elixir) \
    mix phoenix.server \
  ;
fi
```
