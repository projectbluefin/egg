kind: make

sources:
- kind: git_repo
  url: github:micheleg/dash-to-dock.git
  track: extensions.gnome.org-v*
  ref: extensions.gnome.org-v101-0-g55489eed868dd42474e383b3fc2f47375de44896

build-depends:
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

variables:
  strip-binaries: ''

depends:
- freedesktop-sdk.bst:components/gettext.bst
- gnome-build-meta.bst:sdk-deps/sassc.bst
- gnome-build-meta.bst:core/gnome-shell.bst

config:
  install-commands:
    - |
      DESTDIR=%{install-root} %{make-install}
