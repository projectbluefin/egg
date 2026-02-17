kind: stack

depends:
  - gnome-build-meta.bst:gnomeos-deps/deps.bst

  - bluefin/gnome-shell-extensions.bst

  - bluefin/brew.bst
  - bluefin/brew-tarball.bst

  - bluefin/tailscale.bst

  - bluefin/1password-cli.bst
  - bluefin/1password.bst

  - bluefin/ghostty.bst

  - bluefin/glow.bst
  - bluefin/gum.bst
  - bluefin/fzf.bst

  - bluefin/common.bst
  - bluefin/wallpapers.bst

  - bluefin/jetbrains-mono.bst
  - bluefin/jetbrains-mono-nerd-font.bst

  # Include things missing from the gnomeos base image
  - freedesktop-sdk.bst:components/git-lfs.bst
  - freedesktop-sdk.bst:components/git.bst
  - freedesktop-sdk.bst:components/podman.bst
  - freedesktop-sdk.bst:components/containers-common.bst
  - freedesktop-sdk.bst:components/skopeo.bst
  - gnome-build-meta.bst:gnomeos-deps/distrobox.bst
  - gnome-build-meta.bst:gnomeos-deps/just.bst
  - gnome-build-meta.bst:gnomeos-deps/wl-clipboard.bst
