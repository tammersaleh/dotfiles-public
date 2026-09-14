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
7. On a CoreWeave machine, pull work secrets into the login keychain:

    ``` bash
    op signin --account coreweave.1password.com
    secrets-sync
    ```

    Shells read them from the keychain on startup (`~/.zsh/d/secrets.zsh`).
    Rerun `secrets-sync` after rotating any credential.

Reboot and pray.
