# Use a imagem oficial do Elixir como base
FROM elixir:1.15.7 AS builder

# Instale as dependências do sistema
RUN apt-get update && \
    apt-get install -y \
    build-essential \
    inotify-tools \
    postgresql-client

# Configuração do diretório de trabalho
WORKDIR /app

# Cópia dos arquivos de código-fonte
COPY . .

# Instalação das dependências do Mix
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

# Compilação do projeto
RUN mix compile

# Instalação das dependências de teste
RUN mix deps.get --only tests

# Execução dos testes
RUN mix test

# Execução das migrações do banco de dados
RUN mix ecto.setup

# Constrói a aplicação de produção
RUN MIX_ENV=prod mix release

# Etapa final: criação da imagem de produção
FROM erlang:26 AS app

# Configuração do diretório de trabalho
WORKDIR /app

# Cópia do release da aplicação do builder
COPY --from=builder /app/_build/prod/rel/app .

# Porta que a aplicação Phoenix vai ouvir
EXPOSE 4000

# Comando para iniciar a aplicação Phoenix
CMD ["bin/app", "start"]
