kind: manual

sources:
- kind: local
  path: common/system_files/usr/share/ublue-os/user-setup.hooks.d

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 -t "%{install-root}%{datadir}/user-setup.hooks.d" 10-theming.sh
  - install -Dm644 -t "%{install-root}%{datadir}/user-setup.hooks.d" 99-privileged.sh
  - "%{install-extra}"
