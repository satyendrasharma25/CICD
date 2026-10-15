#!/bin/bash
exec > /var/log/user-data.log 2>&1
set -ex   # 👈 IMPORTANT (fail fast + debug)

apt update -y
apt install -y nginx unzip wget

cd /usr/share/nginx/html/
rm -rf *
cd /var/www/html
rm -rf *
# ✅ default nginx page remove
rm -f index.nginx-debian.html

# download
wget https://freewebsitetemplates.com/download/space-science/space-science.zip -O site.zip
   
# check download
if [ ! -f site.zip ]; then
  echo "Download failed!" >> /var/log/user-data.log
  exit 1
fi

# unzip
unzip site.zip

# check folder
if [ -d "space-science/upload" ]; then
  cp -r space-science/upload/* /var/www/html/
else
  echo "Folder not found!" >> /var/log/user-data.log
  exit 1
fi

systemctl restart nginx
systemctl enable nginx