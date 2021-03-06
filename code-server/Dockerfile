ARG BASE_ARCH=amd64

FROM ${BASE_ARCH}/debian:buster-slim AS builder

LABEL maintainer="Eduardo Simoes <eisimoes@yahoo.com>"

WORKDIR /tmp

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=True

RUN echo "**** Setting up repositories ****" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        git \
        golang-go \
    && echo "**** Cloning fixuid repository ****" \
    && git clone https://github.com/boxboat/fixuid.git \
    && cd fixuid \
    && echo "**** Building fixuid" \
    && go build

FROM ${BASE_ARCH}/debian:buster-slim

LABEL maintainer="Eduardo Simoes <eisimoes@yahoo.com>"

ARG DEBIAN_FRONTEND=noninteractive
ARG APT_KEY_DONT_WARN_ON_DANGEROUS_USAGE=True

COPY --from=builder /tmp/fixuid/fixuid /usr/bin/fixuid

RUN echo "**** Setting up repositories ****" \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        ca-certificates \
        gnupg \
        curl \
    && curl -sS https://deb.nodesource.com/gpgkey/nodesource.gpg.key \
        | apt-key add - \
    && echo 'deb https://deb.nodesource.com/node_14.x buster main' \
        > /etc/apt/sources.list.d/nodesource.list \
    && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg \
        | apt-key add - \
    && echo 'deb https://dl.yarnpkg.com/debian/ stable main' \
        > /etc/apt/sources.list.d/yarn.list \
    && echo "**** Installing build dependencies ****" \
    && apt-get update \
    && apt-get install -y \
        build-essential \
        libx11-dev \
        libxkbfile-dev \
        libsecret-1-dev \
        pkg-config \
    && echo "**** Installing packages ****" \
    && apt-get install -y --no-install-recommends \
        dumb-init \
        git \
        iproute2 \
        jq \
        nodejs \
        openssh-client \
        python3 \
        sudo \
        yarn \
    && npm config set python python3 \
    && echo "**** Installing Code Server ****" \
    && yarn --production --frozen-lockfile global add code-server@3.5.0 --unsafe-perm \
    && echo "**** Cleaning up ****" \
    && apt-get purge --auto-remove -y \
        build-essential \
        pkg-config \
        libx11-dev \
        libxkbfile-dev \
        libsecret-1-dev \
    && yarn cache clean \
    && apt-get clean \
    && rm -rf \
        /tmp/* \
        /var/lib/apt/lists/* \
        /var/tmp/* \
    && echo "**** Finishing up configuration ****" \
    && adduser --gecos '' --disabled-password coder \
    && echo "ALL ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers.d/nopasswd \
    && mkdir -p /etc/fixuid \
    && printf "user: coder\ngroup: coder\n" > /etc/fixuid/config.yml \
    && chmod a+s /usr/bin/fixuid

COPY entrypoint.sh /usr/bin/entrypoint.sh

RUN chmod a+x /usr/bin/entrypoint.sh

USER coder

WORKDIR /

EXPOSE 8080/tcp

EXPOSE 8443/tcp

ENV SHELL=/bin/bash

ENTRYPOINT ["/usr/bin/entrypoint.sh"]

CMD ["--bind-addr", "0.0.0.0:8080", "--auth", "none"]
