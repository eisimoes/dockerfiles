#!/bin/bash

set -e

if [[ ! $(whoami 2> /dev/null) ]]; then
    fixuid -q > /dev/null
fi

if [[ "$TZ" ]]; then
    echo "$TZ" | sudo tee /etc/timezone
    sudo dpkg-reconfigure --frontend noninteractive tzdata > /dev/null 2> /dev/null
fi

export USER="$(whoami)"

if [[ -d "/home/$(eval echo ~$USER)" ]]; then
    export HOME="$(eval echo ~$USER)"
    cd "$HOME"
fi

echo "$USER ALL=(ALL) NOPASSWD:ALL" | sudo tee -a /etc/sudoers.d/nopasswd > /dev/null

sudo sed -i "/^ALL/d" /etc/sudoers.d/nopasswd

exec dumb-init /usr/local/bin/code-server "$@"
