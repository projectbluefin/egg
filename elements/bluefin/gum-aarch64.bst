kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: tar
    url: github_files:charmbracelet/gum/releases/download/v0.17.0/gum_0.17.0_Linux_arm64.tar.gz
    ref: b0b9ed95cbf7c8b7073f17b9591811f5c001e33c7cfd066ca83ce8a07c576f9c

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
