kind: meson

sources:
- kind: git_repo
  url: gnome:nautilus.git
  track: main
  ref: 50.beta-34-g3672ca26c003e514d95b04af7dc99081d423c3fd
- kind: patch
  path: patches/nautilus/open-in-ptyxis.patch

build-depends:
- gnome-build-meta.bst:sdk/blueprint-compiler.bst
- gnome-build-meta.bst:sdk/gobject-introspection.bst
- freedesktop-sdk.bst:components/desktop-file-utils.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

runtime-depends:
- gnome-build-meta.bst:core-deps/xdg-user-dirs-gtk.bst
- gnome-build-meta.bst:sdk/adwaita-icon-theme.bst

depends:
- gnome-build-meta.bst:core-deps/gexiv2.bst
- gnome-build-meta.bst:core-deps/gnome-autoar.bst
- gnome-build-meta.bst:core-deps/libcloudproviders.bst
- gnome-build-meta.bst:core-deps/libportal.bst
# Build dep of tests, and runtime dep otherwise
- gnome-build-meta.bst:core-deps/localsearch.bst
- gnome-build-meta.bst:core/gnome-desktop.bst
- gnome-build-meta.bst:sdk/glib.bst
- gnome-build-meta.bst:sdk/gsettings-desktop-schemas.bst
- gnome-build-meta.bst:sdk/gtk.bst
- gnome-build-meta.bst:sdk/libadwaita.bst
- gnome-build-meta.bst:sdk/libglycin-gtk4.bst
- gnome-build-meta.bst:sdk/pango.bst
- gnome-build-meta.bst:sdk/tinysparql.bst
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- core/ptyxis.bst

variables:
  meson-local: >-
    -Dselinux=false