kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: tar
    url: github_files:charmbracelet/gum/releases/download/v0.17.0/gum_0.17.0_Linux_x86_64.tar.gz
    ref: 69ee169bd6387331928864e94d47ed01ef649fbfe875baed1bbf27b5377a6fdb

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" gum
    - |
      install -Dm644 -t "%{install-root}%{datadir}/bash-completion/completions" completions/gum.bash
      install -Dm644 -t "%{install-root}%{datadir}/zsh/site-functions" completions/gum.zsh
      install -Dm644 -t "%{install-root}%{datadir}/fish/vendor_completions.d" completions/gum.fish
    - |
      install -Dm644 -t "%{install-root}%{datadir}/man/man1" manpages/gum.1.gz
    - |
      %{install-extra}
