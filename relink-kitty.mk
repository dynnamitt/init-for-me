#!/usr/bin/make -f


.PHONY:  clean relink

relink: 
	# kitty
	mkdir -p ~/.config/kitty
	ln -sv $$PWD/kitty.conf ~/.config/kitty
	ln -sv $$PWD/kitty-themes ~/.config/kitty


clean: 
	rm -rf \
		~/.config/kitty/kitty.conf \
		~/.config/kitty/kitty-themes


