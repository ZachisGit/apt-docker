#!/bin/bash

# Default values
APT_DOCKER_NAME="mongo-server"
MONGO_TAG="latest"
MONGO_INITDB_ROOT_USERNAME="root"
MONGO_INITDB_ROOT_PASSWORD="my-secret-pw"
MONGO_DATABASE="mydatabase"
MONGO_USER="username"
MONGO_PASSWORD="example-password"
DATA_DIR="$HOME/.apt-docker/"
PORT="27017"
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
    --mongo-tag=*)
      MONGO_TAG="${1#*=}"
      shift 1
      ;;
    --mongo-initdb-root-username=*)
      MONGO_INITDB_ROOT_USERNAME="${1#*=}"
      shift 1
      ;;
    --mongo-initdb-root-password=*)
      MONGO_INITDB_ROOT_PASSWORD="${1#*=}"
      shift 1
      ;;
    --mongo-database=*)
      MONGO_DATABASE="${1#*=}"
      shift 1
      ;;
    --mongo-user=*)
      MONGO_USER="${1#*=}"
      shift 1
      ;;
    --mongo-password=*)
      MONGO_PASSWORD="${1#*=}"
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
  SETTINGS=$(dialog --keep-tite --stdout --backtitle "MongoDB Container Settings" --form "Please review and edit the settings:" 22 60 0 \
    "apt-docker-name:" 1 1 "$APT_DOCKER_NAME" 1 20 30 0 \
    "mongo-tag:" 2 1 "$MONGO_TAG" 2 20 30 0 \
    "mongo-initdb-root-username:" 3 1 "$MONGO_INITDB_ROOT_USERNAME" 3 20 30 0 \
    "mongo-initdb-root-password:" 4 1 "$MONGO_INITDB_ROOT_PASSWORD" 4 20 30 0 \
    "mongo-database:" 5 1 "$MONGO_DATABASE" 5 20 30 0 \
    "mongo-user:" 6 1 "$MONGO_USER" 6 20 30 0 \
    "mongo-password:" 7 1 "$MONGO_PASSWORD" 7 20 30 0 \
    "data-dir:" 8 1 "$DATA_DIR" 8 20 30 0 \
    "port:" 9 1 "$PORT" 9 20 30 0 \
    "ip-mode:" 10 1 "$IP_MODE" 10 20 30 0)

  if [ $? -eq 1 ]; then
    echo "Aborting."
    exit 1
  fi

  IFS=$'\n'
  SETTINGS=($SETTINGS)
  unset IFS

  APT_DOCKER_NAME="${SETTINGS[0]}"
  MONGO_TAG="${SETTINGS[1]}"
  MONGO_INITDB_ROOT_USERNAME="${SETTINGS[2]}"
  MONGO_INITDB_ROOT_PASSWORD="${SETTINGS[3]}"
  MONGO_DATABASE="${SETTINGS[4]}"
  MONGO_USER="${SETTINGS[5]}"
  MONGO_PASSWORD="${SETTINGS[6]}"
  DATA_DIR="${SETTINGS[7]}/${APT_DOCKER_NAME}"
  PORT="${SETTINGS[8]}"
  IP_MODE="${SETTINGS[9]}"

  dialog --keep-tite --backtitle "Confirm MongoDB Container Settings" --yesno \
  "apt-docker-name: $APT_DOCKER_NAME\n
mongo-tag: $MONGO_TAG\n
mongo-initdb-root-username: $MONGO_INITDB_ROOT_USERNAME\n
mongo-initdb-root-password: $MONGO_INITDB_ROOT_PASSWORD\n
mongo-database: $MONGO_DATABASE\n
mongo-user: $MONGO_USER\n
mongo-password: $MONGO_PASSWORD\n
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

# Run the Docker container with the provided settings
docker run --name "$APT_DOCKER_NAME" \
  -e MONGO_INITDB_ROOT_USERNAME="$MONGO_INITDB_ROOT_USERNAME" \
  -e MONGO_INITDB_ROOT_PASSWORD="$MONGO_INITDB_ROOT_PASSWORD" \
  -e MONGO_INITDB_DATABASE="$MONGO_DATABASE" \
  -p "$PORT":27017 \
  -v "$DATA_DIR":/data/db \
  -d mongo:"$MONGO_TAG"

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
echo -e "${BLUE}Local connection URL:${NC} mongodb://${MONGO_USER}:${MONGO_PASSWORD}@localhost:${PORT}/${MONGO_DATABASE}"
if [ "$IP_MODE" = "public" ]; then
  echo -e "${BLUE}Public connection URL:${NC} mongodb://${MONGO_USER}:${MONGO_PASSWORD}@${PUBLIC_IP}:${PORT}/${MONGO_DATABASE}"
fi

echo
echo -e "${YELLOW}For usage instructions, please visit the following GitHub link:${NC}"
echo -e "${BLUE}https://github.com/ZachisGit/apt-docker/blob/repos/repo/${APT_DOCKER_NAME}/readme.md${NC}"

