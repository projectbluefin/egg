kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: tar
    url: github_files:charmbracelet/glow/releases/download/v2.1.1/glow_2.1.1_Linux_arm64.tar.gz
    ref: ab12a703cc6efd06caf24860344a2e8bc2518055fdd986f98eb761c47917ef3d

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" glow
    - |
      install -Dm644 -t "%{install-root}%{datadir}/bash-completion/completions" completions/glow.bash
      install -Dm644 -t "%{install-root}%{datadir}/zsh/site-functions" completions/glow.zsh
      install -Dm644 -t "%{install-root}%{datadir}/fish/vendor_completions.d" completions/glow.fish
    - |
      install -Dm644 -t "%{install-root}%{datadir}/man/man1" manpages/glow.1.gz
    - |
      %{install-extra}
