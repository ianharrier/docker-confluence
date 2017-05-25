#!/bin/sh
set -e

# This script modifies itself after successfully preforming tasks, preventing
# the tasks from running every time the container is restarted.
PERMISSIONS_COMPLETE=false
PROXY_COMPLETE=false
TIMEZONE_COMPLETE=false

if [ "$PERMISSIONS_COMPLETE" = "false" ]; then
    echo "[I] Setting permissions on Confluence home directory."
    chmod -R 700                       "$CONFLUENCE_HOME"
    chown -R ${RUN_USER}:${RUN_GROUP}  "$CONFLUENCE_HOME"
    sed -i 's/^PERMISSIONS_COMPLETE=.*/PERMISSIONS_COMPLETE=true/g' /usr/local/bin/docker-entrypoint
fi

if [ "$PROXY_COMPLETE" = "false" ]; then
    if [ "$PROXY_HOSTNAME" -a "$PROXY_PORT" -a "$PROXY_SCHEME" ]; then
        echo "[I] Configuring Catalina to operate behind a reverse proxy."
        sed -i "s/\(<Connector\)/\1 proxyName=\"$PROXY_HOSTNAME\" proxyPort=\"$PROXY_PORT\" scheme=\"$PROXY_SCHEME\"/" /opt/atlassian/confluence/conf/server.xml
    fi
    sed -i 's/^PROXY_COMPLETE=.*/PROXY_COMPLETE=true/g' /usr/local/bin/docker-entrypoint
fi

if [ "$TIMEZONE_COMPLETE" = "false" ]; then
    if [ "$TIMEZONE" ]; then
        echo "[I] Setting the time zone."
        cp "/usr/share/zoneinfo/$TIMEZONE" /etc/localtime
        echo "$TIMEZONE" > /etc/timezone
    fi
    sed -i 's/^TIMEZONE_COMPLETE=.*/TIMEZONE_COMPLETE=true/g' /usr/local/bin/docker-entrypoint
fi

echo "[I] Entrypoint tasks complete. Starting Confluence."
exec gosu ${RUN_USER} "$@"
