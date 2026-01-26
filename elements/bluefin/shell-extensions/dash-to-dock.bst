kind: make

sources:
- kind: git_repo
  url: github:micheleg/dash-to-dock.git
  track: extensions.gnome.org-v*
  ref: extensions.gnome.org-v102-0-g69d8bce2f75889fe73037a11abf03de5d77cb137

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
- freedesktop-sdk.bst:components/gettext.bst
- gnome-build-meta.bst:sdk-deps/sassc.bst
- gnome-build-meta.bst:core/gnome-shell.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - |
    DESTDIR=%{install-root} %{make-install}
  - |
    %{install-extra}
