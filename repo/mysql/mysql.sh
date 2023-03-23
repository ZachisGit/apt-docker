#!/bin/bash

# Default values
APT_DOCKER_NAME="mysql-server"
MYSQL_TAG="latest"
MYSQL_ROOT_PASSWORD="my-secret-pw"
MYSQL_DATABASE="mydatabase"
MYSQL_USER="user-name"
MYSQL_PASSWORD="example-password"
DATA_DIR="$HOME/.apt-docker/mysql-single-$APT_DOCKER_NAME"
PORT="3306"
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
    --mysql-tag=*)
      MYSQL_TAG="${1#*=}"
      shift 1
      ;;
    --mysql-root-password=*)
      MYSQL_ROOT_PASSWORD="${1#*=}"
      shift 1
      ;;
    --mysql-database=*)
      MYSQL_DATABASE="${1#*=}"
      shift 1
      ;;
    --mysql-user=*)
      MYSQL_USER="${1#*=}"
      shift 1
      ;;
    --mysql-password=*)
      MYSQL_PASSWORD="${1#*=}"
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
  SETTINGS=$(dialog --keep-tite --stdout --backtitle "MySQL Container Settings" --form "Please review and edit the settings:" 22 60 0 \
    "apt-docker-name:" 1 1 "$APT_DOCKER_NAME" 1 20 30 0 \
    "mysql-tag:" 2 1 "$MYSQL_TAG" 2 20 30 0 \
    "mysql-root-password:" 3 1 "$MYSQL_ROOT_PASSWORD" 3 20 30 0 \
    "mysql-database:" 4 1 "$MYSQL_DATABASE" 4 20 30 0 \
    "mysql-user:" 5 1 "$MYSQL_USER" 5 20 30 0 \
    "mysql-password:" 6 1 "$MYSQL_PASSWORD" 6 20 30 0 \
    "data-dir:" 7 1 "$DATA_DIR" 7 20 30 0 \
    "port:" 8 1 "$PORT" 8 20 30 0 \
    "ip-mode:" 9 1 "$IP_MODE" 9 20 30 0)

  if [ $? -eq 1 ]; then
    echo "Aborting."
    exit 1
  fi

  IFS=$'\n'
  SETTINGS=($SETTINGS)
  unset IFS

  APT_DOCKER_NAME="${SETTINGS[0]}"
  MYSQL_TAG="${SETTINGS[1]}"
  MYSQL_ROOT_PASSWORD="${SETTINGS[2]}"
  MYSQL_DATABASE="${SETTINGS[3]}"
  MYSQL_USER="${SETTINGS[4]}"
  MYSQL_PASSWORD="${SETTINGS[5]}"
  DATA_DIR="${SETTINGS[6]}"
  PORT="${SETTINGS[7]}"
  IP_MODE="${SETTINGS[8]}"

  dialog --keep-tite --backtitle "Confirm MySQL Container Settings" --yesno \
  "apt-docker-name: $APT_DOCKER_NAME\n
mysql-tag: $MYSQL_TAG\n
mysql-root-password: $MYSQL_ROOT_PASSWORD\n
mysql-database: $MYSQL_DATABASE\n
mysql-user: $MYSQL_USER\n
mysql-password: $MYSQL_PASSWORD\n
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
  -e MYSQL_ROOT_PASSWORD="$MYSQL_ROOT_PASSWORD" \
  -e MYSQL_DATABASE="$MYSQL_DATABASE" \
  -e MYSQL_USER="$MYSQL_USER" \
  -e MYSQL_PASSWORD="$MYSQL_PASSWORD" \
  -p "$PORT":3306 \
  -v "$DATA_DIR":/var/lib/mysql \
  -d mysql:"$MYSQL_TAG"

# Clear the screen and reset terminal colors
clear
tput sgr0

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
echo -e "${BLUE}Local connection URL:${NC} mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${LOCAL_IP}:${PORT}/${MYSQL_DATABASE}"
if [ "$IP_MODE" = "public" ]; then
  echo -e "${BLUE}Public connection URL:${NC} mysql://${MYSQL_USER}:${MYSQL_PASSWORD}@${PUBLIC_IP}:${PORT}/${MYSQL_DATABASE}"
fi

echo
echo -e "${YELLOW}For usage instructions, please visit the following GitHub link:${NC}"
echo -e "${BLUE}https://github.com/ZachisGit/apt-docker/blob/repos/repo/mysql/readme.md${NC}"
