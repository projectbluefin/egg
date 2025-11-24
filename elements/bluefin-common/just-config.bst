kind: manual

sources:
- kind: local
  path: common/system_files/usr/share/ublue-os/just

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 -t "%{install-root}%{datadir}/just" 10-update.just
  - "%{install-extra}"
