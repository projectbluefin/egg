# straight dump of all the files
# FIXME: split them like the brew config
kind: manual

sources:
- kind: local
  path: files/dump

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
#   - install -Dm644 -t "%{install-root}%{sysconfdir}/" etc/*
#   - install -Dm644 -t "%{install-root}%{sysconfdir}/" etc/*
  - cp -r usr/ "%{install-root}%{prefix}/"
  - cp -r etc/ "%{install-root}%{sysconfdir}/"
  - "%{install-extra}"
