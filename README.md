# Public Dotfiles

## Install

Prep

``` console
$ brew install stow git git-lfs git-crypt
$ mkdir -p ~/dotfiles
$ cd dotfiles
$ USER=tammersaleh # or whatever
$ TOKEN=OMGSEKRIT # from https://github.com/settings/tokens
```

Install the public repo (this one):

``` console
$ git clone https://${USER}:${TOKEN}@github.com/tammersaleh/dotfiles-public.git public
$ (cd public && git-lfs fetch && git-lfs checkout)
```

Copy the private key from "somewhere", and install the private repo:

``` console
$ git clone https://${USER}:${TOKEN}@github.com/tammersaleh/dotfiles-private.git private
$ (cd private && git crypt unlock /path/to/key)
$ ./public/bin/dotfiles install
```

Reboot and pray.
