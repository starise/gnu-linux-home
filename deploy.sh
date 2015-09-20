#!/bin/bash
# author: starise

APP="GNU/Linux Home"
USER_LANG="it_IT.UTF-8"

HERE="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
SITE_DIRS="/srv/www/*"
VAGRANT_DIR="/vagrant"

RED=`tput setaf 1`
GREEN=`tput setaf 2`
YELLOW=`tput setaf 3`
RESET=`tput sgr0`

case "$1" in
  "run")
    ## Bash configuration files
    if ! cmp ${HERE}/.bash_functions ~/.bash_functions; then
      echo "Installing bash configuration files..."
      cp ${HERE}/{.bashrc,.bash_aliases,.bash_functions} $HOME
    fi

    ## Locale (ubuntu)
    if [ "$LANG" != "$USER_LANG" ]; then
      echo "Installing '$USER_LANG' language pack..."
      sudo apt-get install language-pack-$(echo $USER_LANG | awk '{ string=substr($0, 1, 2); print string; }')
      sudo locale-gen
      if ! grep -Rq "export LANG=" ~/.profile; then
        LANG_EXPORT="\n# Set locale\nexport LANG=\"$USER_LANG\"\nexport LANGUAGE=\"$USER_LANG\""
        echo "Add user locale export in ~/.profile"
        printf "$LANG_EXPORT\n" >> ~/.profile
      fi
    fi

    ## Vagrant environment
    if [ -d ${VAGRANT_DIR} ]; then
      ## Deploy SSH keys
      if [ -d ${VAGRANT_DIR}/.ssh ]; then
        if [ ! -d ~/.ssh ]; then
          echo "Creating ~/.ssh directory (700)..."
          mkdir ~/.ssh && chmod 700 ~/.ssh
        fi
        if ! cmp ${VAGRANT_DIR}/.ssh/id_rsa ~/.ssh/id_rsa; then
          echo "Installing SSH private key 'id_rsa' (600)..."
          cp ${VAGRANT_DIR}/.ssh/id_rsa ~/.ssh/id_rsa && chmod 600 ~/.ssh/id_rsa
        fi
        if ! cmp ${VAGRANT_DIR}/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub; then
          echo "Installing SSH public key 'id_rsa.pub' (644)..."
          cp ${VAGRANT_DIR}/.ssh/id_rsa.pub ~/.ssh/id_rsa.pub && chmod 644 ~/.ssh/id_rsa.pub
        fi
      fi

      ## Create symlinks for sites and related theme
      ls ${SITE_DIRS} -d | while read site; do
        ## Link to web directory
        ln -sfn ${site}/current/web ${HOME}/`basename "$site"`_web
        ## Link 'node_modules' outside shared folder
        if [ ! -d ${site}/node_modules ]; then
          mkdir ${site}/node_modules
        fi
        THEME_PATH="$(find ${site}/current/web/app/themes/* -type f -name 'index.php' -printf '%h' -quit)"
        ln -sfn ${site}/node_modules ${THEME_PATH}/node_modules
      done

      ## Node Version Manager
      if [ ! -d ~/.nvm ] || [ "$1" = "nvm" ]; then
        echo "Installing Node Version Manager..."
        curl -o- https://raw.githubusercontent.com/creationix/nvm/master/install.sh | bash
      fi
    fi

    echo "Deployment completed!"
    echo "${YELLOW}Please type 'source ~/.profile' to make all changes effective.${RESET}"
    ;;
  *|"help")
    echo -e "Usage: deploy.sh [OPTION]\n"
    echo "Option   Description"
    echo "  run    run '$APP' install"
    echo "  help   print this menu"
    ;;
esac
