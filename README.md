# Jake Teton-Landis's Dotfiles
Because I need them somewhere.

The VIM distribution that I use, Janus, requires `ruby`, `rake`, `pep8`,
`ctag`, and `ack`. the Janus directory can be used to configure vim
instead if these fancy things aren't availible. Just `ln -s
dotfiles/janus .vim` instead of `ln -s dotfiles/vim .vim`

## Installation

There's a really simple install script in `jark/install.sh` that links
the things in a list into your homedir. You should at least let it link
`zshrc` and `zsh` because if you don't, what's the point?

    $ git clone https://github.com/justjake/Dotfiles ~/.dotfiles
    $ vim ~/.dotfiles/jark/install.sh

... you make your changes to what you want linked ...

    $ zsh ~/.dotfiles/jark/install.sh

## Configuration

Type `hostsettings` to edit your configuration file for this host.

Type `globalsettings` to edit the global zshrc

## Modules

Modules are folders of settings that go someplace other than ~.
For example, my `roxterm` settings should go in
`$HOME/.config/roxterm.sourcecforge.net`.

You can list modules with `dotfile-module-list`, investigate a module
with `dotfile-module-show`, and link/install a module with
`dotfile-module-install`

