#!/bin/bash

# Configuration variables
MYSQL_ROOT_PASSWORD="password"
MYSQL_DATABASE="zabbix"
MYSQL_USER="zabbix"
MYSQL_PASSWORD="password"
NETWORK_NAME="zabbix-network"
MYSQL_CONTAINER_NAME="mysql-server"
ZABBIX_SERVER_CONTAINER_NAME="zabbix-server-mysql"
ZABBIX_WEB_CONTAINER_NAME="zabbix-web-nginx-mysql"

# Function to log messages
log() {
  echo "$(date +"%Y-%m-%d %H:%M:%S") - $1"
}

# Stop all running containers if 
log "Stopping all running containers..."
docker stop $(docker ps -q)

# Remove all containers
log "Removing all containers..."
docker rm $(docker ps -a -q)

# Remove all images
log "Removing all Docker images..."
docker rmi -f $(docker images -q)

# Remove all networks
log "Removing all Docker networks..."
docker network rm $(docker network ls -q | grep -v "bridge\|host\|none")

# Create a new network for Zabbix
log "Creating a new Docker network for Zabbix..."
docker network create $NETWORK_NAME

# Pull the required Docker images
log "Pulling required Docker images..."
docker pull mysql:5.7
docker pull zabbix/zabbix-server-mysql
docker pull zabbix/zabbix-web-nginx-mysql

# Start MySQL container
log "Starting MySQL container..."
docker run --name $MYSQL_CONTAINER_NAME -t \
  -e MYSQL_ROOT_PASSWORD=$MYSQL_ROOT_PASSWORD \
  -e MYSQL_DATABASE=$MYSQL_DATABASE \
  -e MYSQL_USER=$MYSQL_USER \
  -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
  --network $NETWORK_NAME \
  -d mysql:5.7

# Wait for MySQL to initialize
log "Waiting for MySQL to initialize..."
sleep 30

# Initialize Zabbix database schema with proper character set and collation
log "Initializing Zabbix database schema..."
docker run --rm --name $ZABBIX_SERVER_CONTAINER_NAME -t \
  -e DB_SERVER_HOST=$MYSQL_CONTAINER_NAME \
  -e MYSQL_DATABASE=$MYSQL_DATABASE \
  -e MYSQL_USER=$MYSQL_USER \
  -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
  --network $NETWORK_NAME \
  zabbix/zabbix-server-mysql /bin/bash -c "mysql -h $MYSQL_CONTAINER_NAME -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE -e 'ALTER DATABASE $MYSQL_DATABASE CHARACTER SET utf8 COLLATE utf8_bin;' && zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -h $MYSQL_CONTAINER_NAME -u $MYSQL_USER -p$MYSQL_PASSWORD $MYSQL_DATABASE"

# Check if the initialization was successful
if [ $? -ne 0 ]; then
  log "Error initializing the Zabbix database schema."
  exit 1
fi

# Start Zabbix server container
log "Starting Zabbix server container..."
docker run --name $ZABBIX_SERVER_CONTAINER_NAME -t \
  -e DB_SERVER_HOST=$MYSQL_CONTAINER_NAME \
  -e MYSQL_DATABASE=$MYSQL_DATABASE \
  -e MYSQL_USER=$MYSQL_USER \
  -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
  --network $NETWORK_NAME \
  -d zabbix/zabbix-server-mysql

# Start Zabbix web interface container
log "Starting Zabbix web interface container..."
docker run --name $ZABBIX_WEB_CONTAINER_NAME -t \
  -e DB_SERVER_HOST=$MYSQL_CONTAINER_NAME \
  -e MYSQL_DATABASE=$MYSQL_DATABASE \
  -e MYSQL_USER=$MYSQL_USER \
  -e MYSQL_PASSWORD=$MYSQL_PASSWORD \
  -p 8080:8080 \
  --network $NETWORK_NAME \
  -d zabbix/zabbix-web-nginx-mysql

log "Zabbix setup completed. Access the web interface at http://localhost:8080"
