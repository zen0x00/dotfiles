if status is-interactive
    set fish_greeting ""
    fastfetch

    if type -q starship
        starship init fish | source
    end

    fzf --fish | source
    zoxide init fish | source
end

set -x PATH $PATH $HOME/.local/bin
set -x PATH $PATH $HOME/.bun/bin
set -x PATH $PATH $HOME/.spicetify
set -x PATH $PATH $HOME/.local/share/gem/ruby/3.4.0/bin
set -x PATH $PATH /home/aman/.dotnet/tools

alias ls='colorls'
alias vim='nvim'
alias c='clear'
alias clock='tty-clock -C 7 -c'
