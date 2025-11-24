kind: manual

sources:
- kind: local
  path: files/brew

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
  - install -Dm644 -t "%{install-root}%{indep-libdir}/tmpfiles.d" tmpfiles.d/10-homebrew.conf
  - install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system-preset" system-preset/01-homebrew.preset
  - install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system" system/brew-setup.service
  - install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system" system/brew-update.service
  - install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system" system/brew-update.timer
  - install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system" system/brew-upgrade.service
  - install -Dm644 -t "%{install-root}%{indep-libdir}/systemd/system" system/brew-upgrade.timer
  - install -Dm644 -t "%{install-root}%{datadir}/fish/vendor_conf.d" ublue-brew.fish
  - "%{install-extra}"
