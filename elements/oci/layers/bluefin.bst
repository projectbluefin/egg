kind: compose

build-depends:
- oci/layers/bluefin-stack.bst

config:
  exclude:
  - debug
  - devel
  - doc
  - extra
  - static-blocklist
