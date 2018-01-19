#!/bin/sh
set -e

if [ "$TIMEZONE" ]; then
    echo "[I] Setting the time zone."
    ln -sf "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
    echo "$TIMEZONE" > /etc/timezone
fi

if [ "$PROXY_HOSTNAME" -a "$PROXY_PORT" -a "$PROXY_SCHEME" ]; then
    PROXY_STRING="proxyName=\"$PROXY_HOSTNAME\" proxyPort=\"$PROXY_PORT\" scheme=\"$PROXY_SCHEME\""
    if [ ! "$(cat ${CONFLUENCE_INSTALL}/conf/server.xml | grep "<Connector $PROXY_STRING")" ]; then
        echo "[I] Configuring Catalina to operate behind a reverse proxy."
        sed -i "s/\(<Connector\)/\1 $PROXY_STRING/" ${CONFLUENCE_INSTALL}/conf/server.xml
    fi
fi

echo "[I] Setting permissions on Confluence home directory."
chown -R ${RUN_USER}:${RUN_GROUP}  "${CONFLUENCE_HOME}"
chmod -R u=rwx,go-rwx              "${CONFLUENCE_HOME}"

if [ -e ${CONFLUENCE_INSTALL}/temp/synchrony.pid ]; then
    echo "[I] Removing synchrony.pid file from previous run."
    rm ${CONFLUENCE_INSTALL}/temp/synchrony.pid
fi

echo "[I] Entrypoint tasks complete. Starting Confluence."
exec gosu ${RUN_USER} "$@"
