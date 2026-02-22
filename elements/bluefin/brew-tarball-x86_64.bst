kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

runtime-depends:
  - bluefin/brew.bst

sources:
  - kind: remote
    url: github_files:ublue-os/packages/releases/download/homebrew-2026-02-17-01-32-11/homebrew-x86_64.tar.zst
    ref: f110e191eecd481cf4c5e984fd463f3c5b0ee92006ff88402385caa03db72ad6
variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      mkdir -p "%{install-root}%{datadir}"
      mv homebrew-x86_64.tar.zst "%{install-root}%{datadir}/homebrew.tar.zst"
    - |
      %{install-extra}
