#!/bin/sh
# ubuntu 20.04

apt update && apt upgrade -y
apt install ca-certificates curl gnupg lsb-release -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin debian-keyring debian-archive-keyring apt-transport-https -y
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
apt update
apt install caddy -y
apt remove iptables-persistent ufw -y
cd ~ && mkdir n8n && cd n8n
nano docker-compose.yml

echo "version: '2'" > docker-compose.yml
echo "" >> docker-compose.yml
echo "services:" >> docker-compose.yml
echo "  n8n:" >> docker-compose.yml
echo "    image: n8nio/n8n:latest" >> docker-compose.yml
echo "    restart: unless-stopped" >> docker-compose.yml
echo "    ports:" >> docker-compose.yml
echo "      - 5678:5678" >> docker-compose.yml
echo "    environment:" >> docker-compose.yml
echo "      - GENERIC_TIMEZONE=Europe/Moscow" >> docker-compose.yml
echo "      - WEBHOOK_URL=https://n8n.ddns.net/" >> docker-compose.yml
echo "      - N8N_EMAIL_MODE=smtp" >> docker-compose.yml
echo "      - N8N_SMTP_HOST=smtp.mail.ru" >> docker-compose.yml
echo "      - N8N_SMTP_USER=oleniichuk_y" >> docker-compose.yml
echo "      - N8N_SMTP_PASS=ASDgp1QSyiYDEAdQ5AQB" >> docker-compose.yml
echo "      - N8N_SMTP_SENDER=oleniichuk_y@mail.ru" >> docker-compose.yml
echo "    volumes:" >> docker-compose.yml
echo "      - ./n8n_data:/home/node/.n8n" >> docker-compose.yml
/usr/bin/docker compose up --detach
/usr/bin/docker compose logs
sudo nano /etc/caddy/Caddyfile

echo "n8nguide.thomasmartens.eu {" > /etc/caddy/Caddyfile
echo "        reverse_proxy localhost:5678 {" >> /etc/caddy/Caddyfile
echo "		flush_interval -1" >> /etc/caddy/Caddyfile
echo "	}" >> /etc/caddy/Caddyfile
echo "}" >> /etc/caddy/Caddyfile

/usr/bin/caddy validate --config /etc/caddy/Caddyfile
/usr/bin/systemctl restart caddy
