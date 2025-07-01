#!/bin/bash
HTTP_STATUS=$(curl -s -o /dev/null -w "%{http_code}"  "http://127.0.0.1/index.html")

TIMESTAMP=$(date +"%Y/%m/%d - %H:%M:%S")

if [ "$HTTP_STATUS" -eq 200 ]; then
  echo "($TIMESTAMP) Requisição bem sucedida 200 (OK)"
else
  echo "($TIMESTAMP) Erro no servidor"
  /home/ubuntu/telegram-bot/send-message.sh
fi

https://github.com/Elleres/PB-JUN-2025-Atividade-de-Linux/blob/main/Atividade-de-Linux/README.md