#!/usr/bin/env bash
set -e
HUGO_USER=${HUGO_USER:-hugo}
cd ${WORKDIR-/home/$HUGO_USER/hugo}
log() { echo "$@" >&2; }
die() { log "$@";exit 1; }
HUGO_HOME="$(getent passwd $HUGO_USER| cut -d: -f6)"
HUGO_OLD_UID="$(getent passwd $HUGO_USER| cut -d: -f3)"
HUGO_OLD_GID="$(getent passwd $HUGO_USER| cut -d: -f4)"
export NO_ALL_FIXPERMS=${NO_ALL_FIXPERMS-}
export NO_FIXPERMS=${NO_FIXPERMS-}
SHELL_USER=${SHELL_USER:-$HUGO_USER}
FILES_DIRS="${FILES_DIRS:-"$HUGO_HOME"}"
HUGO_DIRS="${HUGO_DIRS:-"/home"}"
if [[ -n $SDEBUG ]];then set -x;fi
if [[ -z $HUGO_UID ]] || [[ -z $HUGO_GID ]];then
    die 'set $HUGO_UID / $HUGO_GID'
fi
if [[ "${HUGO_OLD_UID}${HUGO_OLD_GID}" != "${HUGO_UID}${HUGO_GID}" ]];then
    usermod -o -g $HUGO_GID -u $HUGO_UID $HUGO_USER
    NO_TRANSFER=
else
    NO_TRANSFER=1
fi
if [[ -z ${NO_ALL_FIXPERMS} ]];then
    if [[ -z "$NO_TRANSFER" ]];then
        while read f;do chown -fv $HUGO_UID:$HUGO_GID "$f";ls -dl $f;exit 1;done < \
            <( find $HUGO_DIRS -uid $HUGO_OLD_UID -or -gid $HUGO_OLD_GID )
    fi
    if [[ -z ${NO_FIXPERMS} ]];then
        while read f;do chown -fv $HUGO_UID:$HUGO_GID "$f";done < \
            <( find $FILES_DIRS -not -uid $HUGO_UID )
    fi
fi
if [[ -z $@ ]];then
    exec gosu $SHELL_USER bash -lic "nvm use;hugo_extended server --disableFastRender"
elif [[ "$@" == "shell" ]];then
    exec gosu $SHELL_USER bash -li
else
    exec gosu $SHELL_USER bash -elic "nvm use;$@"
fi
# vim:set et sts=4 ts=4 tw=80:
