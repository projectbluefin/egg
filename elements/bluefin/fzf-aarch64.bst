kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: tar
    url: github_files:junegunn/fzf/releases/download/v0.67.0/fzf-0.67.0-linux_arm64.tar.gz
    ref: 7071f48c2ac0f2bc992d6d33cc36fd675a579a98cc976dda699eea07dd5e9c58
    base-dir: ""

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" fzf
    - |
      %{install-extra}
