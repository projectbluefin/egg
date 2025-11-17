kind: manual

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - mkdir -p "%{install-root}%{datadir}/glib-2.0/schemas/"
  - |
    cat <<EOF > "%{install-root}%{datadir}/glib-2.0/schemas/zz3-bluefin-unsupported-stuff.gschema.override"
    [org.gnome.shell]
    disable-extension-version-validation=true
    EOF

  - "%{install-extra}"
