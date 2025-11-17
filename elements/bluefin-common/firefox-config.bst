kind: manual

sources:
- kind: local
  path: common/system_files/usr/share/ublue-os/firefox-config

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 -t "%{install-root}%{datadir}/firefox-config" 01-bluefin-global.js
  - "%{install-extra}"
