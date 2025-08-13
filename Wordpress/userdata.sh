#!/bin/bash

FILE_SYSTEM_ID="fs-09fc5159b3bb0693b"
DB_HOST="rds-endpoint"
DB_USER="admin"
DB_PASS="DbAtTesteProjeto2"
DB_NAME="wordpress"
WP_URL="http://meu-loadbalancer-dns"

apt-get update -y
apt-get install -y amazon-efs-utils nfs-common ca-certificates curl gnupg lsb-release

mkdir -p /mnt/efs/fs1
echo "${FILE_SYSTEM_ID}.efs.us-east-1.amazonaws.com:/ /mnt/efs/fs1 nfs4 nfsvers=4.1,rsize=1048576,wsize=1048576,hard,timeo=600,retrans=2,noresvport,_netdev 0 0" >> /etc/fstab
mount -a

install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
chmod a+r /etc/apt/keyrings/docker.asc
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "${UBUNTU_CODENAME:-$VERSION_CODENAME}") stable" | tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin

mkdir -p /home/ubuntu/wordpress

cat <<EOF > /mnt/efs/fs1/health.html
OK
EOF

cat <<EOF > /home/ubuntu/wordpress/docker-compose.yaml
services:
  wordpress:
    image: wordpress:latest
    container_name: wordpress_app
    restart: unless-stopped
    ports:
      - "80:80"
    environment:
      WORDPRESS_DB_HOST: ${DB_HOST}
      WORDPRESS_DB_USER: ${DB_USER}
      WORDPRESS_DB_PASSWORD: ${DB_PASS}
      WORDPRESS_DB_NAME: ${DB_NAME}
      WORDPRESS_CONFIG_EXTRA: |
        define('WP_HOME', '${WP_URL}');
        define('WP_SITEURL', '${WP_URL}');
    volumes:
      - /mnt/efs/fs1:/var/www/html
EOF

cd /home/ubuntu/wordpress
docker compose up -d
