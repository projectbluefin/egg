kind: stack

depends:
  - gnome-build-meta.bst:gnomeos-deps/deps.bst

  - bluefin/gnome-shell-extensions.bst
  - bluefin/common-configs.bst

  - bluefin/brew.bst

  - bluefin/dump.bst

  # Since we use gnomeos nightly atm, no extension works
  # with the current shell version
  - bluefin/disable-ext-validator.bst

  - bluefin/jetbrains-mono.bst

  # Include things missing from the gnomeos base image
  - freedesktop-sdk.bst:components/git-lfs.bst
  - freedesktop-sdk.bst:components/git.bst
  - freedesktop-sdk.bst:components/podman.bst
  - freedesktop-sdk.bst:components/containers-common.bst
  - freedesktop-sdk.bst:components/skopeo.bst
  # - gnome-build-meta.bst:gnomeos-deps/bootc.bst
  - gnome-build-meta.bst:gnomeos-deps/distrobox.bst
  - bluefin/common-configs.bst
