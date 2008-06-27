#!/bin/bash
#
 
REMOTE_USER="root"
 
err(){
    echo "ERROR: ${1} Aborting..."
    exit 1
}
 
installkeyat(){
    if [ -n "${1}" ];then
        REMOTE_HOST="${1}"
    else
        err "1st argument should be the remote hostname."
    fi
 
    if [ -n "${2}" ];then
        REMOTE_USER="${2}"
    else
        REMOTE_USER="root"
    fi
 
    [ -d "~/.ssh" ] || mkdir -p ~/.ssh
    if [ ! -f ~/.ssh/id_dsa.pub ];then
        echo "Local SSH key does not exist. Creating..."
        echo "JUST PRESS ENTER WHEN ssh-keygen ASKS FOR A PASSPHRASE!"
        echo ""
        ssh-keygen -t dsa -f ~/.ssh/id_dsa
 
        [ $? -eq 0 ] || err "ssh-keygen returned errors!"
    fi
 
    [ -f ~/.ssh/id_dsa.pub ] || err "unable to create a local SSH key!"
 
 
    while true; do
        echo -n "Install my local SSH key at ${REMOTE_HOST} (Y/n) "
        read yn
        case $yn in
            "y" | "Y" | "" )
                echo "Local SSH key present, installing remotely..."
                cat ~/.ssh/id_dsa.pub | ssh ${REMOTE_USER}@${REMOTE_HOST} "if [ ! -d ~${REMOTE_USER}/.ssh ];then mkdir -p ~${REMOTE_USER}/.ssh ; fi && if [ ! -f ~${REMOTE_USER}/.ssh/authorized_keys2 ];then touch ~${REMOTE_USER}/.ssh/authorized_keys2 ; fi &&  sh -c 'cat - >> ~${REMOTE_USER}/.ssh/authorized_keys2 && chmod 600 ~${REMOTE_USER}/.ssh/authorized_keys2'"
                [ $? -eq 0 ] || err "ssh returned errors!"
             break ;;
            "n" | "N" ) echo -n "" ; break ;;
            * ) echo "unknown response.  Asking again" ;;
        esac
    done
}
 
installkeyat ${1} ${2}
