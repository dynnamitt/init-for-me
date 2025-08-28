#!/usr/bin/make -f

NVIM_APPNAME := lazyv
repo_cache := _config/$(NVIM_APPNAME)
share_cache := _share/$(NVIM_APPNAME)
share_real_path := ~/.local/share/$(NVIM_APPNAME)
conf_real_path := ~/.config/$(NVIM_APPNAME)

.PHONY: clean_dot_git clean relink

relink: $(share_cache)/lazy/LazyVim/init.lua 
	ln -sfv $$PWD/$(repo_cache) $(conf_real_path)
	ln -sfv $$PWD/$(share_cache)/lazy $(share_real_path)
	# kitty
	mkdir -p ~/.config/kitty
	ln -sfv $$PWD/kitty.conf ~/.config/kitty
	ln -sfv $$PWD/kitty-themes ~/.config/kitty

$(share_cache)/lazy/LazyVim/init.lua: $(repo_cache)/init.lua
	@echo "FIRST run ´NVIM_APPNAME=$(NVIM_APPNAME) nvim´ .. and come back to this shell"
	read # allow user exit here
	mkdir -pv $$PWD/$(share_cache)
	# the flip !
	mv -v $(share_real_path)/lazy $(share_cache)
	# call self 
	$(MAKE) -f $(lastword $(MAKEFILE_LIST)) NVIM_APPNAME=$(NVIM_APPNAME) clean_dot_git

$(repo_cache)/init.lua:
	git clone https://github.com/LazyVim/starter $(repo_cache)
	rm -rf $(repo_cache)/.git
	ln -sv $$PWD/$(repo_cache) $(conf_real_path)

clean_dot_git:
	find $(share_cache) -name ".git" -type d -exec echo "Can delete: {}" \;
	@echo "Remove them? (Ctrl+c) to cancel ..."
	read # allow user exit here
	find $(share_cache) -name ".git" -type d -exec rm -rf {} +

clean: 
	rm -rf $(repo_cache) $(share_cache) $(share_real_path) $(conf_real_path)


