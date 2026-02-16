kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: zip
    url: onepassword_cli:v2.32.1/op_linux_arm64_v2.32.1.zip
    ref: cf6d114b12079ba5ac4f3ea6c69d331c06565c361aeae77f8c20868bd94c9885
    base-dir: ""

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" op
    - |
      %{install-extra}
