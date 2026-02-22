kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

runtime-depends:
  - bluefin/brew.bst

sources:
  - kind: remote
    url: github_files:ublue-os/packages/releases/download/homebrew-2026-02-17-01-32-11/homebrew-aarch64.tar.zst
    ref: 08813d100ff0f69c57038b1d397e641789701e0ca109200e1377473cd7bad001
variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      mkdir -p "%{install-root}%{datadir}"
      mv homebrew-aarch64.tar.zst "%{install-root}%{datadir}/homebrew.tar.zst"
    - |
      %{install-extra}
