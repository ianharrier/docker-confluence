FROM alpine

MAINTAINER Ian Harrier <github@harrier.us>

#-------------------------------------------------------------------------------
#  Docker
#-------------------------------------------------------------------------------

RUN set -ex \
        && apk --no-cache add \
               docker

#-------------------------------------------------------------------------------
#  Docker Compose (https://github.com/docker/compose)
#-------------------------------------------------------------------------------

ARG COMPOSE_VERSION

RUN set -ex \
        && apk --no-cache add \
               bash \
               curl \
        && curl --location \
               --output /usr/local/bin/docker-compose \
               https://github.com/docker/compose/releases/download/"${COMPOSE_VERSION}"/run.sh \
        && chmod +x /usr/local/bin/docker-compose \
        && apk --no-cache del \
               curl

#-------------------------------------------------------------------------------
#  Scripts
#-------------------------------------------------------------------------------

COPY app-backup.sh /usr/local/bin/app-backup
COPY app-restore.sh /usr/local/bin/app-restore
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN set -ex \
        && chmod +x /usr/local/bin/app-backup \
        && chmod +x /usr/local/bin/app-restore \
        && chmod +x /usr/local/bin/docker-entrypoint \
        && apk --no-cache add \
               tzdata

CMD ["crond","-f","-L","/dev/stdout"]

ENTRYPOINT ["docker-entrypoint"]
