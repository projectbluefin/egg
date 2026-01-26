kind: meson

sources:
- kind: git_repo
  url: github:ubuntu/gnome-shell-extension-appindicator.git
  track: v*
  ref: v61-0-g7d1e2c827d33f59cfad65be57c00257a1595b5a8

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst
- freedesktop-sdk.bst:components/jq.bst

depends:
- freedesktop-sdk.bst:components/gettext.bst
- gnome-build-meta.bst:core/gnome-shell.bst

variables:
  strip-binaries: ''
