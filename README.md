# Public Dotfiles

## Fresh Install

1. Download the git-crypt key from 1Password as `~/key`
2. Download the fresh-install script (to `/tmp`, _not_ your home directory):
    
    ``` bash
    curl -o /tmp/fresh-install.sh https://raw.githubusercontent.com/tammersaleh/dotfiles-public/master/fresh-install.sh
    ```
3. Generate a [new Github fine-grained access token here](https://github.com/settings/personal-access-tokens/new).  Set:

    1. Comment: `Temporary dotfiles token`
    2. Expiration: 7d
    3. Scopes: ✅ `repo`
    4. **Make sure you copy it!**
    
5. Run the script:
    
    ``` bash
    chmod +x fresh-install.sh
    /tmp/fresh-install.sh tammersaleh ghp_token ~/key
    ```
6. Remove the git crypt key: `rm ~/key`

Reboot and pray.
