# Bash initialization for interactive non-login shells and
# for remote shells (info "(bash) Bash Startup Files").

# Export 'SHELL' to child processes.  Programs such as 'screen'
# honor it and otherwise use /bin/sh.
export SHELL

if [[ $- != *i* ]]
then
    # We are being invoked from a non-interactive shell.  If this
    # is an SSH session (as in "ssh host command"), source
    # /etc/profile so we get PATH and other essential variables.
    [[ -n "$SSH_CLIENT" ]] && source /etc/profile

    # Don't do anything else.
    return
fi

# Source the system-wide file.
source /etc/bashrc

# Adjust the prompt depending on whether we're in 'guix environment'.
if [ -n "$GUIX_ENVIRONMENT" ]
then
    PS1='\u@\h \w [env]\$ '
else
    PS1='\u@\h \w\$ '
fi
alias ls='ls -p --color=auto'
alias ll='ls -l'
alias grep='grep --color=auto'

alias cp='cp -i'
alias mv='mv -i'
alias rm='rm -i'

# ssh-agent
if [ -e ${HOME}/.ssh-agent ]
then
    . ${HOME}/.ssh-agent
fi

# 全员wayland
export WLR_XWAYLAND="/fuckxorg"
export GDK_BACKEND=wayland
export QT_QPA_PLATFORM=wayland
export MOZ_ENABLE_WAYLAND=1

# 用户特定配置
if [ -e ${HOME}/.bashrc.user ]
then
    . ${HOME}/.bashrc.user
fi

# 同一个用户组的用户可以访问luhui的Wayland Server
if [ $(id -u -n) == "luhui" ]
then
    mkdir -p /tmp/user
    chmod 0770 /tmp/user
    export XDG_RUNTIME_DIR=/tmp/user/luhui
    mkdir -p /tmp/user/luhui
    chmod 0770 /tmp/user/luhui
else
    if [ -z ${XDG_RUNTIME_DIR} ]
    then
        export XDG_RUNTIME_DIR=/tmp/xdg_runtime_dir-$(id -u)/
    fi
    mkdir -p ${XDG_RUNTIME_DIR}
    export WAYLAND_DISPLAY="wayland-0"
    ln -sf /tmp/user/luhui/wayland-0 ${XDG_RUNTIME_DIR}/${WAYLAND_DISPLAY}
fi

# 如果拥有emacs则设定EDITOR为emacs
if (type emacsclient &> /dev/null)
then
    export EDITOR='emacsclient -nw'
else
    export EDITOR='vi'
fi

# 打印用户的 MOTD
if [ -e ${HOME}/.motd ]
then
    cat ${HOME}/.motd
    printf "\n"
fi

eval "$(direnv hook bash)"

