kind: autotools

build-depends:
  - freedesktop-sdk.bst:public-stacks/buildsystem-autotools.bst

depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
  - freedesktop-sdk.bst:bootstrap/ncurses.bst
  - freedesktop-sdk.bst:bootstrap/pcre2.bst

variables:
  strip-binaries: ""
  conf-local: |
    CPPFLAGS="${CPPFLAGS} -DHAVE_BOOLCODES" \
    --enable-multibyte \
    --enable-pcre \
    --enable-cap \
    --with-tcsetpgrp \
    --disable-gdbm

config:
  install-commands:
    (>):
      - rm -f "%{install-root}%{infodir}/dir"

sources:
  - kind: tar
    url: sourceforge:project/zsh/zsh/5.9/zsh-5.9.tar.xz
    ref: 9b8d1ecedd5b5e81fbf1918e876752a7dd948e05c1a0dba10ab863842d45acd5
