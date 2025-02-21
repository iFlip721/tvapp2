# syntax=docker/dockerfile:1

# #
#   @project        TVApp2
#   @usage          docker image which allows you to download a m3u playlist and EPG guide data from
#                   multiple IPTV services.
#   @file           Dockerfile
#   @repo           https://github.com/iFlip721/tvapp2
#                   https://github.com/aetherinox/tvapp2
#                   https://github.com/aetherinox/docker-base-alpine
#                   https://git.binaryninja.net/pub_projects/tvapp2
#
#   you can build your own image by running
#       amd64       docker build --build-arg VERSION=1.0.0 --build-arg BUILDDATE=20250218 -t tvapp2:latest -t tvapp2:1.0.0 -t tvapp2:1.0.0-amd64 -f Dockerfile .
#       arm64       docker build --build-arg VERSION=1.0.0 --build-arg BUILDDATE=20250218 -t tvapp2:1.0.0-arm64 -f Dockerfile.aarch64 .
#
#   if you prefer to use `docker buildx`
#       create      docker buildx create --driver docker-container --name container --bootstrap --use
#       amd64       docker buildx build --no-cache --pull --build-arg VERSION=1.0.0 --build-arg BUILDDATE=20250218 -t tvapp2:latest -t tvapp2:1.0.0 --platform=linux/amd64 --output type=docker --output type=docker .
#       arm64       docker buildx build --no-cache --pull --build-arg VERSION=1.0.0 --build-arg BUILDDATE=20250218 -t tvapp2:latest -t tvapp2:1.0.0 --platform=linux/arm64 --output type=docker --output type=docker .
# #


FROM ghcr.io/aetherinox/alpine-base:3.20-amd64

# #
#   Set Args
# #

ARG BUILDDATE
ARG VERSION

# #
#   Set Labels
# #

LABEL maintainer="aetherinox, iFlip721"
LABEL org.opencontainers.image.authors="aetherinox, iFlip721"
LABEL org.opencontainers.image.vendor="BinaryNinja"
LABEL org.opencontainers.image.title="TVApp2"
LABEL org.opencontainers.image.description="Automatic m3u and xml guide updater for TheTvApp, TVPass, and MoveOnJoy utilized within your IPTV client."
LABEL org.opencontainers.image.source="https://git.binaryninja.net/pub_projects/tvapp2"
LABEL org.opencontainers.image.repo.1="https://github.com/iFlip721/tvapp2"
LABEL org.opencontainers.image.repo.2="https://github.com/Aetherinox/tvapp2"
LABEL org.opencontainers.image.repo.3="https://git.binaryninja.net/pub_projects/tvapp2"
LABEL org.opencontainers.image.documentation="https://git.binaryninja.net/pub_projects/tvapp2/wiki"
LABEL org.opencontainers.image.url="https://github.com/Aetherinox/tvapp2/pkgs/container/tvapp2"
LABEL org.opencontainers.image.licenses="MIT"
LABEL BUILDVERSION="TVApp2 v${VERSION} Build ${BUILDDATE}"

# #
#   Set Env Var
# #

ENV TZ="Etc/UTC"
ENV URL_REPO_BASE="https://github.com/aetherinox/alpine-base/pkgs/container/alpine-base"
ENV URL_REPO_APP="https://git.binaryninja.net/pub_projects/tvapp2"
ENV FILE_NAME="index.html"
ENV PORT_HTTP=4124
ENV NODE_VERSION=18.20.5
ENV YARN_VERSION=1.22.22

# #
#   Install
# #

RUN \
    apk add --no-cache \
        wget \
        bash \
        nano \
        npm \
        openssl

# #
#   Copy docker-entrypoint
# #

COPY docker-entrypoint.sh /usr/local/bin/

# #
#   Set work directory
# #

WORKDIR /usr/src/app

# #
#   copy node package.json to workdir
# #

COPY package*.json ./

# #
#   install node (production)
# #

RUN npm install --only=production

# #
#   Add local files
# #

COPY . .
# COPY node_modules/ package.json package-lock.json formatted.dat index.js ./

# #
#   when copying with the command above, all files in root folder will be copied.
# #

RUN rm -rf ./root
RUN rm ./Dockerfile ./Dockerfile.aarch64 docker-entrypoint.sh

# #
#   copy s6-overlays root to image root
# #

COPY root/ /

# #
#   Ports and volumes
# #

EXPOSE ${PORT_HTTP}/tcp

# #
#   In case user sets up the cron for a longer duration, do a first run
#   and then keep the container running. Hacky, but whatever.
# #

CMD ["sh", "-c", "npm start"]
