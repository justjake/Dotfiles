local plugin="$ZSH_FILES/plugins/nvm/nvm.sh"
if [[ -f "$plugin" ]]; then
  source "$plugin"
  [[ -r $NVM_DIR/bash_completion  ]] && . $NVM_DIR/bash_completion
fi
