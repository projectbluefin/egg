kind: compose

build-depends:
  - freedesktop-sdk.bst:components/gcc.bst
  - oci/layers/bluefin-runtime.bst

config:
  exclude:
    - debug
    - extra
    - static-blocklist
