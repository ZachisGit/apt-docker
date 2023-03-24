#!/bin/bash

# Default values
APT_DOCKER_NAME="nodejs-server"
NODE_TAG="latest"
DATA_DIR="$HOME/.apt-docker/"
PORT="3000"
IP_MODE="local"

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
    --node-tag=*)
      NODE_TAG="${1#*=}"
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
    --ip-mode=*)
      IP_MODE="${1#*=}"
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
  SETTINGS=$(dialog --keep-tite --stdout --backtitle "Node.js Container Settings" --form "Please review and edit the settings:" 22 60 0 \
    "apt-docker-name:" 1 1 "$APT_DOCKER_NAME" 1 20 30 0 \
    "node-tag:" 2 1 "$NODE_TAG" 2 20 30 0 \
    "data-dir:" 3 1 "$DATA_DIR" 3 20 30 0 \
    "port:" 4 1 "$PORT" 4 20 30 0 \
    "ip-mode:" 5 1 "$IP_MODE" 5 20 30 0)

  if [ $? -eq 1 ]; then
    echo "Aborting."
    exit 1
  fi

  IFS=$'\n'
  SETTINGS=($SETTINGS)
  unset IFS

  APT_DOCKER_NAME="${SETTINGS[0]}"
  NODE_TAG="${SETTINGS[1]}"
  DATA_DIR="${SETTINGS[2]}/${APT_DOCKER_NAME}"
  PORT="${SETTINGS[3]}"
  IP_MODE="${SETTINGS[4]}"

  dialog --keep-tite --backtitle "Confirm Node.js Container Settings" --yesno \
  "apt-docker-name: $APT_DOCKER_NAME\n
node-tag: $NODE_TAG\n
data-dir: $DATA_DIR\n
port: $PORT\n
ip-mode: $IP_MODE\n
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

# Check if the port is in use
while true; do
  if lsof -Pi :$PORT -sTCP:LISTEN -t >/dev/null ; then
    echo "Port $PORT is in use. Trying a different port..."
    PORT=$((PORT + 1))
  else
    break
  fi
done

# Create a simple app.js file with a basic Node.js server
mkdir -p "${DATA_DIR}/app"
cat > "${DATA_DIR}/app/app.js" <<EOL
const http = require('http');

const hostname = '0.0.0.0';
const port = ${PORT};

const server = http.createServer((req, res) => {
  res.statusCode = 200;
  res.setHeader('Content-Type', 'text/plain');
  res.end('apt-docker install Node.js successful.\n');
});

server.listen(port, hostname, () => {
  console.log('Server running at http://${hostname}:${port}/');
});
EOL

# Run the Docker container with the provided settings
docker run --name "$APT_DOCKER_NAME" \
  -p "$PORT":$PORT \
  -v "$DATA_DIR/app":/usr/src/app \
  -w /usr/src/app \
  -d node:"$NODE_TAG" \
  node app.js

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
echo -e "${BLUE}Local connection URL:${NC} http://localhost:${PORT}"
if [ "$IP_MODE" = "public" ]; then
  echo -e "${BLUE}Public connection URL:${NC} http://${PUBLIC_IP}:${PORT}"
fi

echo
echo -e "${YELLOW}For usage instructions, please visit the following GitHub link:${NC}"
echo -e "${BLUE}https://github.com/ZachisGit/apt-docker/blob/repos/repo/${APT_DOCKER_NAME}/readme.md${NC}"
