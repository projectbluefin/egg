kind: manual

sources:
- kind: local
  path: common/system_files/usr/share/ublue-os/system-setup.hooks.d

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 -t "%{install-root}%{datadir}/system-setup.hooks.d" 10-framework.sh
  - "%{install-extra}"
