#!/usr/bin/env bash

set -ex
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

WORKSPACE=$(pwd)

XSOCK=/tmp/.X11-unix
XAUTH=/tmp/.docker.xauth
xauth nlist :0 | sed -e 's/^..../ffff/' | xauth -f $XAUTH nmerge -
ARGUMENTS=$@

if test -t 0; then
    DOCKER_INTERACTIVE=-ti
fi

export FLOW_HOME="/OpenROAD-flow-scripts/flow/"
export MAKEFILES="$FLOW_HOME/Makefile"
export DESIGN_CONFIG="$WORKSPACE/$CONFIG"
export WORKSPACE_ORIGIN=$(dirname $(realpath $WORKSPACE/WORKSPACE))

# Most of these options below has to do with allowing to
# run the OpenROAD GUI from within Docker.
docker run -u $(id -u ${USER}):$(id -g ${USER}) \
 -e LIBGL_ALWAYS_SOFTWARE=1 \
 -e "QT_X11_NO_MITSHM=1" \
 -e XDG_RUNTIME_DIR=/tmp/xdg-run \
 -e DISPLAY=$DISPLAY \
 -e QT_XKB_CONFIG_ROOT=/usr/share/X11/xkb \
 -e XAUTHORITY=$XAUTH \
 -e BUILD_DIR=$WORKSPACE \
 -e FLOW_HOME=$FLOW_HOME \
 -e MAKE_PATTERN=$MAKE_PATTERN \
 -e MAKEFILES=$MAKEFILES \
 -e DESIGN_CONFIG=$DESIGN_CONFIG \
 -e WORK_HOME=$WORKSPACE/$RULEDIR \
 -v $WORKSPACE:$WORKSPACE \
 -v $WORKSPACE_ORIGIN:$WORKSPACE_ORIGIN \
 --network host \
 $DOCKER_INTERACTIVE \
 ${OR_IMAGE:-openroad/flow-ubuntu22.04-builder:latest} \
 bash -c \
 "set -ex
 . ./env.sh
 cd \$FLOW_HOME
 $ARGUMENTS
 "
