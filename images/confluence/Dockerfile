FROM debian:9

#-------------------------------------------------------------------------------
#  Oracle Server JRE (http://www.oracle.com/technetwork/java/javase/downloads)
#-------------------------------------------------------------------------------

ARG JAVA_VERSION
ARG JAVA_UPDATE
ARG JAVA_BUILD
ARG JAVA_SIG

ENV JAVA_HOME="/usr/java/server-jre-${JAVA_VERSION}u${JAVA_UPDATE}"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

RUN set -ex \
        && apt-get update && apt-get -y install \
               curl \
        && mkdir -p "${JAVA_HOME}" \
        && curl --location --retry 3 --header "Cookie: oraclelicense=accept-securebackup-cookie;" \
               http://download.oracle.com/otn-pub/java/jdk/"${JAVA_VERSION}"u"${JAVA_UPDATE}"-b"${JAVA_BUILD}"/"${JAVA_SIG}"/server-jre-"${JAVA_VERSION}"u"${JAVA_UPDATE}"-linux-x64.tar.gz \
             | tar -xz --directory "${JAVA_HOME}" --strip-components=1 --no-same-owner \
        && apt-get -y purge --auto-remove \
               curl \
        && rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------------------------------
#  gosu (https://github.com/tianon/gosu)
#-------------------------------------------------------------------------------

ARG GOSU_VERSION

RUN set -ex \
        && apt-get update && apt-get -y install \
               curl \
        && curl --location --retry 3 \
               --output /usr/local/bin/gosu \
               https://github.com/tianon/gosu/releases/download/"${GOSU_VERSION}"/gosu-"$(dpkg --print-architecture)" \
        && chmod +x /usr/local/bin/gosu \
        && gosu nobody true \
        && apt-get -y purge --auto-remove \
               curl \
        && rm -rf /var/lib/apt/lists/*

#-------------------------------------------------------------------------------
#  Confluence (https://www.atlassian.com/software/confluence/download)
#-------------------------------------------------------------------------------

ARG CONFLUENCE_VERSION

ENV CONFLUENCE_HOME=/var/atlassian/application-data/confluence
ENV CONFLUENCE_INSTALL=/opt/atlassian/confluence
ENV RUN_USER=daemon
ENV RUN_GROUP=daemon

RUN set -ex \
        && apt-get update && apt-get -y install \
               curl \
        && mkdir -p                           "${CONFLUENCE_INSTALL}" \
        && curl --location --retry 3 \
               https://www.atlassian.com/software/confluence/downloads/binary/atlassian-confluence-"${CONFLUENCE_VERSION}".tar.gz \
             | tar -xz --directory "${CONFLUENCE_INSTALL}" --strip-components=1 --no-same-owner \
        && chmod -R u=rwx,go-rwx              "${CONFLUENCE_INSTALL}" \
        && chown -R ${RUN_USER}:${RUN_GROUP}  "${CONFLUENCE_INSTALL}" \
        && mkdir -p                           "${CONFLUENCE_HOME}" \
        && chown -R ${RUN_USER}:${RUN_GROUP}  "${CONFLUENCE_HOME}" \
        && chmod -R u=rwx,go-rwx              "${CONFLUENCE_HOME}" \
        && echo -e "\nconfluence.home=${CONFLUENCE_HOME}" >> "${CONFLUENCE_INSTALL}/confluence/WEB-INF/classes/confluence-init.properties" \
        && apt-get -y purge --auto-remove \
               curl \
        && rm -rf /var/lib/apt/lists/*

EXPOSE 8090

VOLUME ["${CONFLUENCE_HOME}"]

WORKDIR ${CONFLUENCE_INSTALL}

CMD ["./bin/catalina.sh","run"]

#-------------------------------------------------------------------------------
#  Scripts
#-------------------------------------------------------------------------------

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint

RUN set -ex \
        && chmod +x /usr/local/bin/docker-entrypoint

ENTRYPOINT ["docker-entrypoint"]
