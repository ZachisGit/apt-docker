#!/bin/bash

# Default values
APT_DOCKER_NAME="nginx-server"
NGINX_TAG="latest"
DATA_DIR="$HOME/.apt-docker/"
PORT="80"
SSL_PORT="443"
IP_MODE="public"
DOMAIN="example.org"

# Set confirm_settings to false by default
confirm_settings="false"

# Process command-line arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    -y|--yes)
      confirm_settings="true"
      shift 1
      ;;
    --apt-docker-name=*)
      APT_DOCKER_NAME="${1#*=}"
      shift 1
      ;;
    --nginx-tag=*)
      NGINX_TAG="${1#*=}"
      shift 1
      ;;
    --data-dir=*)
      DATA_DIR="${1#*=}"
      shift 1
      ;;
    --port=*)
      PORT="${1#*=}"
      shift 1
      ;;
    --ssl-port=*)
      SSL_PORT="${1#*=}"
      shift 1
      ;;
    --ip-mode=*)
      IP_MODE="${1#*=}"
      shift 1
      ;;
    --domain=*)
      DOMAIN="${1#*=}"
      shift 1
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

# Ask for confirmation or edit settings
while [ "$confirm_settings" != "true" ]; do
  SETTINGS=$(dialog --keep-tite --stdout --backtitle "NGINX Container Settings" --form "Please review and edit the settings:" 24 60 0 \
    "apt-docker-name:" 1 1 "$APT_DOCKER_NAME" 1 20 30 0 \
    "nginx-tag:" 2 1 "$NGINX_TAG" 2 20 30 0 \
    "data-dir:" 3 1 "$DATA_DIR" 3 20 30 0 \
    "port:" 4 1 "$PORT" 4 20 30 0 \
    "ssl-port:" 5 1 "$SSL_PORT" 5 20 30 0 \
    "ip-mode:" 6 1 "$IP_MODE" 6 20 30 0 \
    "domain:" 7 1 "$DOMAIN" 7 20 30 0)

  if [ $? -eq 1 ]; then
    echo "Aborting."
    exit 1
  fi

  IFS=$'\n'
  SETTINGS=($SETTINGS)
  unset IFS

  APT_DOCKER_NAME="${SETTINGS[0]}"
  NGINX_TAG="${SETTINGS[1]}"
  DATA_DIR="${SETTINGS[2]}/${APT_DOCKER_NAME}"
  PORT="${SETTINGS[3]}"
  SSL_PORT="${SETTINGS[4]}"
  IP_MODE="${SETTINGS[5]}"
  DOMAIN="${SETTINGS[6]}"

  dialog --keep-tite --backtitle "Confirm NGINX Container Settings" --yesno \
  "apt-docker-name: $APT_DOCKER_NAME\n
nginx-tag: $NGINX_TAG\n
data-dir: $DATA_DIR\n
port: $PORT\n
ssl-port: $SSL_PORT\n
ip-mode: $IP_MODE\n
domain: $DOMAIN\n
\n
Do you want to continue with these settings?" 0 0

  if [ $? -eq 0 ]; then
    confirm_settings="true"
  fi
done

# Check if Docker container with the same name already exists
if [ "$(docker ps -a -f "name=^/$APT_DOCKER_NAME$" --format '{{.Names}}')" ]; then
  echo "A Docker container with the name '$APT_DOCKER_NAME' already exists. Please choose a different name."
  exit 1
fi

# Check if the ports are in use
while true; do
  if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "Port $PORT is in use. Trying a different port..."
    PORT=$((PORT + 1))
  else
    break
  fi
done

while true; do
  if lsof -Pi :$SSL_PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "SSL Port $SSL_PORT is in use. Trying a different port..."
    SSL_PORT=$((SSL_PORT + 1))
  else
    break
  fi
done

# Create a simple index.html file with a success message
mkdir -p "${DATA_DIR}/html"
echo "apt-docker install nginx successful." > "${DATA_DIR}/html/index.html"

# Create a default nginx configuration file
mkdir -p "${DATA_DIR}/conf"
cat > "${DATA_DIR}/conf/default.conf" <<EOL
server {
    listen       80;
    server_name  $DOMAIN;

    location / {
        return 301 https://$DOMAIN\$request_uri;
    }

    location /.well-known/acme-challenge/ {
        root /var/www/certbot;
    }
}

server {
    listen       443 ssl http2;
    server_name  $DOMAIN;

    ssl_certificate /etc/nginx/ssl/live/$DOMAIN/fullchain.pem;
    ssl_certificate_key /etc/nginx/ssl/live/$DOMAIN/privkey.pem;

    location / {
        root   /usr/share/nginx/html;
        index  index.html index.htm;
    }

    error_page   500 502 503 504  /50x.html;
    location = /50x.html {
        root   /usr/share/nginx/html;
    }
}
EOL

# Create directories for Certbot
mkdir -p "${DATA_DIR}/certbot/www"
mkdir -p "${DATA_DIR}/certbot/conf"

# Install Certbot and obtain the SSL certificate
docker run -it --rm \
  -v "$DATA_DIR/certbot/conf":/etc/letsencrypt \
  -v "$DATA_DIR/certbot/www":/var/www/certbot \
  certbot/certbot certonly --standalone --preferred-challenges http \
  -d "$DOMAIN" --register-unsafely-without-email --agree-tos

# Run the Docker container with the provided settings
docker run --name "$APT_DOCKER_NAME" \
  -p "$PORT":80 \
  -p "$SSL_PORT":443 \
  -v "$DATA_DIR/html":/usr/share/nginx/html \
  -v "$DATA_DIR/conf":/etc/nginx/conf.d \
  -v "$DATA_DIR/certbot/www":/var/www/certbot \
  -v "$DATA_DIR/certbot/conf":/etc/nginx/ssl \
  -d nginx:"$NGINX_TAG"


# Define text colors
GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No color

echo -e "${GREEN}Docker container '${APT_DOCKER_NAME}' has been created and is now running.${NC}"

# Get local and public IP addresses
LOCAL_IP="$(hostname -I | awk '{print $1}')"
PUBLIC_IP="$(curl -s https://api.ipify.org/?format=json | grep -oP '\"ip\":\s*\"\K[^"]+' | awk '{print $1}')"

echo
echo -e "${YELLOW}Connection URLs:${NC}"

# Display the connection URL for local and public IP addresses
echo -e "${BLUE}Local HTTP connection URL:${NC} http://${DOMAIN}:${PORT}"
echo -e "${BLUE}Local HTTPS connection URL:${NC} https://${DOMAIN}:${SSL_PORT}"
if [ "$IP_MODE" = "public" ]; then
  echo -e "${BLUE}Public HTTP connection URL:${NC} http://${DOMAIN}:${PORT}"
  echo -e "${BLUE}Public HTTPS connection URL:${NC} https://${DOMAIN}:${SSL_PORT}"
fi

echo
echo -e "${YELLOW}For usage instructions, please visit the following GitHub link:${NC}"
echo -e "${BLUE}https://github.com/ZachisGit/apt-docker/blob/repos/repo/${APT_DOCKER_NAME}/readme.md${NC}"
