#!/bin/bash

# Configuration
CONTAINER_NAME="lampac-local"
IMAGE_NAME="mylampac:final"
DOCKERFILE_URL="https://raw.githubusercontent.com/lampastore/lampac-scripts/master/Dockerfile"
DEST=$(pwd)

echo "--- Starting Deployment from: $DEST ---"

# 1. Download the latest Dockerfile
echo "Fetching latest Dockerfile..."
curl -sL "$DOCKERFILE_URL" -o "$DEST/Dockerfile"

# 2. Prepare environment
echo "Preparing directories and config files..."
mkdir -p "$DEST/cache"
chmod -R 777 "$DEST/cache"

# Create default init.conf if it doesn't exist (Lampac custom format)
if [ ! -f "$DEST/init.conf" ]; then
    echo "Creating default init.conf..."
cat <<EOF > "$DEST/init.conf"
"listenport": 9111
EOF
fi

# 3. Cleanup old container
if [ "$(docker ps -aq -f name=$CONTAINER_NAME)" ]; then
    echo "Removing existing container..."
    docker rm -f $CONTAINER_NAME > /dev/null
fi

# 4. Build the image
echo "Building Docker image: $IMAGE_NAME..."
docker build --no-cache -t $IMAGE_NAME .

# 5. Run the container
echo "Launching container..."
docker run -d \
  --name $CONTAINER_NAME \
  -p 9111:9111 \
  -v "$DEST/init.conf:/home/lampac/init.conf" \
  -v "$DEST/cache:/home/lampac/cache" \
  --restart always \
  $IMAGE_NAME

# 6. Post-build cleanup (removes unused layers/images)
echo "Cleaning up dangling images..."
docker image prune -f

# --- Helper Functions and Final Output ---

get_external_ip() {
   local ip
   ip=$(curl -s --connect-timeout 5 https://api.ipify.org 2>/dev/null)
   if [ -z "$ip" ]; then
      ip=$(curl -s --connect-timeout 5 https://icanhazip.com 2>/dev/null)
   fi
   if [ -z "$ip" ]; then
      ip=$(curl -s --connect-timeout 5 https://ifconfig.me 2>/dev/null)
   fi
   echo "${ip:-IP}"
}

echo ""
echo "################################################################"
echo ""
echo "Have fun!"
echo ""
echo "Access Lampac at: http://$(get_external_ip):9111"
echo ""
echo "Please check/edit $DEST/init.conf params and configure it"
echo ""
echo "Then [re]start lampac container:"
echo "docker restart $CONTAINER_NAME"
echo ""
echo "################################################################"