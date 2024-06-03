# Simple Bank

O Simple Bank é uma aplicação backend construída com Phoenix e PostgreSQL, containerizada com Docker para facilitar a execução e o desenvolvimento.

## Pré-requisitos

Para rodar esta aplicação, você precisará ter o Docker instalado em sua máquina. Acredito que a melhor instrução para a instalação do mesmo você encontrara na [documentação oficial do Docker](https://docs.docker.com/engine/install/).

## Executando a aplicação

Com o Docker instalado, você pode iniciar a aplicação com o seguinte comando:

```bash
docker-compose up
```
Isso irá subir o serviço do Phoenix na porta 4000 e o serviço do PostgreSQL.

## Acessando a aplicação

Após iniciar a aplicação, você pode acessar a API no seguinte endereço:
```bash
http://localhost:4000/api
```

Para acessar a documentação Swagger da API, use:
```bash
http://localhost:4000/api/swagger
```

## Funcionalidades

- **Cadastro de Usuários**: Os usuários podem se cadastrar na aplicação.

- **Contas**: Cada usuário pode ter de 1 a 2 contas dos tipos:
  - **Corrente (cahin)**: Para o dia a dia.
  - **Poupança (saving)**: Para economizar.
  - **Salário (wage)**: Para receber o salário.

  Nota: É possível ter uma conta de cada tipo, mas não é possível ter conta salário e conta corrente ao mesmo tempo.

- **Operações**:
  - **Transferências (transfer)**: Disponíveis entre contas.
  - **Depósito (deposit)** e **Saque (withdraw)**: Disponíveis para contas corrente e poupança.
  - **Saque (withdraw)**: Disponível para conta salário.


## Desenvolvimento

Este projeto foi inspirado em um desafio do PicPay e aprimorado com base no conhecimento adquirido em Elixir. Algumas funcionalidades e regras extras foram adicionadas para testar as habilidades no desenvolvimento com Phoenix.

Contribuições são bem-vindas!!!

