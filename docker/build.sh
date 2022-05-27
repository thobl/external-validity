#!/usr/bin/env bash

# todo: clone in the dockerfile itself, once the repo is public
REPO="git@git.scc.kit.edu:scale/research/locality-and-heterogeneity.git"
LOCALREPO="docker/locality-and-heterogeneity/"
if [ ! -d $LOCALREPO ] 
then
    git clone $REPO $LOCALREPO
else
    cd $LOCALREPO
    git pull
    cd -
fi

docker image build -t ext_val docker
