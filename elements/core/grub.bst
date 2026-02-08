kind: autotools

sources:
  - kind: git_repo
    url: https://git.savannah.gnu.org/git/grub.git
    track: grub-*
    ref: grub-2.14-rc1-0-g280715ec63a3424f5cf1289302cb4ab4e98768f4

  - kind: git_repo
    url: https://git.savannah.gnu.org/git/gnulib.git
    # This has to be manually set according to what grub uses
    ref: 9f48fb992a3d7e96610c4ce8be969cff2d61a01b
    directory: gnulib

build-depends:
  - freedesktop-sdk.bst:components/autoconf.bst
  - freedesktop-sdk.bst:components/bison.bst
  - freedesktop-sdk.bst:components/flex.bst
  - freedesktop-sdk.bst:components/freetype.bst
  - freedesktop-sdk.bst:components/fuse3.bst
  - freedesktop-sdk.bst:components/gettext.bst
  - freedesktop-sdk.bst:components/help2man.bst
  - freedesktop-sdk.bst:components/libusb.bst
  - freedesktop-sdk.bst:components/python3.bst
  - freedesktop-sdk.bst:components/rsync.bst
  - freedesktop-sdk.bst:components/sdl3.bst
  - freedesktop-sdk.bst:components/texinfo.bst
  - freedesktop-sdk.bst:components/wget2.bst
  - freedesktop-sdk.bst:components/pkg-config.bst
  - freedesktop-sdk.bst:components/git.bst
  - freedesktop-sdk.bst:components/automake.bst
  - freedesktop-sdk.bst:components/patch.bst
  - freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
  - core/efibootmgr.bst
  - freedesktop-sdk.bst:components/libdevmapper.bst
  - freedesktop-sdk.bst:components/xz.bst
  - freedesktop-sdk.bst:components/dejavu-fonts.bst
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

environment:
  CFLAGS: ""
  CXXFLAGS: ""
  LDFLAGS: ""

variables:
  strip-binaries: ""
  make-args: >-
    PREFIX="%{prefix}"
    PREFIX="%{prefix}"
    LIBDIR="%{libdir}"

config:
  configure-commands:
    - |
      ./bootstrap --gnulib-srcdir=gnulib --no-git

    - |
      mkdir -p build-i386-pc
      cd build-i386-pc
      ../configure \
        --prefix="/usr" \
        --bindir="/usr/bin" \
        --sbindir="/usr/bin" \
        --sysconfdir="/etc" \
        --with-bootdir="/boot" \
        --with-grubdir="grub" \
        --target=i386 \
        --with-platform=pc

    - |
      mkdir -p build-i386-efi
      cd build-i386-efi
      ../configure \
        --prefix="/usr" \
        --bindir="/usr/bin" \
        --sbindir="/usr/bin" \
        --sysconfdir="/etc" \
        --with-bootdir="/boot" \
        --with-grubdir="grub" \
        --target=i386 \
        --with-platform=efi

    - |
      mkdir -p build-x86_64-efi
      cd build-x86_64-efi
      ../configure \
        --prefix="/usr" \
        --bindir="/usr/bin" \
        --sbindir="/usr/bin" \
        --sysconfdir="/etc" \
        --with-bootdir="/boot" \
        --with-grubdir="grub" \
        --target=x86_64 \
        --with-platform=efi

  build-commands:
    - cd build-i386-pc && %{make}
    - cd build-i386-efi && %{make}
    - cd build-x86_64-efi && %{make}

  install-commands:
    - cd build-i386-pc && PREFIX="%{prefix}" %{make-install}
    - cd build-i386-efi && PREFIX="%{prefix}" %{make-install}
    - cd build-x86_64-efi && PREFIX="%{prefix}" %{make-install}
