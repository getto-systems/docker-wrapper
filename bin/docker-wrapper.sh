#!/bin/bash

declare -A docker_wrapper_images
declare -a docker_wrapper_image_names

docker_wrapper_image(){
  docker_wrapper_images[$1]=$2
  docker_wrapper_image_names[${#docker_wrapper_image_names[@]}]="$1:$2"
}


docker_wrapper_cmd(){
  local image
  local image_tag
  local volume
  local no_alt_args
  local -a opts
  local -a args
  local -a envs

  : ${docker_wrapper_hostname:=$(hostname)}
  : ${docker_wrapper_name:=}
  : ${docker_wrapper_user:=1000:1000}
  : ${docker_wrapper_home:=$HOME}
  : ${docker_wrapper_work_dir:=$(pwd)}
  : ${docker_wrapper_volumes:=$DOCKER_VOLUMES}
  : ${docker_wrapper_shared_volume:=shared}

  no_alt_args=1
  docker_wrapper_parse_args "$@"

  : ${docker_wrapper_name:=${args[0]}}
  docker_wrapper_opts -h $(docker_wrapper_name $docker_wrapper_hostname-$docker_wrapper_name)
  docker_wrapper_opts -u $docker_wrapper_user
  docker_wrapper_opts -e HOME=$docker_wrapper_home
  docker_wrapper_opts -w $docker_wrapper_work_dir

  if [ -n "$docker_wrapper_volumes" ]; then
    for volume in $docker_wrapper_volumes; do
      docker_wrapper_opts -v $volume
    done
  fi
  if [ $docker_wrapper_home == $HOME ]; then
    docker_wrapper_opts -v $docker_wrapper_shared_volume:$docker_wrapper_home
  fi

  if [ -t 1 ]; then
    docker_wrapper_opts -it --detach-keys ctrl-@,ctrl-@
  fi

  docker_wrapper_opts --rm

  docker_wrapper_run
}

docker_wrapper_server(){
  local image
  local image_tag
  local name
  local volume
  local port
  local -a opts
  local -a args
  local -a alt_args
  local -a envs
  local mode

  : ${docker_wrapper_hostname:=$(hostname)}
  : ${docker_wrapper_name:=}
  : ${docker_wrapper_user:=1000:1000}
  : ${docker_wrapper_home:=$HOME}
  : ${docker_wrapper_work_dir:=$APP_ROOT}
  : ${docker_wrapper_work_dir:=/}
  : ${docker_wrapper_volumes:=$DOCKER_VOLUMES}
  : ${docker_wrapper_ports:=}
  : ${docker_wrapper_start_hooks:=}
  : ${docker_wrapper_shared_volume:=shared}

  docker_wrapper_parse_args "$@"

  : ${docker_wrapper_name:=${args[@]}}
  name=$(docker_wrapper_name "$docker_wrapper_hostname-$docker_wrapper_name")

  docker_wrapper_opts --name $name
  docker_wrapper_opts -h $name
  docker_wrapper_opts -u $docker_wrapper_user
  docker_wrapper_opts -e HOME=$docker_wrapper_home
  docker_wrapper_opts -w $docker_wrapper_work_dir

  if [ -n "$docker_wrapper_volumes" ]; then
    for volume in $docker_wrapper_volumes; do
      docker_wrapper_opts -v $volume
    done
  fi
  if [ $docker_wrapper_home == $HOME ]; then
    docker_wrapper_opts -v $docker_wrapper_shared_volume:$docker_wrapper_home
  fi
  if [ -n "$docker_wrapper_ports" ]; then
    for port in $docker_wrapper_ports; do
      docker_wrapper_opts -p $port
    done
  fi

  docker_wrapper_opts -d

  if [ ${#alt_args[@]} -eq 0 ]; then
    mode=start
  else
    mode=${alt_args[0]}
  fi

  case "$mode" in
    start)
      docker_wrapper_start
      ;;
    stop)
      docker_wrapper_purge
      ;;
    restart)
      docker_wrapper_purge
      docker_wrapper_start
      ;;
    logs)
      docker_wrapper_logs
      ;;
    status)
      docker_wrapper_status
      ;;
    ps)
      docker_wrapper_ps -a
      ;;
    *)
      echo "unknown option '$mode'"
      echo
      echo "available options:"
      echo "  status : check for running"
      echo "  start : start server if not running"
      echo "  stop : stop server if running"
      echo "  restart : stop and start server"
      echo "  logs : show server logs"
      echo "  status : check for running"
      echo "  ps : show docker ps"
      exit 1
      ;;
  esac
}

