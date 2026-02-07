#!/bin/bash

# Define the installation directory (change if you installed it elsewhere)
DEST="/home/lampac"

echo "--- Starting Lampac and .NET Uninstallation ---"

# 1. Stop and remove the systemd service
echo ">> Stopping and removing lampac.service..."
sudo systemctl stop lampac 2>/dev/null
sudo systemctl disable lampac 2>/dev/null
if [ -f /etc/systemd/system/lampac.service ]; then
    sudo rm -f /etc/systemd/system/lampac.service
    echo "Service file removed."
fi
sudo systemctl daemon-reload

# 2. Remove .NET binaries and symlinks
echo ">> Removing .NET (installed in /usr/share/dotnet)..."
if [ -d "/usr/share/dotnet" ]; then
    sudo rm -rf /usr/share/dotnet
    echo "Dotnet directory deleted."
fi

if [ -L "/usr/bin/dotnet" ] || [ -f "/usr/bin/dotnet" ]; then
    sudo rm -f /usr/bin/dotnet
    echo "Dotnet symlink removed."
fi

# 3. Clean up Crontab
echo ">> Cleaning up crontab tasks..."
# Remove any line containing 'update.sh' related to the installation
crontab -l 2>/dev/null | grep -v "update.sh" | crontab -
echo "Crontab updated."

# 4. Remove application files
echo ">> Removing application files from $DEST..."
if [ -d "$DEST" ]; then
    sudo rm -rf "$DEST"
    echo "Directory $DEST deleted."
else
    echo "Directory $DEST not found, skipping."
fi

# 5. Clean up temporary installation scripts
echo ">> Removing leftover installation scripts..."
rm -f dotnet-install.sh install.sh

echo "--- Uninstallation Complete ---"

# Final Verification
if ! command -v dotnet &> /dev/null; then
    echo "Verification: .NET has been successfully removed."
else
    echo "Warning: 'dotnet' command still responds. Check /usr/local/bin or environment variables."
fi