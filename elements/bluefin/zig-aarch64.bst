kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

sources:
  - kind: tar
    url: ziglang:download/0.14.1/zig-aarch64-linux-0.14.1.tar.xz
    ref: f7a654acc967864f7a050ddacfaa778c7504a0eca8d2b678839c21eea47c992b

config:
  install-commands:
    - |
      install -Dm755 zig "%{install-root}%{bindir}/zig"
      mkdir -p "%{install-root}%{libdir}/zig"
      cp -a lib/* "%{install-root}%{libdir}/zig/"
