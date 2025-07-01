#!/bin/bash

# Instalação do Nginx
sudo apt update -y
sudo apt upgrade -y

curl https://nginx.org/keys/nginx_signing.key | gpg --dearmor \
    | sudo tee /usr/share/keyrings/nginx-archive-keyring.gpg >/dev/null

echo "deb [signed-by=/usr/share/keyrings/nginx-archive-keyring.gpg] \
http://nginx.org/packages/ubuntu `lsb_release -cs` nginx" \
    | sudo tee /etc/apt/sources.list.d/nginx.list

echo -e "Package: *\nPin: origin nginx.org\nPin: release o=nginx\nPin-Priority: 900\n" \
    | sudo tee /etc/apt/preferences.d/99nginx

sudo apt update
sudo apt install nginx

#Removendo arquivo padrão de configuração Nginx
sudo rm /etc/nginx/conf.d/default.conf

# Dado site_inicial.conf
ARQUIVO_SITE_INICIAL="
server {
	location / {
		root /data/www;
	}
}
"

# Criando arquivos de configuração
sudo sh -c "echo \"$ARQUIVO_SITE_INICIAL\" > /etc/nginx/conf.d/site_inicial.conf "

# Criando pasta de arquivos que será servida
sudo mkdir -p /data/www/

# Alterando permissões para permitir que o usuário utilize 
sudo chown -R www-data:www-data /data/
sudo chmod -R 755 /data/

# Garantir que o diretório abaixo existe
sudo mkdir -p /etc/systemd/system/nginx.service.d

# Criação do arquivo override pra reiniciar o nginx quando o serviço parar de funcionar.
ARQUIVO_OVERRIDE="
[Service]
Restart=on-failure
RestartSec=5s
"

sudo sh -c "echo \"$ARQUIVO_OVERRIDE\" > /etc/systemd/system/nginx.service.d/override.conf"

# Reiniciando o systemctl
sudo systemctl daemon-reload

sudo systemctl restart nginx.service

# Baixando arquivos do HTML
curl -O http://rb34-sv.duckdns.org:8000/www.tar.gz

# Descompactando o arquivo

tar -xzf www.tar.gz

sudo cp www/* /data/www/

# Instalando o awscli
curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
sudo apt install unzip
unzip awscliv2.zip
sudo ./aws/install

# Configurando serviços de monitoramento

sudo mkdir -p /etc/sentinela-nginx/telegram-bot/

sudo tee /etc/sentinela-nginx/verificar-disponibilidade.sh > /dev/null <<'FINAL_ARQUIVO'
#!/bin/bash
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1/index.html")

TIMESTAMP=$(date +"%Y/%m/%d - %H:%M:%S")

if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "($TIMESTAMP) Requisição bem sucedida 200 (OK)"
else
  echo "($TIMESTAMP) Erro no servidor"
  /etc/sentinela-nginx/telegram-bot/send-message.sh
fi
FINAL_ARQUIVO

# Coleta variáveis de ambiente

sudo tee /etc/sentinela-nginx/telegram-bot/send-message.sh > /dev/null <<'FINAL_ARQUIVO'
#!/bin/bash
TIMESTAMP=$(date +"%Y/%m/%d - %H:%M:%S")
TEXT="($TIMESTAMP) O site está fora do ar!"

API_URL=$(aws ssm get-parameter --name "API_URL" --with-decryption --query "Parameter.Value" --output text --region us-east-2)

CHAT_ID=$(aws ssm get-parameter --name "CHAT_ID" --with-decryption --query "Parameter.Value" --output text --region us-east-2) 

curl -s -o /dev/null -X POST "$API_URL"\
        -d "chat_id=$CHAT_ID"\
        -d "text=$TEXT"\
        -d "parse_mode=Markdown"

echo $TEXT
FINAL_ARQUIVO


sudo chmod +x /etc/sentinela-nginx/verificar-disponibilidade.sh
sudo chmod +x /etc/sentinela-nginx/telegram-bot/send-message.sh

# Limpando arquivos baixados
sudo rm -rf www.tar.gz awscliv2.zip www

# Configurando o serviço de verificação + o timer

sudo tee /etc/systemd/system/sentinela-nginx.service > /dev/null << 'FINAL_ARQUIVO'
[Unit]
Description=Script de monitoramento da página do Nginx.
#After=network.target nginx.service
#Requires=nginx.service

[Service]
ExecStart=/etc/sentinela-nginx/verificar-disponibilidade.sh
User=ubuntu
StandardOutput=append:/var/log/verificar-disponibilidade.log
StandardError=append:/var/log/verificar-disponibilidade.log

[Install]
WantedBy=multi-user.target
FINAL_ARQUIVO

sudo tee /etc/systemd/system/sentinela-nginx.timer > /dev/null << 'FINAL_ARQUIVO'
[Unit]
Description=Executar script a cada 30 segundos

[Timer]
# Removi essa opção porque não estava preciso
#OnBootSec=30s
#OnUnitActiveSec=30s
# Aqui ele vai executar a cada 30 segundos do relógio, precisamente.
OnCalendar=*:*:00,30
Persistent=true
AccuracySec=1s

[Install]
WantedBy=timers.target
FINAL_ARQUIVO

sudo systemctl daemon-reload

sudo systemctl enable sentinela-nginx.service
sudo systemctl enable sentinela-nginx.timer

sudo systemctl start sentinela-nginx.service
sudo systemctl start sentinela-nginx.timer