kind: manual

description: |
  Ghostty is a fast, feature-rich, and cross-platform terminal emulator
  that uses platform-native UI and GPU acceleration. This is the first
  Zig-built package in the Bluefin image.

sources:
  # Primary source: Ghostty 1.2.3 source tarball
  - kind: tar
    url: ghostty_releases:1.2.3/ghostty-1.2.3.tar.gz
    ref: 559770fe9773161e93e3dd9177d916e27037d7f548edcf6186eabc571c0e520b

  # =====================================================================
  # Zig dependencies (32 HTTP tarballs)
  #
  # These are fetched by BuildStream and placed in zig-deps/.
  # Build commands use 'zig fetch' on each to populate the Zig cache.
  # =====================================================================

  - kind: remote
    url: ghostty_deps:breakpad-b99f444ba5f6b98cac261cbb391d8766b34a5918.tar.gz
    ref: 6cca98943d1a990766cef61077c09aff5938063fe17a1efe1228e5412b6d6ad9
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:fontconfig-2.14.2.tar.gz
    ref: 3ba2dd92158718acec5caaf1a716043b5aa055c27b081d914af3ccb40dce8a55
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:freetype-1220b81f6ecfb3fd222f76cf9106fecfa6554ab07ec7fdc4124b9bb063ae2adf969d.tar.gz
    ref: 427201f5d5151670d05c1f5b45bef5dda1f2e7dd971ef54f0feaaa7ffd2ab90c
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:gettext-0.24.tar.gz
    ref: c918503d593d70daf4844d175a13d816afacb667c06fba1ec9dcd5002c1518b7
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:glslang-12201278a1a05c0ce0b6eb6026c65cd3e9247aa041b1c260324bf29cee559dd23ba1.tar.gz
    ref: 14a2edbb509cb3e51a9a53e3f5e435dbf5971604b4b833e63e6076e8c0a997b5
    directory: zig-deps

  - kind: remote
    url: github_files:jcollie/ghostty-gobject/releases/download/0.15.1-2025-09-04-48-1/ghostty-gobject-0.15.1-2025-09-04-48-1.tar.zst
    ref: 87a68a51eac6957d804d511ea0dd377966aa0eabd498a75e760a71ad2a07beb6
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:gtk4-layer-shell-1.1.0.tar.gz
    ref: 98284281260a5eef5b4f63a55f16c4bf6a788a1020a6db037ecb0f71fa336988
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:harfbuzz-11.0.0.tar.xz
    ref: f16351bafe214725fe2c1d5b59f0d93e49905a4b247899fb90d70cff953a2b9b
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:highway-66486a10623fa0d72fe91260f96c892e41aceb06.tar.gz
    ref: 87d4f8893ef4e08f224973608ffebf94268a81380ba79c12e8841968c80aa212
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:imgui-1220bc6b9daceaf7c8c60f3c3998058045ba0c5c5f48ae255ff97776d9cd8bfc6402.tar.gz
    ref: a05fd01e04cf11ab781e28387c621d2e420f1e6044c8e27a25e603ea99ef7860
    directory: zig-deps

  # NOTE: iTerm2-Color-Schemes ghostty-themes.tgz removed — the upstream
  # GitHub release was deleted (404). This is safe because Ghostty's
  # emit_themes defaults to false; themes are a lazy dependency only
  # fetched when -Demit-themes=true is passed to zig build.

  - kind: remote
    url: ghostty_deps:JetBrainsMono-2.304.tar.gz
    ref: c57a691e8b82ad098b5963f3959032e4038f391087af7715885ba59046105cc4
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:libpng-1220aa013f0c83da3fb64ea6d327f9173fa008d10e28bc9349eac3463457723b1c66.tar.gz
    ref: fecc95b46cf05e8e3fc8a414750e0ba5aad00d89e9fdf175e94ff041caf1a03a
    directory: zig-deps

  - kind: remote
    url: github_files:mitchellh/libxev/archive/7f803181b158a10fec8619f793e3b4df515566cb.tar.gz
    ref: 29aa3360a121853ffab089de7fbffc3bfeb42c304937ef1099d2ee358d469267
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:libxml2-2.11.5.tar.gz
    ref: 6c28059e2e3eeb42b5b4b16489e3916a6346c1095a74fee3bc65cdc5d89a6215
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:NerdFontsSymbolsOnly-3.4.0.tar.gz
    ref: 1164d1b956d4bde248d7b2f0998c43cc94f5202431a1564a793895b1e73b0d04
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:oniguruma-1220c15e72eadd0d9085a8af134904d9a0f5dfcbed5f606ad60edc60ebeccd9706bb.tar.gz
    ref: 001aa1202e78448f4c0bf1a48c76e556876b36f16d92ce3207eccfd61d99f2a0
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:pixels-12207ff340169c7d40c570b4b6a97db614fe47e0d83b5801a932dcd44917424c8806.tar.gz
    ref: 55e83b16d091082502bf149bf457f31f42092c5982650e3ffbae7b48871bf11a
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:plasma_wayland_protocols-12207e0851c12acdeee0991e893e0132fc87bb763969a585dc16ecca33e88334c566.tar.gz
    ref: 5c58ba214acd8e6bca3426dc08b022c46a8dd997b29a1b3e28badf71c20df441
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:sentry-1220446be831adcca918167647c06c7b825849fa3fba5f22da394667974537a9c77e.tar.gz
    ref: 2ac6497cc8d61a8d31093e47addb8c9b2c45b16b0705bb334a835b6423c318df
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:spirv_cross-1220fb3b5586e8be67bc3feb34cbe749cf42a60d628d2953632c2f8141302748c8da.tar.gz
    ref: b52b6fcfc45e7fa69b1f06a1362c155473444e2cc09995556b156c53ba6657e3
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:utfcpp-1220d4d18426ca72fc2b7e56ce47273149815501d0d2395c2a98c726b31ba931e641.tar.gz
    ref: ffc668a310e77607d393f3c18b32715f223da1eac4c4d6e0579a11df8e6b59cf
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:wayland-9cb3d7aa9dc995ffafdbdef7ab86a949d0fb0e7d.tar.gz
    ref: ea4191d68e437677e51f3aacde27829810144e931d397a327dc6035e2c39c50d
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:wayland-protocols-258d8f88f2c8c25a830c6316f87d23ce1a0f12d9.tar.gz
    ref: 5cedcadde81b75e60f23e5e83b5dd2b8eb4efb9f8f79bd7a347d148aeb0530f8
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:wuffs-122037b39d577ec2db3fd7b2130e7b69ef6cc1807d68607a7c232c958315d381b5cd.tar.gz
    ref: 9e4cd20abe96e6c4c6ede9c3057108860126e7be2e2c3e35515476c250be1c13
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:zig_js-12205a66d423259567764fa0fc60c82be35365c21aeb76c5a7dc99698401f4f6fefc.tar.gz
    ref: 7f235e0956c2f5401a28963a261019953d00e3bf4cfc029830f2161196c3583d
    directory: zig-deps

  - kind: remote
    url: github_files:mitchellh/zig-objc/archive/c9e917a4e15a983b672ca779c7985d738a2d517c.tar.gz
    ref: a37be5eea7e44a2d1b2976ba256b85f76a8c1063fc01ffec85c8a9e67468e4dc
    directory: zig-deps

  - kind: remote
    url: codeberg_files:ifreund/zig-wayland/archive/f3c5d503e540ada8cbcb056420de240af0c094f7.tar.gz
    ref: 13bec6675e403d86db3b55b39ae262f1e1bdfe24056dcd82824341c6308b5219
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:ziglyph-b89d43d1e3fb01b6074bc1f7fc980324b04d26a5.tar.gz
    ref: 72c7bdf3e16df105235fe3fcf32c987dac49389190f4ced89b0ee31710f3f3d9
    directory: zig-deps

  - kind: remote
    url: ghostty_deps:zlib-1220fed0c74e1019b3ee29edae2051788b080cd96e90d56836eea857b0b966742efb.tar.gz
    ref: 17e88863f3600672ab49182f217281b6fc4d3c762bde361935e436a95214d05c
    directory: zig-deps

  - kind: remote
    url: github_files:vancluever/z2d/archive/refs/tags/v0.8.1.tar.gz
    ref: d036c3292600d5e8e1571fd66ce9304e00f9ecf35115c9d1be2a8187cc693d9d
    directory: zig-deps

  - kind: remote
    url: github_files:natecraddock/zf/archive/7aacbe6d155d64d15937ca95ca6c014905eb531f.tar.gz
    ref: de7ba535077fe2b678a5a7972585f002588d37244db08397feadf3d4907c0bb2
    directory: zig-deps

  # =====================================================================
  # Git-based Zig dependencies (3)
  #
  # These use git+https:// URLs in build.zig.zon. Since we can't do git
  # clones in the BST sandbox, we fetch GitHub/Codeberg archive tarballs.
  #
  # IMPORTANT: zig fetch on archive tarballs may produce different content
  # hashes than git clones (GitHub adds a top-level directory wrapper).
  # The build commands handle this by manually extracting and placing
  # these at the correct Zig hash path, bypassing zig fetch -- following
  # the same approach as the Nix derivation (fetchGitZig).
  # =====================================================================

  - kind: remote
    url: github_files:rockorager/libvaxis/archive/1f41c121e8fc153d9ce8c6eb64b2bbab68ad7d23.tar.gz
    ref: 36a508b4fe13eebcee5f7bcfcac774dd427c962997a4e7543838a791d986df86
    directory: zig-deps-git

  - kind: remote
    url: codeberg_files:atman/zg/archive/4a002763419a34d61dcbb1f415821b83b9bf8ddc.tar.gz
    ref: c887c08d72b11f312f15f1ce1dafe4ba8afacd3f459005e69f2d5fcee3618d7a
    directory: zig-deps-git

  - kind: remote
    url: github_files:TUSF/zigimg/archive/31268548fe3276c0e95f318a6c0d2ab10565b58d.tar.gz
    ref: c09e3a403e883f2ea90d2e201b051bc67c1ec1ca89a55da73d50020dbc7dfbf1
    directory: zig-deps-git

