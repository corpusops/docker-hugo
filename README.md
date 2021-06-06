# docker-hugo
- Docker setup for using [hugo](https://gohugo.io/) which also builds this docker image: [corpusops/docker-hugo](https://hub.docker.com/repository/docker/corpusops/hugo/).
- You should certainly be aware of this wonderfull theme: https://github.com/russfeld/ksucs-hugo-theme
- [![.github/workflows/cicd.yml](https://github.com/corpusops/docker-hugo/workflows/.github/workflows/cicd.yml/badge.svg?branch=main)](https://github.com/corpusops/docker-hugo/actions?query=workflow%3A.github%2Fworkflows%2Fcicd.yml+branch%3Amain) 

## Use

- copy the compose setup to your hugo project root:

```sh
cp .env.dist .env
docker-compose build
```

### Run in server mode

```sh
cp .env.dist .env
COMPOSE_GID=$(id -g) COMPOSE_UID=$(id -u) \
    docker-compose up -d
```

### Generate

```sh
COMPOSE_GID=$(id -g) COMPOSE_UID=$(id -u) \
    docker-compose run --rm hugo hugo_extended
```

### shell


```sh
COMPOSE_GID=$(id -g) COMPOSE_UID=$(id -u) \
    docker-compose up -d hugo bash
```

