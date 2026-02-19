kind: manual

depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
  - bluefin/zsh.bst

variables:
  strip-binaries: ""

config:
  install-commands:
    # ── /etc/default/useradd: set zsh as default login shell ──────────────
    - |
      install -dm755 "%{install-root}%{sysconfdir}/default"
      cat > "%{install-root}%{sysconfdir}/default/useradd" << 'EOF'
      GROUP=100
      HOME=/home
      INACTIVE=-1
      EXPIRE=
      SHELL=/usr/bin/zsh
      SKEL=/etc/skel
      CREATE_MAIL_SPOOL=no
      EOF

    # ── /etc/shells: register zsh ─────────────────────────────────────────
    - |
      install -dm755 "%{install-root}%{sysconfdir}"
      printf '/usr/bin/zsh\n/bin/zsh\n' > "%{install-root}%{sysconfdir}/shells"

    # ── /etc/skel/.zshenv: set up PATH before any shell ──────────────────
    - |
      install -dm755 "%{install-root}%{sysconfdir}/skel"
      cat > "%{install-root}%{sysconfdir}/skel/.zshenv" << 'EOF'
      # Sourced for all zsh invocations (login, interactive, script).
      # Keep this minimal — only export environment variables.
      [[ -f "$HOME/.cargo/env" ]] && source "$HOME/.cargo/env"
      EOF

    # ── /etc/skel/.zshrc: interactive shell defaults ──────────────────────
    - |
      cat > "%{install-root}%{sysconfdir}/skel/.zshrc" << 'ZSHRC'
      # Source global definitions
      [[ -f /etc/zshrc ]] && source /etc/zshrc

      # ─── PATH ───────────────────────────────────────────────────────────
      typeset -U path  # deduplicate
      path=($HOME/.local/bin $HOME/bin $path)
      export PATH

      # ─── History ────────────────────────────────────────────────────────
      HISTFILE=~/.zsh_history
      HISTSIZE=50000
      SAVEHIST=50000
      setopt EXTENDED_HISTORY        # write timestamps
      setopt HIST_EXPIRE_DUPS_FIRST  # expire dupes first
      setopt HIST_FIND_NO_DUPS       # no dupe display during search
      setopt HIST_IGNORE_DUPS        # no consecutive dupes
      setopt HIST_IGNORE_SPACE       # skip commands prefixed with space
      setopt HIST_VERIFY             # show history substitution before running
      setopt SHARE_HISTORY           # share across sessions
      setopt INC_APPEND_HISTORY      # write immediately

      # ─── General Options ────────────────────────────────────────────────
      setopt AUTO_CD               # cd by typing a directory name
      setopt AUTO_PUSHD            # track directory history with pushd
      setopt PUSHD_IGNORE_DUPS
      setopt PUSHD_SILENT
      setopt CORRECT               # suggest command corrections
      setopt INTERACTIVE_COMMENTS  # allow # in interactive shell
      setopt NO_BEEP
      setopt EXTENDED_GLOB

      # ─── Completion ─────────────────────────────────────────────────────
      autoload -Uz compinit
      # Regenerate .zcompdump at most once per day
      if [[ -n ${ZDOTDIR:-$HOME}/.zcompdump(#qN.mh+24) ]]; then
          compinit
      else
          compinit -C
      fi

      zstyle ':completion:*' menu select
      zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
      zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
      zstyle ':completion:*' group-name ''
      zstyle ':completion:*:descriptions' format '%F{yellow}── %d ──%f'
      zstyle ':completion:*:warnings' format '%F{red}no matches%f'
      zstyle ':completion:*' squeeze-slashes true
      zstyle ':completion:*' use-cache on
      zstyle ':completion:*' cache-path ~/.zsh/cache

      # ─── Key Bindings ───────────────────────────────────────────────────
      bindkey -e
      bindkey '^[[A' history-search-backward
      bindkey '^[[B' history-search-forward
      bindkey '^[[H' beginning-of-line
      bindkey '^[[F' end-of-line
      bindkey '^[[3~' delete-char
      bindkey '^[[1;5C' forward-word
      bindkey '^[[1;5D' backward-word
      bindkey '^U' backward-kill-line

      # ─── Aliases ────────────────────────────────────────────────────────
      alias grep='grep --color=auto'
      alias mkdir='mkdir -pv'
      alias df='df -h'
      alias du='du -sh'
      alias ..='cd ..'
      alias ...='cd ../..'
      alias ....='cd ../../..'

      # Modern replacements (if installed via brew or elsewhere)
      if command -v eza &>/dev/null; then
          alias ls='eza --icons --group-directories-first'
          alias ll='eza -alh --icons --group-directories-first --git'
          alias lt='eza -alh --icons --tree --level=2'
      else
          alias ls='ls --color=auto'
          alias ll='ls -alh'
      fi

      if command -v bat &>/dev/null; then
          alias cat='bat --paging=never --style=plain'
      fi

      # Git shortcuts
      alias g='git'
      alias gs='git status -sb'
      alias gd='git diff'
      alias gl='git log --oneline --graph --decorate -20'
      alias gp='git push'
      alias gpf='git push --force-with-lease'

      # Container shortcuts
      alias pd='podman'
      alias pps='podman ps --format "table {{.ID}}\t{{.Names}}\t{{.Status}}\t{{.Ports}}"'

      # Systemd shortcuts
      alias sc='systemctl'
      alias scu='systemctl --user'
      alias jc='journalctl'
      alias jcu='journalctl --user'

      # ─── Tool Integrations (gracefully skip if not installed) ────────────
      command -v starship  &>/dev/null && eval "$(starship init zsh)"
      command -v atuin     &>/dev/null && eval "$(atuin init zsh --disable-up-arrow)"
      command -v zoxide    &>/dev/null && eval "$(zoxide init zsh)"
      command -v direnv    &>/dev/null && eval "$(direnv hook zsh)"
      command -v fzf       &>/dev/null && source <(fzf --zsh 2>/dev/null) || true

      # Distrobox shell integration (enter a box by name)
      command -v distrobox &>/dev/null && alias box='distrobox enter'

      # Lazy-load kubectl completion (avoids slow startup)
      if command -v kubectl &>/dev/null; then
          function kubectl() {
              unfunction kubectl
              source <(command kubectl completion zsh)
              command kubectl "$@"
          }
      fi
      ZSHRC
    - "%{install-extra}"
