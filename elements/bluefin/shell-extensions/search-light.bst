kind: make

sources:
- kind: git_repo
  url: github:icedman/search-light.git
  track: main
  ref: 2070cd42271eae5aebe64045ec9cbbe8a10b74e6

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/jq.bst

depends:
- freedesktop-sdk.bst:components/gettext.bst
- gnome-build-meta.bst:sdk/glib.bst
- gnome-build-meta.bst:core/gnome-shell.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - |
    %{make}

    _uuid="$(jq -r .uuid metadata.json)"
    install -d "%{install-root}/usr/share/gnome-shell/extensions/${_uuid}"
    cp -R ./* "%{install-root}/usr/share/gnome-shell/extensions/${_uuid}/"
  - |
    %{install-extra}
