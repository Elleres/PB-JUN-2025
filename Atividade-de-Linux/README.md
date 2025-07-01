# Atividade de Linux - PB JUN 2025

## Introdução

Nesse projeto, eu (Arthur Guimarães Elleres) pude aprender como fazer uma instância EC2 e configurar uma VPC dentro da AWS. Além disso, tive que configurar um servidor Nginx e alguns serviços para monitorar o funcionamento do servidor. Nesse README irei documentar o passo a passo para chegar no mesmo resultado que cheguei.

## Etapa 1

Para criar uma rede VPC dentro da AWS, pode se utilizar a interface gráfica da AWS, que exige poucos passos para configurar a VPC e as configurações são bem claras. Conforme a **Figura 1**, todas as configurações que são necessárias para utilizar vem como padrão, portanto, não é necessário fazer alterações. Cheque se você precisa da quantidade de sub-redes que vem por padrão, caso contrário, você pode diminuir.

![Criação de VPC](./fotos/create_vpc.png)
*Figura 1: Criação de VPC*

Depois de criar a VPC, é necessário criar uma instância EC2, que também é bem simples, visto que a interface da AWS possui bastante clareza. A parte mais importante é colocar as **tags de forma apropriada** (conforme a Patrícia instruiu), definir a imagem do sistema operacional e selecionar a VPC (com uma sub-rede pública que foi configurada anteriormente) correta. Além disso, é necessário ajustar algumas regras de segurança para permitir a conexão por meio de SSH (porta 22) e solicitações HTTP (porta 80).

![](./fotos/tags_EC2.png)
*Figura 2: Tags na criação da instância ECS*

## Etapa 2

### Instalando Nginx

