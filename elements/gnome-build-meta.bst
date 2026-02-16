kind: junction

sources:
- kind: git_repo
  url: gnome:gnome-build-meta.git
  track: master
  ref: 49-branchpoint-455-gc1c661ff62b12f0e45ece25eda61de763a263d8d
- kind: patch_queue
  path: patches/gnome-build-meta

config:
  overrides:
    # This along with the patches is required and has to match what gnome-build-meta is using
    freedesktop-sdk.bst: freedesktop-sdk.bst

    # Replace the element so the OCI image doesn't have any apps
    core/meta-gnome-core-apps.bst: core/meta-gnome-core-apps.bst

    gnomeos-deps/plymouth-gnome-theme.bst: bluefin/plymouth-bluefin-theme.bst
    gnomeos-deps/bootc.bst: core/bootc.bst

    # Replace the element so the OCI image generates Bluefin's os-release file
    oci/os-release.bst: oci/os-release.bst

    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
