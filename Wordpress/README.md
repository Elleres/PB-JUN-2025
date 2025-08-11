# Projeto Wordpress - PB JUN 2025

## Introdução

O objetivo desse projeto é implantar a plataforma WordPress com alta disponibilidade na AWS.

## Etapa 1

É necessário criar uma VPC com quatro subnets, sendo quatro privadas e duas públicas. Para isso, entre no painel da AWS e procure por VPC. Entre no dashboard de VPC. Por hora, devemos deixar a opção de NAT gateway desativada, vou ativar mais pra frente para evitar custos adicionais enquanto fazemos as configurações básicas.

![Criação da VPC](./arquivos/image-1.png)

## Etapa 2

Antes de criar uma instância da RDS, é necessário criar um grupo de subnets, que é basicamente onde a instância estará disponível. Conforme o diagrama, a instância deverá estar em uma subnet privada isolada. Para isso, basta entrar no dashboard do RDS e selecionar Create DB Subnet Group. A AWS te obriga a criar em duas AZ diferente, portanto, terei de fazer uma sutil alteração do projeto do diagrama. Seu grupo deve ficar conforme a imagem abaixo.

![Criação do subnet group](./arquivos/image-2.png)

Após a criação da VPC, podemos criar o RDS. A configuração é bem simples, você deve ir para o dashboard Aurora e RDS, clicar na opção de criar um database. Na interface de criação, você deve selecionar a opção Standard create e a engine MySQL. Além disso, você deve selecionar a opção free tier. Como a tarefa pediu, selecionei a opção de single-AZ. Após isso, basta configurar as informações do banco de dados. É recomendado utilizar as seguintes variaveis:

- DB instance identifier: wordpress
- Master username: admin
- Master password: DbAtTesteProjeto2
-

Caso você decida alterar essas variáveis será importante alterar no docker-compose em um passo futuro, para garantir que o WordPress seja capaz de se conectar com o banco corretamente.Além disso, você deve usar uma instância do tipo db.t3.micro.

Após isso, você pode selecionar a VPC e o grupo que foram criados anteriormente. Selecione "No" para acesso público e crie um novo security group. 

![Configuração do RDS](./arquivos/image-3.png)

Além disso, você deve configurar o nome do database inicial. Para isso, você deve clicar na aba "Additional configuration" e em "Initial database name" inserir "wordpress"