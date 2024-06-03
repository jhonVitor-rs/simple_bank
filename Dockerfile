# Use a imagem oficial do Elixir como base
FROM elixir:1.15.7 AS builder

# Defina variáveis de ambiente como argumentos de build
ARG POSTGRES_USER
ARG POSTGRES_PASSWORD
ARG POSTGRES_DB
ARG POSTGRES_DB_TEST
ARG HOSTNAME

# Use as variáveis de ambiente no Dockerfile
ENV POSTGRES_USER=${POSTGRES_USER}
ENV POSTGRES_PASSWORD=${POSTGRES_PASSWORD}
ENV POSTGRES_DB=${POSTGRES_DB}
ENV POSTGRES_DB_TEST=${POSTGRES_DB_TEST}
ENV HOSTNAME=${HOSTNAME}

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

# Copia o script para a imagem e renomeia para entrypoint.sh
COPY entrypoint.sh /usr/local/bin/entrypoint.sh

# Instalação das dependências do Mix
RUN mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get

# Torna o script entrypoint.sh executável
RUN chmod +x /usr/local/bin/entrypoint.sh

# Compilação do projeto
RUN mix compile

CMD [ "/usr/local/bin/entrypoint.sh" ]
