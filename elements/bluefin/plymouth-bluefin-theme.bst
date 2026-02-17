kind: manual

sources:
  - kind: local
    path: files/plymouth

runtime-depends:
  - gnome-build-meta.bst:core-deps/plymouth.bst

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

config:
  install-commands:
    - install -Dm644 -t "%{install-root}%{datadir}/pixmaps" bluefin-boot-logo.png
    - install -Dm644 plymouthd.defaults "%{install-root}%{datadir}/plymouth/plymouthd.defaults"
    - install -Dm644 bluefin-boot-logo.png "%{install-root}%{datadir}/plymouth/themes/spinner/watermark.png"
    - "%{install-extra}"

public:
  bst:
    overlap-whitelist:
      - "%{datadir}/plymouth/plymouthd.defaults"
      - "%{datadir}/plymouth/themes/spinner/watermark.png"
