#check if the zsh is default shell if not let the user know only works with zsh
passwd="$(grep $USER /etc/passwd)"
USER_SHELL="${passwd##*/}"
if [[ "$USER_SHELL" != "zsh" ]]; then
    echo -e "This script only works with zsh\n If you do not care about what shell you are using, you can change the shell by running chsh -s /bin/zsh and relogin\nExiting now..."
    exit 1
fi

# check if both fzf and kubectl are installed if not let the user know
[[ -z "$(which fzf)" ]] && { echo "fzf is not installed, please install fzf and rerun the script"; exit 1; }
[[ -z "$(which kubectl)" ]] && { echo "kubectl is not installed, please install kubectl and rerun the script"; exit 1; }

mkdir -p "${HOME}/.config/script"

cat > "${HOME}/.config/script/kcon.sh" <<EOF
#!/usr/bin/env zsh 

# kcon hotkey for changing context
kcon(){
	context="$(kubectl config get-contexts --output=name | awk '{print $1}' | fzf --prompt 'Select a Context : ')"
	[[ $? != 0 ]] && { zle reset-prompt; return 1 }
	kubectl config use-context "$context"
	zle reset-prompt
}

zle -N kcon
bindkey '^K' kcon

EOF

chmod +x $HOME/.config/script/kcon.sh
echo 'source <(cat $HOME/.config/script/kcon.sh)' >> $HOME/.zshrc
