#!/usr/bin/env bash
cd ${WORKDIR-/home/hugo/hugo}
log() { echo "$@" >&2; }
die() { log "$@";exit 1; }
if [[ -n $SDEBUG ]];then set -x;fi
if [[ -z $HUGO_UID ]] || [[ -z $HUGO_GID ]];then
    die 'set $HUGO_UID / $HUGO_GID'
fi
usermod -o -g $HUGO_GID -u $HUGO_UID hugo
while read f;do chown -Rfv $HUGO_UID:$HUGO_GID "$f";done < \
    <( find ~hugo -not -uid $HUGO_UID )
if [[ -z $@ ]];then
    exec gosu hugo bash -lic "nvm use;hugo_extended server --disableFastRender"
elif [[ "$@" == "shell" ]];then
    exec gosu hugo bash -li
else
    exec gosu hugo bash -elic "nvm use;$@"
fi
# vim:set et sts=4 ts=4 tw=80:
