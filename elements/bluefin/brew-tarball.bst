kind: import

sources:
- kind: remote
  url: https://github.com/ublue-os/packages/releases/download/homebrew-2025-11-11-01-29-58/homebrew-x86_64.tar.zst
  ref: 0ccb314083b4b7933fa9c8633c454bca465205797e1261cdf60d665e5e8f516b

runtime-depends:
  - bluefin/brew.bst

config:
  target: /usr/share/homebrew.tar.zst
