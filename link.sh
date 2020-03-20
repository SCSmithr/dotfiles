#!/usr/bin/env bash
# Symlink files to where they're expected to be found

DIR="$(pwd)"

# bash
ln -sv $DIR/bash/bashrc ~/.bashrc

# xmonad
mkdir -p ~/.xmonad/lib
ln -sv $DIR/xmonad/*.hs ~/.xmonad
ln -sv $DIR/xmonad/lib/*.hs ~/.xmonad/lib

# xmobar
ln -sv $DIR/xmobar/xmobarrc ~/.xmobarrc

# bin/scripts
mkdir -p ~/.bin
ln -sv $DIR/bin/* ~/.bin

# various x stuff
ln -sv $DIR/x/xinitrc ~/.xinitrc
ln -sv $DIR/x/xmodmap ~/.xmodmap
ln -sv $DIR/x/Xresources ~/.Xresources

# redshift
mkdir -p ~/.config/redshift
ln -sv $DIR/redshift/redshift.conf ~/.config/redshift

# dunst
mkdir -p ~/.config/dunst
ln -sv $DIR/dunst/dunstrc ~/.config/dunst

# gtk
mkdir -p ~/.config/gtk-3.0
ln -sv $DIR/gtk/settings.ini ~/.config/gtk-3.0
ln -sv $DIR/gtk/gtkrc-2.0 ~/.gtkrc-2.0

# alacritty
mkdir -p ~/.config/alacritty
ln -sv $DIR/alacritty/alacritty.yml ~/.config/alacritty

# zathura
ln -sv $DIR/zathura/zathurarc ~/.config/zathura

# readline
ln -sv $DIR/readline/inputrc ~/.inputrc

# fonts
mkdir -p ~/.config/fontconfig
ln -sv $DIR/fontconfig/fonts.conf ~/.config/fontconfig

# git
ln -sv $DIR/git/gitconfig ~/.gitconfig
ln -sv $DIR/git/gitignore ~/.gitignore

# emacs
mkdir -p ~/.emacs.d
ln -sv $DIR/emacs/* ~/.emacs.d
mkdir -p ~/.emacs.d/straight/versions/
ln -sv $DIR/emacs/default.el ~/.emacs.d/straight/versions

