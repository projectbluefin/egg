kind: meson

sources:
- kind: git_repo
  url: gnome_gitlab:chergert/ptyxis.git
  track: 50.beta
  ref: 50.beta-0-g06d46e7f0eed2b3e261044d68e4f602d957c31b8

build-depends:
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- gnome-build-meta.bst:sdk/adwaita-icon-theme.bst

depends:
- gnome-build-meta.bst:core-deps/libgtop.bst
- gnome-build-meta.bst:core-deps/vte.bst
- gnome-build-meta.bst:core/nautilus.bst
- gnome-build-meta.bst:sdk/gtk.bst
- gnome-build-meta.bst:sdk/libadwaita.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

# Changes the application to show "Console" instead of "Ptyxis"
variables:
  meson-local: >-
    -Dgeneric=terminal
