kind: manual

sources:
- kind: local
  path: common/system_files/usr/share/ublue-os/privileged-setup.hooks.d

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 -t "%{install-root}%{datadir}/privileged-setup.hooks.d" 10-tailscale.sh
  - install -Dm644 -t "%{install-root}%{datadir}/privileged-setup.hooks.d" 99-flatpaks.sh
  - "%{install-extra}"