docker_wrapper_parse_args(){
  local image_name

  image=$1
  shift

  image_tag=${docker_wrapper_images["$image"]}
  if [ -z "$image_tag" ]; then
    echo "image not found for '$image'"
    for image_name in ${docker_wrapper_image_names[@]}; do
      echo $image_name
    done
    exit 1
  fi

  docker_wrapper_parse_alt_args args "$@"
}
docker_wrapper_parse_alt_args(){
  local mode
  local next_mode
  mode=$1
  shift

  while [ $# -gt 0 ]; do
    case "$1" in
      --)
        shift
        if [ $mode == args ]; then
          if [ -n "$no_alt_args" ]; then
            next_mode=args
          else
            next_mode=alt_args
          fi
        else
          next_mode=args
        fi
        docker_wrapper_parse_alt_args $next_mode "$@"
        break
        ;;
      -*)
        args[${#args[@]}]=$1
        ;;
      *=*)
        envs[${#envs[@]}]="-e $1"
        ;;
      *)
        if [ $mode == args ]; then
          args[${#args[@]}]=$1
        else
          alt_args[${#alt_args[@]}]=$1
        fi
        ;;
    esac
    shift
  done
}
docker_wrapper_opts(){
  while [ $# -gt 0 ]; do
    opts[${#opts[@]}]=$1; shift
  done
}

docker_wrapper_name(){
  echo $@ | sed -e "s/[^[:alnum:]]\+/-/g"
}

docker_wrapper_run(){
  docker run "${opts[@]}" "${envs[@]}" $image:$image_tag "${args[@]}"
}

docker_wrapper_start(){
  if [ -z "$(docker_wrapper_is_running -a)" ]; then
    echo "run..."
    docker_wrapper_run
    docker_wrapper_start_hook "${docker_wrapper_start_hooks[@]}"
  else
    docker_wrapper_status_container_exists
  fi
}
docker_wrapper_purge(){
  if [ -z "$(docker_wrapper_is_running -a)" ]; then
    docker_wrapper_status_not_running
  else
    echo "stop..."
    docker stop $name
    echo "rm..."
    docker rm $name
  fi
}
docker_wrapper_logs(){
  if [ -n "$(docker_wrapper_is_running -a)" ]; then
    docker logs $name
  else
    docker_wrapper_status_not_running
  fi
}

docker_wrapper_status(){
  if [ -z "$(docker_wrapper_is_running -a)" ]; then
    docker_wrapper_status_not_running
  else
    docker_wrapper_status_container_exists
  fi
}
docker_wrapper_status_not_running(){
  echo not running.
}
docker_wrapper_status_container_exists(){
  if [ -n "$(docker_wrapper_is_running)" ]; then
    echo already running.
  else
    echo error exited.
  fi
}

docker_wrapper_ps(){
  docker ps -f name=$name "$@"
}
docker_wrapper_is_running(){
  docker_wrapper_ps --format "{{.ID}}" "$@"
}

docker_wrapper_start_hook(){
  local arg
  local -a args
  local -a alt_args
  local -a envs

  while [ $# -gt 0 ]; do
    arg=$1; shift
    if [ -n "$arg" ]; then
      docker_wrapper_parse_alt_args args $arg
      docker exec "${args[@]}" "${envs[@]}" $name "${alt_args[@]}"
    fi
  done
}
