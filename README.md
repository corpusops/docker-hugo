# docker-hugo setup
- Docker setup for using [hugo](https://gohugo.io/) which also builds this docker image: [corpusops/docker-hugo](https://hub.docker.com/repository/docker/corpusops/hugo/).
- You should certainly be aware of this wonderfull theme: https://github.com/russfeld/ksucs-hugo-theme
- [![.github/workflows/cicd.yml](https://github.com/corpusops/docker-hugo/workflows/.github/workflows/cicd.yml/badge.svg?branch=main)](https://github.com/corpusops/docker-hugo/actions?query=workflow%3A.github%2Fworkflows%2Fcicd.yml+branch%3Amain)

## Use
- Integrate the compose setup to your hugo project root:

```sh
git submodule add https://github.com/corpusops/docker-hugo.git local/docker-hugo
ln -fs local/docker-hugo/docker-compose.yml
cp local/docker-hugo/.env.dist .env.dist
cp .env.dist .env
echo .env >> .gitignore
git add .env.dist docker-compose.yml
$EDITOR .env
docker-compose build
```

## Run with docker-compose
## server
```sh
cp .env.dist .env
HUGO_GID=$(id -g) HUGO_UID=$(id -u) \
    docker-compose up -d
```

### Generate
```sh
HUGO_GID=$(id -g) HUGO_UID=$(id -u) \
    docker-compose run --rm hugo hugo_extended
```

## shell
```sh
HUGO_GID=$(id -g) HUGO_UID=$(id -u) \
    docker-compose up -d hugo bash
```

### Run with docker
## server
```sh
docker run -it --rm \
	-e HUGO_UID=$(id -u) -e HUGO_GID=$(id -g)  \
	-v $PWD:/home/hugo/hugo corpusops/hugo
```

### Generate
```sh
docker run -it --rm \
	-e HUGO_UID=$(id -u) -e HUGO_GID=$(id -g)  \
	-v $PWD:/home/hugo/hugo corpusops/hugo hugo_extended
```

### shell
```sh
docker run -it --rm \
	-e HUGO_UID=$(id -u) -e HUGO_GID=$(id -g)  \
	-v $PWD:/home/hugo/hugo corpusops/hugo bash
```
