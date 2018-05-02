# Public Dotfiles

## Install

```
brew install git git-lfs git-crypt
mkdir -p ~/code/tammersaleh/dotfiles
cd ~/code/tammersaleh/dotfiles
git clone https://tsaleh:${TOKEN}@github.com/tammersaleh/dotfiles-public.git public
git clone https://tsaleh:${TOKEN}@github.com/tammersaleh/dotfiles-private.git private
(cd private && git crypt unlock /path/to/key)
(cd public && git-lfs fetch && git-lfs checkout)
./public/bin/dotfiles install
```
