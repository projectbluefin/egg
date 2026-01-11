kind: make

sources:
- kind: git_repo
  url: github:icedman/search-light.git
  track: main
  ref: 2070cd42271eae5aebe64045ec9cbbe8a10b74e6

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
- freedesktop-sdk.bst:components/gettext.bst
- gnome-build-meta.bst:core/gnome-shell.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - |
    DESTDIR=%{install-root} %{make-install}
  - |
    %{install-extra}
