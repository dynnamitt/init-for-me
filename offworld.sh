#!/bin/bash

# curl only tgz from github or CACHE
GH_PRE=${GH_PRE:-https://github.com}

# mac-hacks
if [[ "$OSTYPE" == "darwin"* ]]; then
    alias tar=gtar
    alias awk=gawk
fi

curl_untar(){
  TMP_FILE=$(mktemp)
  curl -sL "$1" > $TMP_FILE
  mkdir -vp $2
  tar -xvzf $TMP_FILE --strip-component=1 -C "$2"
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

# ts_grammar <lang@ref> <dest-dir>
ts_grammar(){
    LANG_REF=$1
    lang=${1%@*}
    DEST=$2
    TEMP_DIR=$(mktemp -d)
    gh_cache_fetch "tree-sitter/tree-sitter-$LANG_REF" $TEMP_DIR

    currdir=$PWD
    echo "Entering TEMPDIR = $TEMP_DIR"
    cd $TEMP_DIR
    
    tree-sitter generate
    cd $currdir

    # Build the shared library
    tree-sitter build $TEMP_DIR --output "$DEST/$lang.so"

    [ ! -d $DEST ] && mkdir -pv $DEST
    echo "Installed to: $DEST"
    cd $currdir
}