Após configurar a instância EC2, é necessário instalar o Nginx. Para isso, podemos utilizar o [tutorial](https://nginx.org/en/linux_packages.html#Ubuntu) que está disponível na documentação oficial do Nginx.

![](./fotos/instalacao_Nginx.png)
*Figura 3: Instalação do Nginx de acordo com documentação oficial.*

Depois de executar os comandos acima, o Nginx deverá estar disponível na instância. Entretanto, para que ele sirva a página HTML conforme o esperado, é necessário fazer alterações nas configurações do serviço.

### Configurando Nginx

Primeiramente, remova o arquivo **/etc/nginx/conf.d/default.conf** para que não haja conflitos com o arquivo de configuração. Após a deleção, crie um novo arquivo chamado **site_inicial.conf** (na mesma pasta onde estava o default.conf) e siga as configurações que estão na documentação oficial do software. Para que a página seja servida da forma correta (os arquivos que estão na pasta **/data/www** serão servidos no link **http://IP_DA_MAQUINA/NOME_DO_ARQUIVOs**) é necessário escrever no arquivo **site_inicial.conf** conforme a **Figura 4**.


![](./fotos/site_inicial_conf.png)

*Figura 4: Configuração do arquivo /etc/nginx/conf.d/site_inicial.conf*

É importante ressaltar a importância de **alterar as permissões da pasta `/data/www`**. Se o usuário usado pelo nginx (`www-data`) não tiver permissão para ler os arquivos na pasta, ele não poderá servir da forma apropriada. Além disso, é necessário garantir que a pasta exista. Para isso execute:
**`sudo mkdir -p /www/data`**
**`sudo chown -R www-data:www-data /data/`**
**`sudo chmod -R 755 /data/`**

### Criação do serviço

Para que o Nginx reinicie quando for parado de forma inesperada utilize o comando **`sudo systemctl edit nginx`**. Esse comando abre um editor de texto em um arquivo que irá sobrescrever algumas configurações do Nginx padrão. Dessa forma, podemos adicionar um bloco (bloco `[Service]` que não está comentado na **Figura 5**) de código que ordene a reinicialização do Nginx quando ele parar. Depois de alterar o código, é necessário executar o comando **`sudo systemctl daemon-reload`** para que o novo arquivo seja carregado.

![](./fotos/systemctl_edit_nginx.png)
*Figura 5: Resultado de systemctl edit nginx, com configurações para reinicialização.*

## Etapa 3

### Script para enviar mensagem pelo Telegram
Primeiramente, envie uma mensagem para o BotFather no Telegram. Após o diálogo da **Figura 6**, você recebera um token (guarde com segurança esse token, pois ele é o que vai controlar o bot, não compartilhe com outras pessoas) que poderá utilizar para executar comandos no bot que foi criado. Com o token em mãos, agora é possível criar um script para enviar uma mensagem. Para evitar expor os segredos no código `.sh`, crie um arquivo `.env` e coloque o token e a URL que você vai utilizar para fazer a requisição.

Coloque essas duas linhas de código no seu arquivo **.env**.
**`API_URL="https://api.telegram.org/bot{SEU_TOKEN}/sendMessage"`**
**`CHAT_ID="CHAT_ID_DA_CONVERSA_QUE_VOCE_QUER_ENVIAR"`**

Para coletar o ID de um chat, você pode enviar uma mensagem para o seu bot, e então acessar a url (no seu navegador) **`API_URL="https://api.telegram.org/bot{SEU_TOKEN}/getUpdates"`**. Lá, vai aparecer um JSON contendo o ID do chat.
 
![](./fotos/botfather.png)

*Figura 6: Criação do bot com o BotFather*


![](./fotos/send-message.sh.png)
*Figura 7: O script send-message.sh*

O script é bem simples, vou explicar linha por linha.

#### `TIMESTAMP=$(date +"%Y/%m/%d - %H:%M:%S")`

**`TIMESTAMP=$(date +"%Y/%m/%d - %H:%M:%S")`** -> Cria uma variável `TIMESTAMP` e armazena o valor da expressão após o sinal de igualdade.
`TIMESTAMP=`**`$(date +"%Y/%m/%d - %H:%M:%S")`** -> O cifrão seguido de parênteses significa que o valor de saída da função de dentro dos parênteses será substituído e, portanto, atribuído à variável.
`TIMESTAMP=$(**date +"%Y/%m/%d - %H:%M:%S"**)` -> Função para retornar o horário atual, formatado conforme está dentro da string, sendo o resultado: Ano/Mês/Dia - Hora:Minuto:Segundos.

#### `TEXT="($TIMESTAMP) $TEXT"`

**`TEXT="($TIMESTAMP) $TEXT"`** -> Não vou entrar em tantos detalhes pois é uma linha simples. Ele vai coletar o valor de **TIMESTAMP** e inserir no começo da string. Após isso, vai atribuir essa string à variável **TEXT**.

#### `SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"`

`SCRIPT_DIR="$(cd "$( dirname **"${BASH_SOURCE[0]}"** )" &> /dev/null && pwd)"` -> Esse comando exibe onde está sendo executado um script, nesse caso, onde o script `send-message.sh` está.

`SCRIPT_DIR="$(cd "$( **dirname** "${BASH_SOURCE[0]}" )" &> /dev/null && pwd)"` -> Serve para extrair o diretório de um caminho. Por exemplo, se eu executasse: **`dirname "/home/ubuntu/verificar-disponibilidade.sh"`** resultaria em `/home/ubuntu` sendo printado no terminal.

`SCRIPT_DIR="$(**cd** "$( dirname "${BASH_SOURCE[0]}" )" **&> /dev/null** && pwd)"` -> O `cd` será executado com o texto resultante do `dirname`, ou seja, o diretório onde está sendo executado o `send-message.sh`. O **`&>/dev/null`** serve para "jogar fora" qualquer output que o `cd` possa exibir.

`SCRIPT_DIR="$(cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null **&& pwd**)"` -> Vai executar o `pwd` somente se o `cd` tiver executado com sucesso. Retornando o diretório onde o código está sendo executado.
`SCRIPT_DIR=**"$(**cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd**)"**` -> Coleta o resultado dos comandos e salva na variável `SCRIPT_DIR`.

#### `source "$SCRIPT_DIR/.env"`

**`source "$SCRIPT_DIR/.env"`** -> Importa do arquivo `.env` do diretório onde o script está sendo executado.

#### `curl -s -X POST "$API_URL" -d "chat_id=$CHAT_ID" -d "text=$TEXT" -d "parse_mode=Markdown"`

**`curl -s -X POST "$API_URL"`**\\
`-d "chat_id=$CHAT_ID"`\\
`-d "text=$TEXT"`\\
`-d "parse_mode=Markdown"` -> Faz uma post request para `$API_URL` (que está sendo importada do arquivo `.env`) de forma silenciosa (sem poluição no terminal).

`curl -s -X POST "$API_URL"`\\
**`-d "chat_id=$CHAT_ID"`**\\
**`-d "text=$TEXT"`**\\
**`-d "parse_mode=Markdown"`** -> Parâmetros da [API do Telegram](https://core.telegram.org/bots/api#sendmessage). `chat_id` representa o ID da conversa (basicamente quem deve receber a mensagem), `text` é o texto da mensagem (nesse caso, a variável que criamos acima) e por último, `parse_mode` é o modo que a API deve ler o texto enviado, nesse caso, selecionamos como `Markdown`, já que é um texto simples.

Com isso, tenho um bot capaz de enviar mensagens ao meu Telegram quando necessário. Para executá-lo, basta usar o caminho absoluto do arquivo, nesse caso é **"/home/ubuntu/telegram-bot/send-message.sh"**.

### Script de monitoramento da página Nginx

Para monitorar a página, fiz um script que envia uma post request para a URL **`http://127.0.0.1/index.html`**. Dependendo do código da resposta, é possível dizer se o sistema está funcionando conforme o esperado.

![](./fotos/verificar-disponibilidade.sh.png)

*Figura 8: Script verificar-disponibilidade.sh*

`HTTP_STATUS=$(curl **-s -o /dev/null** -w "%{http_code}" "http://127.0.0.1/index.html")` -> A flag **`-s`** representa uma saída silenciosa (sem printar no terminal mensagens de erro). Enquanto a flag e o parâmetro **`-o /dev/null`** representam que a saída (corpo da resposta) vai ser salva em `/dev/null`, que é um arquivo que descarta qualquer coisa que for escrita nele.

`HTTP_STATUS=$(curl -s -o /dev/null **-w "%{http_code}" "http://127.0.0.1/index.html"**)` -> A flag **`-w "%{http_code}"`** essencialmente coleta a variável `http_code` (isso pode ser visto na documentação do curl com "man curl"). E a URL é o local onde a página WEB está acessível.

Por último, a condicional vai basicamente verificar se o status da requisição é igual a 200. Se for, o script vai apenas printar que está tudo certo. Caso seja diferente de 200, o script printa que tem algo de errado no servidor e executa o script de enviar mensagem no servidor.

### Execução a cada 30 segundos do script

#### Criando um serviço

Para executar o serviço, criei o seguinte arquivo **/etc/systemd/system/sentinela-nginx.service.**

![](./fotos/sentinela-nginx.service.png)

*Figura 8: Arquivo sentinela-nginx.service*

Esse serviço executa o script de verificar disponibilidade e salva o resultado que é printado no terminal no arquivo **verificar-disponibilidade.log**.

Entretanto, somente isso não é o suficiente para executar o serviço a cada 1 minuto. Para que o serviço seja executado em um período de tempo definido, é necessário criar um arquivo **/etc/systemd/system/sentinela-nginx.timer**.

![](./fotos/sentinela.nginx.timer.png)

*Figura 9: Arquivo sentinela-nginx.timer*

As linhas que estão comentadas na **Figura 9** representam a primeira tentativa de fazer o serviço executar em um tempo específico. Entretanto, essa alternativa não tinha me agradado, devido ao fato de que ela não estava sendo executada a cada 30 segundos, então alterei para o código que está abaixo, que executa sempre que chegar nos 30 segundos de algum minuto.

A linha **`WantedBy=timers.target`** cria um link simbólico (quando o service `.timer` for habilitado com o `enable`) para a pasta que gerencia os arquivos `.timer` do sistema. Então, o sistema irá executar esses arquivos ao iniciar.

---

## Testando a solução

Se você seguiu os passos que eu fiz até aqui, você deve poder executar o teste conforme explicarei abaixo.

### Testando reinicialização do Nginx

Para verificar se a configuração de reinicialização do Nginx está funcionando corretamente, você deve terminar o processo de uma forma inesperada. Para isso, execute os comandos da seguinte forma:

**`ps aux | grep nginx | grep master`** -> Vai lhe fornecer o processo master do Nginx. Você irá utilizar o PID desse processo para o próximo passo, além disso, garante que o Nginx está rodando.

**`sudo kill -9 PID_DO_PROCESSO`** -> Isso vai finalizar o processo de uma forma inesperada. O `-9` significa forçar o término do processo.

**`sudo systemctl status nginx`** -> Vai exibir que o serviço está reiniciando (ou ativo se você demorar para executar).

![](./fotos/teste-reinicio-nginx.png)
*Figura 10: Resultado dos comandos acima.*

Na **Figura 10**, você pode ver que o processo está "activating", que é o sinal de que ele foi finalizado e está iniciando novamente.

### Testando o script de verificar a disponibilidade

Não irei testar o script **`send-message.sh`** diretamente, já que ele é executado junto com o script **`verificar-disponibilidade.sh`**.

Para testar o serviço, vamos testar em partes, e depois testar tudo de uma vez só. Primeiramente, vou executar o script **`verificar-disponibilidade.sh`**. Para isso, irei para a pasta onde criei o arquivo. Na **Figura 11**, é possível ver que quando o serviço do Nginx está rodando, o script retorna que está tudo certo. Na **Figura 12**, é possível ver que o script alerta que o site está fora do ar.

#### Testando com o Nginx ativo

**`sudo systemctl status nginx`** -> Para verificar que o Nginx está ativo.

**`./verificar-disponibilidade.sh`** -> Para executar o script.

![](./fotos/teste-verificar-disponibilidade.sh.png)
*Figura 11: Teste do verificar-disponibilidade.sh*

#### Testando com o Nginx desligado

**`sudo systemctl stop nginx`** -> Para o serviço da forma correta, não ativando o trigger de reiniciar o serviço automaticamente.

**`sudo systemctl status nginx`** -> Para verificar que o Nginx está desligado.

**`./verificar-disponibilidade.sh`** -> Para executar o script.
![](./fotos/teste-verificar-disponbilidade.sh.fail.png)
*Figura 12: Teste do verificar-disponibilidade.sh com Nginx desligado*

![](./fotos/teste-chat-telegram.png)
*Figura 13: Chat com as mensagens de alerta do estado do site.*

Na **Figura 13**, podemos ver as mensagens que são enviadas quando o script é executado e o sistema está fora do ar. A mensagem que é enviada no dia 26/06/2025 - 13:44:34 é resultante da execução manual que fiz, enquanto as outras são do serviço de automação, que executa a cada 30 segundos.

### Testando os serviços de execução/temporização

Se você criou os arquivos corretamente, você deve ser capaz de executar os seguintes comandos para ativar os serviços.

#### Testando o sentinela-nginx.service

**`sudo systemctl enable sentinela-nginx.service`** -> Esse comando vai criar o link simbólico que vai ativar o serviço para o systemctl.

**`sudo cat /var/log/verificar-disponibilidade.log`** -> Esse comando é para mostrar que o arquivo está vazio no momento.

**`sudo systemctl start sentinela-nginx.service`** -> Vai executar o serviço que por consequência vai executar o script **`verificar-disponibilidade.sh`**.

**`sudo cat /var/log/verificar-disponibilidade.log`** -> Agora o comando deve exibir o log do script.

![](./fotos/teste-sentinela-nginx.service.png)
*Figura 14: Execução dos comandos para testar o sentinela-nginx.service.*

#### Testando o sentinela-nginx.timer

Para testar o timer, irei printar primeiramente o horário atual da máquina e então habilitar o serviço. Para isso, executei os seguintes comandos:

**`date +"%Y/%m/%d - %H:%M:%S"`** -> Printar o horário atual no terminal.

**`sudo systemctl enable sentinela-nginx.timer`** -> Ativa o serviço.

**`sudo systemctl start sentinela-nginx.timer`** -> Inicia o serviço.

**`sudo cat /var/log/verificar-disponibilidade.log`** -> Verificando o log para contar o número de vezes que o script foi executado.

![](./fotos/teste-sentinela-nginx.timer.png)
*Figura 15: Execução dos comandos para testar o sentinela-nginx.timer.*