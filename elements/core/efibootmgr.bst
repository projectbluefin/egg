kind: make

sources:
  - kind: git_repo
    url: github:rhboot/efibootmgr
    track: 18
    ref: 18-0-gc3f9f0534e32158f62c43564036878b93b9e0fd6

build-depends:
  - freedesktop-sdk.bst:components/pkg-config.bst
  - freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
  - freedesktop-sdk.bst:components/efivar.bst
  - freedesktop-sdk.bst:components/popt.bst
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  make-args: >-
    sbindir="/usr/bin"
    EFIDIR="bluefin"
