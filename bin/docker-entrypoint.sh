#!/usr/bin/env bash
cd ${WORKDIR-/home/hugo/hugo}
log() { echo "$@" >&2; }
die() { log "$@";exit 1; }
if [[ -n $SDEBUG ]];then set -x;fi
if [[ -z $COMPOSE_UID ]] || [[ -z $COMPOSE_GID ]];then
    die 'set $COMPOSE_UID / $COMPOSE_GID'
fi
usermod -o -g $COMPOSE_GID -u $COMPOSE_UID hugo
while read f;do chown -Rfv $COMPOSE_UID:$COMPOSE_GID "$f";done < \
    <( find ~hugo -not -uid $COMPOSE_GID )
if [[ -z $@ ]];then
    exec gosu hugo bash -lic "nvm use;hugo_extended server --disableFastRender"
elif [[ "$@" == "shell" ]];then
    exec gosu hugo bash -li
else
    exec gosu hugo bash -elic "nvm use;$@"
fi
# vim:set et sts=4 ts=4 tw=80: