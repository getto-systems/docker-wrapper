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

docker_wrapper_port phoenix 4000:4000
```

* put docker-wrapper.rc.sh in anywhere under $PATH
