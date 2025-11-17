kind: manual

sources:
- kind: git_repo
  url: gnome_gitlab:jrahmatzadeh/just-perfection.git
  track: main
  ref: 6da92ad9284c2ccb0232dc8f36a9cfef4d2d0eb2

depends:
- freedesktop-sdk.bst:components/gettext.bst
- gnome-build-meta.bst:core/gnome-shell.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - ./scripts/build.sh -i
  - mkdir -p %{install-root}/usr/share/gnome-shell/extensions/just-perfection-desktop@just-perfection/
  - |
    cp -Rf \
      ~/.local/share/gnome-shell/extensions/just-perfection-desktop@just-perfection \
      %{install-root}/usr/share/gnome-shell/extensions/
  - |
    mkdir -p %{install-root}/usr/share/glib-2.0/schemas
    cp src/schemas/org.gnome.shell.extensions.just-perfection.gschema.xml \
      %{install-root}/usr/share/glib-2.0/schemas/
