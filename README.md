# docker-wrapper

utility for wrap `docker run` command


## Usage

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

#### environment variables

- DOCKER_WRAPPER_IMAGE_{image-name} : docker_wrapper_image ruby -> image-name = ruby
- DOCKER_WRAPPER_VOLUMES : comma separated volume specification : e.g. dotfiles:/home/labo,apps:/apps


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

#### environment variables

- DOCKER_WRAPPER_SERVER_HOSTNAME : --name ${DOCKER_WRAPPER_SERVER_HOSTNAME}-{server-name}
- DOCKER_WRAPPER_SERVER_OPTS_{server-name} : docker_wrapper_server phoenix -> server-name = phoenix
- DOCKER_WRAPPER_IMAGE_{image-name} : docker_wrapper_image elixir -> image-name = elixir
- DOCKER_WRAPPER_VOLUMES : comma separated volume specification : e.g. dotfiles:/home/labo,apps:/apps


## Utility

### docker_wrapper_envs

- all env vars in current env
- without DOCKER_WRAPPER_EXCLUDE_ENVS (default: PATH,LANG)


### docker_wrapper_tty

```bash
$(docker_wrapper_tty) # => -it -detach-keys ctrl-@,ctrl-@ # if [ -t 1 ]
```

### docker_wrapper_volumes

```bash
DOCKER_WRAPPER_VOLUMES=volume:/path/to/volume,volume2:/path/to/volume2
$(docker_wrapper_volumes) # => -v volume:/path/to/volume -v volume2:/path/to/volume2
```

### docker_wrapper_image

```bash
DOCKER_WRAPPER_IMAGE_ruby=2.4.1
$(docker_wrapper_image ruby) => ruby:2.4.1
```

### docker_wrapper_server

```
DOCKER_WRAPPER_SERVER_OPTS_phoenix=-p 4000:4000
docker_wrapper_server phoenix
if [ "$docker_wrapper_server_cmd" == start ]; then
  ${docker_wrapper_envs[@]} # => -p 4000:4000 ( and many other envs )
fi
```

