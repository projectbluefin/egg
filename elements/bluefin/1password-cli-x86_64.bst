kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
  - kind: zip
    url: onepassword_cli:v2.32.1/op_linux_amd64_v2.32.1.zip
    ref: 64a49db2d1b0333f3bee88546e3e84995e530e25f2c783fb5d4081d01a05b2a1
    base-dir: ""

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      install -Dm755 -t "%{install-root}%{bindir}" op
    - |
      %{install-extra}
