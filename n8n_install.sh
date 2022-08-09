#!/bin/sh
# ubuntu 20.04, ubuntu 22.04 tested
echo "Enter the URL. Example: dev.test.com"
read url
echo "Enter the timezone from https://en.wikipedia.org/wiki/List_of_tz_database_time_zones"
echo "Example: Europe/Moscow"
read timezone
echo "Setting up SMTP mail. Enter the server:"
read smtp_server
echo "Enter username (without @* part):"
read smtp_username
echo "Enter the mail pass. Don't use quotes:"
read smtp_pass
echo "Enter the sender name. Example: dev@test.com"
read smtp_sender

apt update && apt upgrade -y
apt install ca-certificates curl gnupg lsb-release -y
mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt update
apt install docker-ce docker-ce-cli containerd.io docker-compose-plugin debian-keyring debian-archive-keyring apt-transport-https caddy -y
apt remove iptables-persistent ufw -y
cd ~ && mkdir n8n && cd n8n
echo "version: '2'" > docker-compose.yml
echo "" >> docker-compose.yml
echo "services:" >> docker-compose.yml
echo "  n8n:" >> docker-compose.yml
echo "    image: n8nio/n8n:latest" >> docker-compose.yml
echo "    restart: unless-stopped" >> docker-compose.yml
echo "    ports:" >> docker-compose.yml
echo "      - 5678:5678" >> docker-compose.yml
echo "    environment:" >> docker-compose.yml
echo "      - GENERIC_TIMEZONE=$timezone" >> docker-compose.yml
echo "      - WEBHOOK_URL=https://$url/" >> docker-compose.yml
echo "      - N8N_EMAIL_MODE=smtp" >> docker-compose.yml
echo "      - N8N_SMTP_HOST=$smtp_server" >> docker-compose.yml
echo "      - N8N_SMTP_USER=$smtp_username" >> docker-compose.yml
echo "      - N8N_SMTP_PASS=$smtp_pass" >> docker-compose.yml
echo "      - N8N_SMTP_SENDER=$smtp_sender" >> docker-compose.yml
echo "    volumes:" >> docker-compose.yml
echo "      - ./n8n_data:/home/node/.n8n" >> docker-compose.yml
/usr/bin/docker compose up --detach
/usr/bin/docker compose logs
echo "$url {" > /etc/caddy/Caddyfile
echo "        reverse_proxy localhost:5678 {" >> /etc/caddy/Caddyfile
echo "		flush_interval -1" >> /etc/caddy/Caddyfile
echo "	}" >> /etc/caddy/Caddyfile
echo "}" >> /etc/caddy/Caddyfile

/usr/bin/caddy validate --config /etc/caddy/Caddyfile
/usr/bin/systemctl restart caddy
