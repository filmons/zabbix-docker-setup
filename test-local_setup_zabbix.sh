#!/bin/bash

# Stop all running containers
echo "Stopping all running containers..."
docker stop $(docker ps -q)

# Remove all containers
echo "Removing all containers..."
docker rm $(docker ps -a -q)

# Remove all images
echo "Removing all Docker images..."
docker rmi -f $(docker images -q)

# Remove all networks
echo "Removing all Docker networks..."
docker network rm $(docker network ls -q | grep -v "bridge\|host\|none")

# Create a new network for Zabbix
echo "Creating a new Docker network for Zabbix..."
docker network create zabbix-network

# Pull the required Docker images
echo "Pulling required Docker images..."
docker pull mysql:5.7
docker pull zabbix/zabbix-server-mysql
docker pull zabbix/zabbix-web-nginx-mysql

# Start MySQL container
echo "Starting MySQL container..."
docker run --name mysql-server -t \
  -e MYSQL_ROOT_PASSWORD=password \
  -e MYSQL_DATABASE=zabbix \
  -e MYSQL_USER=zabbix \
  -e MYSQL_PASSWORD=password \
  --network zabbix-network \
  -d mysql:5.7

# Wait for MySQL to initialize
echo "Waiting for MySQL to initialize..."
sleep 30

# Initialize Zabbix database schema with proper character set and collation
echo "Initializing Zabbix database schema..."
docker run --rm --name zabbix-server-mysql -t \
  -e DB_SERVER_HOST="mysql-server" \
  -e MYSQL_DATABASE="zabbix" \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD="password" \
  --network zabbix-network \
  zabbix/zabbix-server-mysql /bin/bash -c "mysql -h mysql-server -u zabbix -ppassword zabbix -e 'ALTER DATABASE zabbix CHARACTER SET utf8 COLLATE utf8_bin;' && zcat /usr/share/doc/zabbix-server-mysql/create.sql.gz | mysql -h mysql-server -u zabbix -ppassword zabbix"

# Start Zabbix server container
echo "Starting Zabbix server container..."
docker run --name zabbix-server-mysql -t \
  -e DB_SERVER_HOST="mysql-server" \
  -e MYSQL_DATABASE="zabbix" \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD="password" \
  --network zabbix-network \
  -d zabbix/zabbix-server-mysql

# Start Zabbix web interface container
echo "Starting Zabbix web interface container..."
docker run --name zabbix-web-nginx-mysql -t \
  -e DB_SERVER_HOST="mysql-server" \
  -e MYSQL_DATABASE="zabbix" \
  -e MYSQL_USER="zabbix" \
  -e MYSQL_PASSWORD="password" \
  -p 8080:8080 \
  --network zabbix-network \
  -d zabbix/zabbix-web-nginx-mysql

echo "Zabbix setup completed. Access the web interface at http://localhost:8080"
