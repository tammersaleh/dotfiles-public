# Public Dotfiles

## Fresh Install

1. Download the git-crypt key from 1Password and store in ~/key
2. Download the fresh-install script:
    
    ```
    curl -O https://raw.githubusercontent.com/tammersaleh/dotfiles-public/master/fresh-install.sh
    ```
3. Generate a new Github fine-grained access token here: https://github.com/settings/personal-access-tokens/new

    1. Named `Temporary dotfiles token`
    2. Select 7d expiration
    3. `repo` scope
    4. MAKE SURE YOU COPY IT
    
5. Run the script:
    
    ```
    chmod +x fresh-install.sh
    ./fresh-install.sh tammersaleh gh_token_string ~/key
    ```
6. Remove the git crypt key: `rm ~/key`

Reboot and pray.
