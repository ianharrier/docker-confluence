FROM debian:9

#-------------------------------------------------------------------------------
#  AdoptOpenJDK (https://adoptopenjdk.net/releases.html)
#-------------------------------------------------------------------------------

ARG JAVA_VERSION
ARG JAVA_UPDATE
ARG JAVA_BUILD

ENV JAVA_HOME="/usr/java/jdk${JAVA_VERSION}u${JAVA_UPDATE}-b${JAVA_BUILD}-jre"
ENV PATH="${PATH}:${JAVA_HOME}/bin"

RUN set -ex \
        && apt-get update && apt-get -y install \
               curl \
        && mkdir -p "${JAVA_HOME}" \
        && curl --location --retry 3 \
               https://github.com/AdoptOpenJDK/openjdk"${JAVA_VERSION}"-binaries/releases/download/jdk"${JAVA_VERSION}"u"${JAVA_UPDATE}"-b"${JAVA_BUILD}"/OpenJDK"${JAVA_VERSION}"U-jre_x64_linux_hotspot_"${JAVA_VERSION}"u"${JAVA_UPDATE}"b"${JAVA_BUILD}".tar.gz \
             | tar -xz --directory "${JAVA_HOME}" --strip-components=2 --no-same-owner \
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
               fontconfig \
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
        && apt-get update && apt-get -y install \
               gosu \
        && chmod +x /usr/local/bin/docker-entrypoint \
        && rm -rf /var/lib/apt/lists/*

ENTRYPOINT ["docker-entrypoint"]
