#!/bin/bash
# Default values

ALPINE_DOCKER_NAME="alpine-container"
ALPINE_TAG="3.14"
DATA_DIR="$HOME/.alpine-docker/"
PORT="8080"
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
--alpine-docker-name=*)
ALPINE_DOCKER_NAME="${1#*=}"
shift 1
;;
--alpine-tag=*)
ALPINE_TAG="${1#*=}"
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
    SETTINGS=$(dialog --keep-tite --stdout --backtitle "Alpine Container Settings" --form "Please review and edit the settings:" 16 60 0 \
        "alpine-docker-name:" 1 1 "$ALPINE_DOCKER_NAME" 1 20 30 0 \
        "alpine-tag:" 2 1 "$ALPINE_TAG" 2 20 30 0 \
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

    ALPINE_DOCKER_NAME="${SETTINGS[0]}"
    ALPINE_TAG="${SETTINGS[1]}"
    DATA_DIR="${SETTINGS[2]}/${ALPINE_DOCKER_NAME}"
    PORT="${SETTINGS[3]}"
    IP_MODE="${SETTINGS[4]}"

    dialog --keep-tite --backtitle "Confirm Alpine Container Settings" --yesno \
        "alpine-docker-name: $ALPINE_DOCKER_NAME\n\
        alpine-tag: $ALPINE_TAG\n\
        data-dir: $DATA_DIR\n\
        port: $PORT\n\
        ip-mode: $IP_MODE\n\
        \n\
        Do you want to continue with these settings?" 0 0

    if [ $? -eq 0 ]; then
        confirm_settings="true"
    else
        confirm_settings="false"
    fi
done

# Check if Docker container with the same name already exists

if [ "$(docker ps -a -f "name=^/$ALPINE_DOCKER_NAME$" --format '{{.Names}}')" ]; then
    echo "A Docker container with the name '$ALPINE_DOCKER_NAME' already exists. Please choose a different name."
    exit 1
fi

# Run the Docker container with the provided settings

docker run --name "$ALPINE_DOCKER_NAME" \
    -p "$PORT":80 \
    -v "$DATA_DIR":/var/www/html \
    -d alpine:"$ALPINE_TAG"

# Define text colors

GREEN="\033[0;32m"
YELLOW="\033[1;33m"
BLUE="\033[0;34m"
NC="\033[0m" # No color

echo -e "${GREEN}Docker container '${ALPINE_DOCKER_NAME}' has been created and is now running.${NC}"
# Get local and public IP addresses

LOCAL_IP="$(hostname -I | awk '{print $1}')"
PUBLIC_IP="$(curl -s https://api.ipify.org/?format=json | grep -oP '"ip":\s*"\K[^"]+' | awk '{print $1}')"

echo
echo -e "${YELLOW}Access URLs:${NC}"
# Display the access URL for local and public IP addresses

echo -e "${BLUE}Local access URL:${NC} http://${LOCAL_IP}:${PORT}"
if [ "$IP_MODE" = "public" ]; then
echo -e "${BLUE}Public access URL:${NC} http://${PUBLIC_IP}:${PORT}"
fi

echo
echo -e "${YELLOW}For usage instructions, please visit the following GitHub link:${NC}"
echo -e "${BLUE}https://github.com/alpinelinux/docker-alpine${NC}"
