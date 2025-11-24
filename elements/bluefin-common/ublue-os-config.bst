kind: manual

sources:
- kind: local
  path: common/system_files/etc/ublue-os

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 -t "%{install-root}%{sysconfdir}/" bling.json
  - install -Dm644 -t "%{install-root}%{sysconfdir}/" fastfetch.json
  - install -Dm644 -t "%{install-root}%{sysconfdir}/" setup.json
  - "%{install-extra}"
