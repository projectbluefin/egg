kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: tar
    url: github_files:junegunn/fzf/releases/download/v0.67.0/fzf-0.67.0-linux_amd64.tar.gz
    ref: 4be08018ca37b32518c608741933ea335a406de3558242b60619e98f25be2be1
    base-dir: ""

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" fzf
    - |
      %{install-extra}
