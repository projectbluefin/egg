kind: manual

sources:
- kind: local
  path: common/system_files/usr/share/ublue-os/motd

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 -t "%{install-root}%{datadir}/motd/tips" tips/10-tips.md
  - install -Dm644 -t "%{install-root}%{datadir}/motd" template.md
  - "%{install-extra}"
