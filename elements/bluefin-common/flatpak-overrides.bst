kind: manual

sources:
- kind: local
  path: common/system_files/usr/share/ublue-os/flatpak-overrides

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 -t "%{install-root}%{datadir}/flatpak-overrides" io.github.kolunmi.Bazaar
  - "%{install-extra}"
