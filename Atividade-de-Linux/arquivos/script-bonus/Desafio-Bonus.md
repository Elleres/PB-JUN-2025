# Tutorial desafio bônus

## Etapa 0 - Criando Role
Para poder executar alguns scripts na criação da EC2, a instância precisa ter permissão para acessar conteúdos especificos da AWS. Precisamos criar duas roles diferentes, uma para criar a instância com o user data e outro para criar utilizando o CloudFormation.

### ReadSecretParameters
Para criar essa role você procura na barra de busca IAM > Roles (ou funções dependendo da linguagem da sua interface) > Create Role (ou criar função). Ao entrar nessa página, você poderá criar a role conforme você desejar. Para esse tutorial, criei uma role chamada ReadSecretParameters, que dará permissão para EC2 ler segredos que foram armazenados no Parameter Store.

![Página 1 do Create Role](/Atividade-de-Linux/fotos/Role-read-secret-parameters.png)
*Figura 1: Página inicial da interface de criar role*

Conforme a **Figura 2**, você deve escolher somente a permissão **AmazonSSMReadOnlyAccess**. Essa permissão é gerenciada pela Amazon e dá somente o necessário para que a instância EC2 leia os segredos necessários.

![Página 2 do Create Role](/Atividade-de-Linux/fotos/add-permissions.png)
*Figura 2: Página onde você irá adicionar permissões*

Depois disso, você pode ir para a próxima página e dar o nome e descrição que achar mais apropriada e clicar em Create Role. Dessa forma, você terá o perfil necessário para criar a instância utilizando o user data.

### EC2WebServerInstanceProfile

Para criar essa função, você segue passos semelhantes com a função acima. Entretanto, você deve criar uma politíca de permissão customizada. Para isso, você faz conforme a **Figura 3**.

![Página 1 do Create role com custom policy](/Atividade-de-Linux/fotos/custom-politica-de-confianca.png)
*Figura 3: Política de confiança customizada*

Depois disso, você pode finalizar a criação da role somente com as entidades de confiança, pois precisaremos adicionar permissões mais complexas e esse método permite apenas selecionar permissões que são gerenciadas pela AWS.

Agora, com a role inicial criada, você pode procurar por ela em IAM > Roles > EC2WebServerInstanceProfile. Você deve encontrar a role conforme a **Figura 4**. Ao clicar nela, você poderá ver as permissões atuais da função. 

![Role](/Atividade-de-Linux/fotos/EC2InstanceProfileRole.png)
*Figura 4: EC2WebServerInstanceProfile*

Para adicionarmos permissões, você deve criar em Add permissions > Create inline policy. Você entrará em uma página para criar permissões, você deve então clicar em JSON (ao lado de visual) e inserir o conteudo do arquivo [EC2WebServerInstanceProfile.json](/Atividade-de-Linux/arquivos/script-bonus/EC2WebServerInstanceProfile.json). Essas permissões são bem amplas, entretanto, como esse serviço é simples isso não deve causar problemas.

![Criando Permissão](/Atividade-de-Linux/fotos/CriandoPermissao.png)
*Figura 5: Criando permissão*

Após isso, você poderá criar a permissão, colocando o nome desejado (é recomendado utilizar o nome EC2WebServerInstanceProfile, visto que é assim que está especificado no arquivo [nginx_server.yaml](/Atividade-de-Linux/arquivos/script-bonus/nginx_server.yaml)). Dessa forma, temos em mão agora todas os perfis necessários para os próximos passos.

## Etapa 0.1 - Criando segredos

A necessidade de criar esses perfis se da pelo fato de que precisamos acessar alguns segredos dentro do código [send-message.sh](/Atividade-de-Linux/arquivos/scripts/telegram-bot/send-message.sh). Os segredos necessários são a URL para enviar a mensagem - incluindo o token do bot, por isso a necessidade de ocultar -  e o ID do chat do telegram, essa última variável não é tão necessário ocultar, mas já que estamos aqui vamos adicionar essa precaução.

Para isso, você deve acessar AWS Systems Manager > Parameter Store. Já na página, você deve criar os parametros: 
- **API_URL**: https://api.telegram.org/bot{TOKEN_DO_SEU_BOT}/sendMessage
- **CHAT_ID**: ID_DO_SEU_CHAT (Você encontra como coletar esse dado na Etapa 3 do [README](/Atividade-de-Linux/README.md)).

Para que essas variáveis funcionem como segredo, você deve selecionar a opção **SecureString** na hora de sua criação. Você precisa criar um segredo diferente para cada uma. Além disso, é **MUITO** importante que você mantenha o nome da variável conforme o tutorial, visto que os scripts estão programados para procurar esses segredos pelo nome especificado.
## Etapa 1 - User data

Para criar uma instância EC2 utilizando user data, você deve criar a instância normalmente e ajustar nas últimas configurações.
Para isso, você pode seguir os passos da **Etapa 1** do [README principal](/Atividade-de-Linux/README.md), além disso, nas configurações adicionais, você deve inserir o instance profile ReadSecretParameters, que foi o que criamos para esse passo. No final, você vai encontrar uma aba com o nome user data. Nesse campo, você deve inserir o arquivo [user_data.sh](/Atividade-de-Linux/arquivos/script-bonus/user_data.sh). Depois disso, basta iniciar a instância e esperar até a inicialização ser completa.

![User data](/Atividade-de-Linux/fotos/user-data.png)
*Figura 6: Aba de user data.*

Dessa forma, você criará uma instância EC2 com o servidor setado de forma automática para cumprir todos os requisitos da tarefa principal.

## Etapa 2 - Criando instância da EC2 com o CloudFormation

Se você seguiu os passos da Etapa 0 e da Etapa 0.1 corretamente, agora você será capaz de criar a instância sem problemas pelo CloudFormation. Para isso, vá para CloudFormation > Stacks e clique em criar stack. 

![Cloud Formation 0](/Atividade-de-Linux/fotos/cloud-formation0.png)
*Figura 7: Página inicial da criação do CloudFormation.*

Selecione a opção upload a template file e coloque o arquivo [nginx_server.yaml](/Atividade-de-Linux/arquivos/script-bonus/nginx_server.yaml). Após isso, selecione next e coloque o nome desejado para sua stack, aperte next novamente. Depois basta confirmar que você compreende que essa stack pode criar IAM resources, na parte inferior e dar next. Após a revisão, basta criar a stack e pronto. Agora basta aguardar o Status Check da sua instância EC2 chegar no ponto 2/2 checks passed.

![Instância EC2 criada pelo CloudFormation carregando](/Atividade-de-Linux/fotos/loading-ec2.png)
*Figura 8: EC2 carregando*

![Instância EC2 criada pelo CloudFormation carregada](/Atividade-de-Linux/fotos/ec2-checks-passed.png)
*Figura 9: EC2 carregada*

Para servir sua página, você deve alterar o **index.html** na pasta **/data/www**. Feito isso, você terá uma página acessível na internet utilizando o IP da instância EC2. Você pode verificar o IP no painel EC2, conforme a **Figura 9**.