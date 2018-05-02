# Public Dotfiles

## Install

```
brew install git git-lfs git-crypt
mkdir -p ~/code/tammersaleh/dotfiles
cd ~/code/tammersaleh/dotfiles
git clone https://tsaleh:${TOKEN}@github.com/tammersaleh/dotfiles-public.git public
git clone https://tsaleh:${TOKEN}@github.com/tammersaleh/dotfiles-private.git private
cd private
git lfs unlock /path/to/key
./public/bin/dotfiles install
```
