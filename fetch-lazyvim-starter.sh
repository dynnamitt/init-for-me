#!/bin/sh
NVIM_APPNAME=lazyv
repo_cache=_config/$NVIM_APPNAME
share_cache=_share/$NVIM_APPNAME

if [ -f $repo_cache/init.lua ]; then
  echo "$repo_cache/ seem to exist, skipping clone "
else
  git clone https://github.com/LazyVim/starter $repo_cache
  rm -rf $repo_cache/.git
  ln -s $(PWD)/$repo_cache $HOME/.config/$NVIM_APPNAME
fi

if [ -d $share_cache/lazy ]; then
  echo "$share_cache seem to have been flipped, aborting "
  exit 1
else
  echo "Now run ´NVIM_APPNAME=$NVIM_APPNAME nvim´ .. and come back to this shell"
  read
  share_path=$HOME/.local/share/$NVIM_APPNAME
  mkdir -pv $(PWD)/$share_cache
  mv -v $share_path/lazy $share_cache
  ln -s $(PWD)/$share_cache/lazy $share_path
fi
