#!/bin/sh
set -e

START_TIME=$(date +%s)

echo "=== Shutting down web container. ==============================================="
docker-compose stop web

# The backup process will fail if the db container is not started.

echo "=== Starting backup container. ================================================="
docker-compose up -d backup

echo "=== Backing up application stack. =============================================="
docker-compose exec backup app-backup

echo "=== Removing currnet application stack. ========================================"
docker-compose down

echo "=== Pulling changes from repo. ================================================="
git pull

echo "=== Updating environment file. ================================================="
OLD_CONFLUENCE_VERSION=$(grep ^CONFLUENCE_VERSION= .env | cut -d = -f 2)
NEW_CONFLUENCE_VERSION=$(grep ^CONFLUENCE_VERSION= .env.template | cut -d = -f 2)
echo "[I] Upgrading Confluence from '$OLD_CONFLUENCE_VERSION' to '$NEW_CONFLUENCE_VERSION'."
sed -i.bak "s/^CONFLUENCE_VERSION=.*/CONFLUENCE_VERSION=$NEW_CONFLUENCE_VERSION/g" .env

echo "=== Deleting old images. ======================================================="
IMAGE_BACKUP=$(docker images ianharrier/confluence-backup -q)
IMAGE_WEB=$(docker images ianharrier/confluence -q)
docker rmi $IMAGE_BACKUP $IMAGE_WEB

echo "=== Building new images. ======================================================="
docker-compose build --pull

echo "=== Pulling updated database image. ============================================"
docker-compose pull db

echo "=== Starting backup container. ================================================="
docker-compose up -d backup

echo "=== Restoring application stack to most recent backup. ========================="
cd backups
LATEST_BACKUP=$(ls -1tr *.tar.gz 2> /dev/null | tail -n 1)
cd ..
docker-compose exec backup app-restore $LATEST_BACKUP

END_TIME=$(date +%s)

echo "=== Upgrade complete. =========================================================="
echo "[I] Time elapsed: $((END_TIME-START_TIME)) seconds."
