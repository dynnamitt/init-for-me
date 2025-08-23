#!/bin/bash

# curl only tgz from github or CACHE
GH_PRE=${GH_PRE:-https://github.com}

# mac-hacks
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias tar=gtar
  alias awk=gawk
fi

curl_untar(){
  mkdir -p $2
  curl -sL "$1" |\
    gtar -xvzf - --strip-component=1 -C "$2"
}

# gh_cache_fetch <github_repo@ref> <dest-dir>
gh_cache_fetch() {
  mkdir -p $2
  if echo $1|grep -q "@";then
    repo=${1%@*}
    ref=${1#*@}

    # maybe needed
    if [ $ref != "main" ] && [ $ref != "master" ];then
      r_pre="refs/tags/"
    fi
      
    curl_untar $GH_PRE/$repo/archive/${r_pre}${ref}.tar.gz $2
  else
    echo "No REF given in arg1 <github_repo@REF>"
  fi
}

