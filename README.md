# [@jitl](https://twitter.com/@jitl)'s Dotfiles

Because I need them somewhere.

## Installation

There's a really simple install script in `meta/install.sh` that links
the things in a list into your homedir. 

    $ git clone https://github.com/justjake/Dotfiles ~/.dotfiles

Print out the list of installable configurations:

    $ ~/.dotfiles/meta/install.sh

I usually install like this:

    $ zsh ~/.dotfiles/meta/install.sh submodules dotfiles ssh-config

## Things to Change

There are a few files that have my usernames and email in them. You should
switch them out with your own before you make git commits or something.

* `gitconfig`
* `hgrc`
* `irssi/config`
* `signature`
* `ssh_config`

## Zsh

### Getting started

Try using the TAB key lots. ZSH completions are excellent, and will
semantically complete most commands. You can use the arrow keys to move around
tab-completion menus.

Pressing the up and down arrows after you've typed a partial command will only
move to history items that start with that command. Type `^R` (control-r) to
enter full history search mode.

If you type a bare directory name (eg, `~/.dotfiles`) you will `cd` to it.

Type `hostsettings` to edit your configuration file for this host. Type
`globalsettings` to edit the global zshrc. Type `zshall` to edit the ZSH config
directory.

### Configuration

Zsh configuration is spread across several topical files in `zsh/`. The global
config file `~/.zshrc` loads the rest of the configuration, including a host
specific configuration file at `~/.zsh/hosts/$(hostname -f).zsh`. Here is a list
of a few of the files, and the sort of settings they contain:

* `zshrc`: basic ZSH configuration. Setup of basic env vars like `$EDITOR`, and
  zsh history config. Sources the rest of the configs and the host config
* `zsh/rc.d/01_completion.zsh`: ZSH completion settings. Has SSH host
  completion and shows `...` while completion is happening.
* `zsh/rc.d/02_bundles.zsh`: bundle support, described separately below. Bundles
  in $HOME/bundles are loaded by default. This file is SH-compatible, so you
  can use it from other init scripts.
* `zsh/rc.d/1*`: version control status in `RPS1`, up/down arrows perform history
  search 
* `zsh/rc.d/20_aliases.zsh`: put aliases here. Uses associative arrays to
  create short host-aliases that ssh to the complete hostname. For instance,
  `hal` is aliased to `ssh hal.rescomp.berkeley.edu`. We always call ssh with
  the full hostname instead of an ssh_config host shortname. 

  Also configures some useful settings files aliases. For instance, typing
  `zshrc` will edit ~/.zshrc; typing `sshconfig` will edit ~/.ssh/config
* `zsh/rc.d/21_rescomp.zsh`: settings that are loaded on all ResComp hosts.
* `zsh/rc.d/99_jokes.zsh`: try out `fractal`!

### Bundles

"Bundles" are UNIX PREFIXes: directories that contains a partial (or full) UNIX
[filesystem hierarchy](fhs: http://en.wikipedia.org/wiki/Filesystem_Hierarchy_Standard)

I find bundles to be useful because they allow me to use non-standard software
without having to install it in some sort of centralized, system-wide fashion.
For instance, when I compile my own VIM, I do so with `--prefix=~/bundles/vim`
so that when I install it, it is cleanly separate from the rest of my programs.

Many 3rd party Linux software packages (Firefox, Intellij IDEA, Java, etc) are
distributed in bundle format.  By default `zshrc` will load all the bundles in
`~/bundles`. All you have to do is untar them in ~/bundles and they'll be added
to your path when you next source your .zshrc.

You can use the function `add-bundle-to-path [BUNDLE_PATH]` to add the
directories in the given bundle to your current environment variables. Here are
how various subdirectorys of a bundle are handled:

* `bin`: prepended to `$PATH`, allowing you to run commands in the bundle
* `share/man`: prepended to `$MANPATH`, allowing you to access man pages in
  the bundle
* `lib` and `lib64`: prepended to `$LD_LIBRARY_PATH`, allowing programs to load
  shared libraries from the bundle. This can sometimes cause things to go weird
  when a system program expects version 1.0.0 of a library but ends up loading
  version 1.5.7a2 from one of your bundles.
* `lib/pkgconfig`: prepended to `$PKG_CONFIG_PATH`, allowing autotools and
  `./configure` to find the libraries and headers in the bundle.
* `include`: prepended to `$C_INCLUDE_PATH`
* `usr`: recursed into by a second call to `add-bundle-to-path`


## Vim

Vim uses [Vundle](https://github.com/gmarik/Vundle.vim) for plugin management.

Vim will complain loudly if you don't have Vundle.vim going. Make sure you `git
submodule upate --init` or install with submodules (`meta/install.sh
submodules`) before trying to use it, or download and extract an archive of
Vundle.vim to ~/.vim/bundle/Vundle.

Once you launch Vim for the first time, type `:PluginInstall` to get all the
nifty vim plugins.
