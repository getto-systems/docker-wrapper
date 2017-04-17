# docker-wrapper

docker wrapper scripts for development


## Command-Line Wrapper

* aws
* certbot-manual : [GitHub](https://github.com/getto-systems/certbot-manual)
* elm
* elx : elixir
* gcloud
* iex
* mix
* node : run command in node container
* npm

### Pass Env Vars

```
mix compile MIX_ENV=prod
```


## Server Wrapper

* labo.shun : [GitHub](https://github.com/shun-getto-systems/labo)
* lr : npm run livereload
* phx : elixir phoenix server

### Commands

```
phx start
```

* start : default
* stop
* restart
* logs
* status
* ps


## Env Vars

* `DOCKER_WRAPPER_VOLUMES` : "volume:/path/to/volume volume2:/path/to/volume2"
* `DOCKER_WRAPPER_SERVER_HOSTNAME` : use in `docker_wrapper_server`


## Install

* setup path
* setup docker-wrapper.rc.sh

### setup path

```
export PATH=/path/to/docker-wrapper/bin:$PATH
```

### setup docker-wrapper.rc.sh

```
# docker-wrapper.rc.sh

docker_wrapper_map elixir 1.4.2

docker_wrapper_server_env_phoenix(){
  docker_wrapper_env -p 4000:4000
}
```

* put docker-wrapper.rc.sh in anywhere under $PATH


## Utility

### docker_wrapper_args, docker_wrapper_envs

```
# $@ <= "cmd" "arg1" "arg2" "ENV1=VAL1" "ENV2=VAL2"
${docker_wrapper_args[@]} => "cmd" "arg1" "arg2"
${docker_wrapper_envs[@]} => "-eENV1=VAL1" "-eENV2=VAL2"
```

* init on load docker-wrapper.sh

### docker_wrapper_home

```
$(docker_wrapper_home) => "-e" "HOME=$HOME" "-v" "dotfiles:$HOME/.dotfiles"
```

### docker_wrapper_tty

```
$(docker_wrapper_tty) => "-it" "-detach-keys" "ctrl-@,ctrl-@"
```

* `if [ -t 1 ]`, docker_wrapper_tty echo options above

### docker_wrapper_volumes

```
# $DOCKER_WRAPPER_VOLUMES <= "volume:/path/to/volume volume2:/path/to/volume2"
$(docker_wrapper_volumes) => "-v volume:/path/to/volume" "-v volume2:/path/to/volume2"
```

### docker_wrapper_image

```
docker_wrapper_map elixir 1.4.2
$(docker_wrapper_image elixir) => "elixir:1.4.2"
```

### docker_wrapper_server

```
docker_wrapper_server phoenix
if [ "$docker_wrapper_server_cmd" == start ]; then
  docker run ...
fi
```

### docker_wrapper_server_env_${service}

```
docker_wrapper_server_env_phoenix(){
  # setup server env vars
  docker_wrapper_env ...
}
```

