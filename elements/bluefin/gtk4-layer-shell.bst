kind: meson

build-depends:
  - freedesktop-sdk.bst:public-stacks/buildsystem-meson.bst

depends:
  - gnome-build-meta.bst:sdk/gtk.bst
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: tar
    url: github_files:wmww/gtk4-layer-shell/archive/refs/tags/v1.1.0.tar.gz
    ref: 98284281260a5eef5b4f63a55f16c4bf6a788a1020a6db037ecb0f71fa336988

variables:
  meson-local: >-
    -Dexamples=false
    -Dintrospection=false
    -Dvapi=false
