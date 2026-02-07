#!/usr/bin/env bash
DEST="/home/lampac"

# Become root
# sudo su -
apt-get update
apt-get install -y unzip curl libicu-dev
apt-get install -y libnss3-dev libgtk-3-dev libxss-dev libasound2
apt-get install -y libgdk-pixbuf2.0-dev
apt-get install -y libnspr4
apt-get install -y libatk1.0-0
apt-get install -y xvfb
apt-get install -y coreutils

# chromium
apt-get install -y libnss3 libatk-bridge2.0-0 libdrm-dev libxkbcommon-dev libxcomposite-dev libxdamage-dev libxrandr-dev libgbm-dev libasound2-dev libpangocairo-1.0-0 libpango-1.0-0 libcairo2-dev

# Install .NET
if ! curl -L -k -o dotnet-install.sh https://dot.net/v1/dotnet-install.sh; then
   echo "Failed to download dotnet-install.sh. Exiting."
   exit 1
fi

chmod 755 dotnet-install.sh
./dotnet-install.sh --channel 9.0 --runtime aspnetcore --install-dir /usr/share/dotnet
ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet

# Download zip
mkdir $DEST -p
cd $DEST
if ! curl -L -k -o publish.zip https://github.com/lampac-talks/lampac/releases/latest/download/publish.zip; then
   echo "Failed to download publish.zip. Exiting."
   exit 1
fi

unzip -o publish.zip
rm -f publish.zip

# automatic updates
curl -k -s https://api.github.com/repos/lampac-talks/lampac/releases/latest | grep tag_name | sed s/[^0-9]//g > $DEST/data/vers.txt

if [ ! -f "$DEST/init.conf" ]; then
cat <<EOF > $DEST/init.conf
"listen": {
  "port": 9111
}
EOF
fi

# iptables drop
cat <<EOF > iptables-drop.sh
#!/bin/sh
echo "Stopping firewall and allowing everyone..."
iptables -F
iptables -X
iptables -t nat -F
iptables -t nat -X
iptables -t mangle -F
iptables -t mangle -X
iptables -P INPUT ACCEPT
iptables -P FORWARD ACCEPT
iptables -P OUTPUT ACCEPT
EOF

# Note
echo ""
echo "################################################################"
echo ""
echo "Have fun!"
echo ""
echo "http://$(get_external_ip):9111"
echo ""
echo "Please check/edit $DEST/init.conf params and configure it"
echo ""
echo "Then [re]start it as systemctl [re]start lampac"
echo ""
echo "Clear iptables if port $random_port is not available"
echo "bash $DEST/iptables-drop.sh"
echo ""