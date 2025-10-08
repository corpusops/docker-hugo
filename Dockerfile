ARG RSYNC=corpusops/rsync
ARG HUGO_BASE_IMAGE="corpusops/ubuntu:22.04-2.17"
FROM $HUGO_BASE_IMAGE AS base
ENV PATH=/w/node_modules/.bin:$COPS_ROOT/bin:$PATH
FROM base AS final
ARG GITHUB_PAT="NTA2N2MxYTQzNDgzOGRkYzZkZTczZTZlNjljZTFkNGEzNWZjMWMxOAo="
ARG HUGO_RELEASE="latest"
ARG PKG="gohugoio/hugo"
ARG URI="https://api.github.com/repos/$PKG/releases"
RUN set -e \
  && cd /tmp \
  && arch=$( uname -m|sed -re "s/x86_64/amd64/g" ) \
  && if !( echo $HUGO_RELEASE|grep -E -q ^latest$ );then URI="$URI/tags";fi  \
  && curl -sH "Authorization: token $(echo $GITHUB_PAT|base64 -d)" "$URI/$HUGO_RELEASE" \
  | grep browser_download_url | cut -d '"' -f 4 \
  | grep -E -i "($(uname -s)-64.*gz|checksum)">hugo_data \
  && cat hugo_data|while read f;do wget -c $f;done \
  && grep -E -i "($(uname -s)-64.*gz)" *checksum* | while read f;do \
    printf "$f\n" | sha256sum -c; \
    tar xzvf $(echo $f|awk '{print $2}');\
    b=hugo; \
    if ( echo $f|grep -q extend );then b=hugo_extended;fi; \
    mv -vf hugo /bin/$b; \
  done \
  && rm -rfv *
ADD /apt.txt ./
RUN if ! (python3 -c "import sqlalchemy");then apt update && apt install -y $(grep -E -v '^#' apt.txt);fi
ADD /requirements.txt ./
RUN if ! (python3 -c "import sqlalchemy");then python3 -m pip install -r requirements.txt;fi
# Final cleanup, only work if using the docker build --squash option
ARG DEV_DEPENDENCIES_PATTERN='^#\s*dev dependencies'
RUN \
  set -e \
  && if !( getent group hugo );then \
    sed -i -re "s/(python-?)[0-9]\.[0-9]+/\1$PY_VER/g" apt.txt \
    && if $(grep -E -q "${DEV_DEPENDENCIES_PATTERN}" apt.txt);then \
      apt-get remove --auto-remove --purge \
        $(sed "1,/${DEV_DEPENDENCIES_PATTERN}/ d" apt.txt|grep -v '^#'|tr "\n" " ");\
    fi \
    && rm -rf /var/lib/apt/lists/*; \
  fi
ARG NVM_RELEASE="latest"
ARG NVMURI="https://api.github.com/repos/nvm-sh/nvm/releases"
RUN set -e \
  && if !( echo $NVM_RELEASE|grep -E -q ^latest$ );then NVMURI="$NVMURI/tags";fi  \
  && curl -sH "Authorization: token $(echo $GITHUB_PAT|base64 -d)" "$NVMURI/$NVM_RELEASE"|grep tag_name|cut -d '"' -f 4 > t \
  && curl -sL https://raw.githubusercontent.com/nvm-sh/nvm/$(cat t)/install.sh -o /bin/install_nvm.sh
RUN set -e \
  && if !( getent group hugo  2>/dev/null);then groupadd -g 1000 hugo;fi \
  && if !( getent passwd hugo 2>/dev/null);then useradd -m -u 1000 -g 1000 hugo;fi
USER hugo
WORKDIR /home/hugo
RUN bash -lc "bash /bin/install_nvm.sh\
    && if ( grep -q nvm .bash_profile ) && ! ( grep -q nvm .profile );then \
        grep -p nvm .profile >> .bash_profile;\
    fi"
RUN bash -ilc ": verify nvm is loaded && nvm --version"
ADD --chown=hugo:hugo .nvmrc ./
RUN bash -ilc 'nvm install $(cat .nvmrc)'
ADD --chown=hugo:hugo package.json package*json ./
RUN bash -elic 'nvm use && npm ci'
ADD /bin/docker-entrypoint.sh /

# SQUASH Stage
FROM $RSYNC AS squashed-rsync
FROM base AS squashed-ancestor
WORKDIR /home/hugo
ARG ROOTFS="/BASE_ROOTFS_TO_COPY_THAT_WONT_COLLIDE_1234567890"
ARG PATH="${ROOTFS}_rsync/bin:$PATH"
RUN --mount=type=bind,from=final,target=$ROOTFS --mount=type=bind,from=squashed-rsync,target=${ROOTFS}_rsync \
rsync -Aaz --delete ${ROOTFS}/ / --exclude=/proc --exclude=/sys --exclude=/etc/resolv.conf --exclude=/etc/hosts --exclude=$ROOTFS* --exclude=dev/shm --exclude=dev/pts --exclude=dev/mqueue
USER root
ENTRYPOINT ["/docker-entrypoint.sh"]
