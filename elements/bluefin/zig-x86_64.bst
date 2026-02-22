kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ""

sources:
  - kind: tar
    url: ziglang:download/0.14.1/zig-x86_64-linux-0.14.1.tar.xz
    ref: 24aeeec8af16c381934a6cd7d95c807a8cb2cf7df9fa40d359aa884195c4716c

config:
  install-commands:
    - |
      install -Dm755 zig "%{install-root}%{bindir}/zig"
      mkdir -p "%{install-root}%{libdir}/zig"
      cp -a lib/* "%{install-root}%{libdir}/zig/"
