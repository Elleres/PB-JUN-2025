# Coleta variáveis de ambiente

TIMESTAMP=$(date +"%Y/%m/%d - %H:%M:%S")
TEXT="($TIMESTAMP) O site está fora do ar!"

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

source "$SCRIPT_DIR/.env"

curl -s -o /dev/null -X POST "$API_URL"\
        -d "chat_id=$CHAT_ID"\
        -d "text=$TEXT"\
        -d "parse_mode=Markdown"

echo $TEXT
