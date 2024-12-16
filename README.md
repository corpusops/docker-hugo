# docker-hugo setup

DISCLAIMER
============

**UNMAINTAINED/ABANDONED CODE / DO NOT USE**

Due to the new EU Cyber Resilience Act (as European Union), even if it was implied because there was no more activity, this repository is now explicitly declared unmaintained.

The content does not meet the new regulatory requirements and therefore cannot be deployed or distributed, especially in a European context.

This repository now remains online ONLY for public archiving, documentation and education purposes and we ask everyone to respect this.

As stated, the maintainers stopped development and therefore all support some time ago, and make this declaration on December 15, 2024.

We may also unpublish soon (as in the following monthes) any published ressources tied to the corpusops project (pypi, dockerhub, ansible-galaxy, the repositories).
So, please don't rely on it after March 15, 2025 and adapt whatever project which used this code.



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
