kind: manual

sources:
- kind: git_repo
  url: github:projectbluefin/common.git
  track: main
  ref: v2026.01-61-gbf18df7ce7d2276587f1137f258b49ada6d833c4
- kind: git_module
  url: github:projectbluefin/branding/
  path: bluefin_branding 
  ref: f5213ca61615bb79a8315fc4c5378a80ca93922e

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

config:
  install-commands:
#   - install -Dm644 -t "%{install-root}%{sysconfdir}/" etc/*
#   - install -Dm644 -t "%{install-root}%{sysconfdir}/" etc/*
  - cp -r system_files/bluefin/usr/ "%{install-root}%{prefix}/"
  - cp -r system_files/shared/usr/ "%{install-root}%{prefix}/"
  - cp -r system_files/bluefin/etc/ "%{install-root}%{sysconfdir}/"
  - cp -r system_files/shared/etc/ "%{install-root}%{sysconfdir}/"
  - cp -r bluefin_branding/system_files/etc/ "%{install-root}%{sysconfdir}/"
  - "%{install-extra}"