build-depends:
  - bluefin/zig.bst

depends:
  - gnome-build-meta.bst:sdk/gtk.bst
  - gnome-build-meta.bst:sdk/libadwaita.bst
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

config:
  build-commands:
    # Set up Zig cache and lib path
    - |
      export ZIG_GLOBAL_CACHE_DIR="/tmp/zig-cache"
      export ZIG_LIB_DIR="%{libdir}/zig"
      mkdir -p "$ZIG_GLOBAL_CACHE_DIR/p"

    # Populate Zig cache from HTTP dependency tarballs using zig fetch.
    # zig fetch unpacks each archive, computes the content hash, and
    # places the result in $ZIG_GLOBAL_CACHE_DIR/p/<hash>/.
    - |
      export ZIG_GLOBAL_CACHE_DIR="/tmp/zig-cache"
      export ZIG_LIB_DIR="%{libdir}/zig"
      for dep in zig-deps/*; do
        echo "Fetching: $dep"
        zig fetch --global-cache-dir "$ZIG_GLOBAL_CACHE_DIR" "$dep" || {
          echo "WARNING: zig fetch failed for $dep" >&2
        }
      done

    # Handle git-based dependencies manually.
    # GitHub/Codeberg archive tarballs have a top-level directory that
    # differs from a git clone. We extract the contents and place them
    # directly at the Zig hash path, matching what Nix's fetchGitZig does.
    - |
      export ZIG_GLOBAL_CACHE_DIR="/tmp/zig-cache"

      place_git_dep() {
        local tarball="$1"
        local zig_hash="$2"
        local dest="$ZIG_GLOBAL_CACHE_DIR/p/$zig_hash"
        mkdir -p "$dest"
        # Extract, stripping the top-level directory wrapper
        tar xf "$tarball" --strip-components=1 -C "$dest"
        echo "Placed git dep at $dest"
      }

      # vaxis: git+https://github.com/rockorager/libvaxis#1f41c121...
      place_git_dep \
        "zig-deps-git/1f41c121e8fc153d9ce8c6eb64b2bbab68ad7d23.tar.gz" \
        "vaxis-0.1.0-BWNV_FUICQAFZnTCL11TUvnUr1Y0_ZdqtXHhd51d76Rn"

      # zg: git+https://codeberg.org/atman/zg#4a002763...
      place_git_dep \
        "zig-deps-git/4a002763419a34d61dcbb1f415821b83b9bf8ddc.tar.gz" \
        "zg-0.13.4-AAAAAGiZ7QLz4pvECFa_wG4O4TP4FLABHHbemH2KakWM"

      # zigimg: git+https://github.com/TUSF/zigimg#31268548...
      place_git_dep \
        "zig-deps-git/31268548fe3276c0e95f318a6c0d2ab10565b58d.tar.gz" \
        "zigimg-0.1.0-lly-O6N2EABOxke8dqyzCwhtUCAafqP35zC7wsZ4Ddxj"

  install-commands:
    # Build and install Ghostty in a single step with DESTDIR.
    # Flags match upstream PACKAGING.md + Arch Linux conventions.
    - |
      export ZIG_GLOBAL_CACHE_DIR="/tmp/zig-cache"
      export ZIG_LIB_DIR="%{libdir}/zig"
      DESTDIR="%{install-root}" \
      zig build \
        --prefix /usr \
        --system "$ZIG_GLOBAL_CACHE_DIR/p" \
        -Doptimize=ReleaseFast \
        -Dcpu=baseline \
        -Dpie=true \
        -Dversion-string=1.2.3 \
        -Dgtk-x11=true
