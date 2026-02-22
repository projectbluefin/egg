kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: tar
    url: github_files:charmbracelet/glow/releases/download/v2.1.1/glow_2.1.1_Linux_x86_64.tar.gz
    ref: 59106b08be69b2a0bda1178327bbb7accd584e7c113ba3d2f5ef6e48ff3ac27f

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
