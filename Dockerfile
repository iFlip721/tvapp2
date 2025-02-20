# syntax=docker/dockerfile:1

# #
#   @project        tvapp2
#   @usage          docker image which allows you to download a m3u playlist and EPG guide data for the
#                   IPTV service TheTvApp.
#   @file           Dockerfile
#   @repo           https://github.com/aetherinox/docker-base-alpine
#                   https://git.binaryninja.net/pub_projects/tvapp2
#
#   you can build your own image by running
#       amd64       docker build --build-arg VERSION=1.0.0 --build-arg BUILD_DATE=20250218 -t tvapp2:latest -t tvapp2:1.0.0 -t tvapp2:1.0.0-amd64 -f Dockerfile .
#       arm64       docker build --build-arg VERSION=1.0.0 --build-arg BUILD_DATE=20250218 -t tvapp2:1.0.0-arm64 -f Dockerfile.aarch64 .
#   
#   if you prefer to use `docker buildx`
#       create      docker buildx create --driver docker-container --name container --bootstrap --use
#       amd64       docker buildx build --no-cache --pull --build-arg VERSION=1.0.0 --build-arg BUILD_DATE=20250218 -t tvapp2:latest -t tvapp2:1.0.0 --platform=linux/amd64 --output type=docker --output type=docker .
#       arm64       docker buildx build --no-cache --pull --build-arg VERSION=1.0.0 --build-arg BUILD_DATE=20250218 -t tvapp2:latest -t tvapp2:1.0.0 --platform=linux/arm64 --output type=docker --output type=docker .
# #


FROM ghcr.io/aetherinox/alpine-base:3.20-amd64

# #
#   Set Args
# #

ARG BUILD_DATE
ARG VERSION
ARG NGINX_VERSION

# #
#   Set Labels
# #

LABEL maintainer="aetherinox, iFlip721"
LABEL org.opencontainers.image.authors="aetherinox, iFlip721"
LABEL org.opencontainers.image.vendor="BinaryNinja"
LABEL org.opencontainers.image.title="TvApp m3u playlist and EPG guide downloader"
LABEL org.opencontainers.image.description="Download m3u playlist and EPG guide data for the IPTV service TheTVApp"
LABEL org.opencontainers.image.source="https://git.binaryninja.net/pub_projects/tvapp2"
LABEL org.opencontainers.image.documentation="https://git.binaryninja.net/pub_projects/tvapp2/wiki"
LABEL org.opencontainers.image.url="https://git.binaryninja.net/pub_projects/tvapp2/packages"
LABEL org.opencontainers.image.licenses="MIT"
LABEL build_version="TvApp2 v${VERSION} build-date: ${BUILD_DATE}"

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

#RUN echo -e "http://nl.alpinelinux.org/alpine/v3.20/main\nhttp://nl.alpinelinux.org/alpine/v3.20/community" > /etc/apk/repositories
#RUN sed -ie "s/https/http/g" /etc/apk/repositories
RUN \
    apk add --no-cache \
        wget \
        bash \
        npm \
        openssl

# #
#   Copy docker-entrypoint
# #

COPY docker-entrypoint.sh /usr/local/bin/

# #
#   entrypoint
# #

#ENTRYPOINT ["docker-entrypoint.sh"]

CMD ["node"]

# #
#   Set work directory
# #

WORKDIR /usr/src/app
#WORKDIR /config/www

COPY package*.json ./
RUN npm install

# #
#   Add local files
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

# CMD ["sh", "-c", "/run.sh ; /task.sh ; tail -f /dev/null"]
