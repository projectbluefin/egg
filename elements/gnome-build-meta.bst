kind: junction

sources:
- kind: git_repo
  url: gnome:/gnome-build-meta.git
  track: master
  ref: 49-branchpoint-438-g35cf3d4a75b3628b1c7b81f91a7dd6661659052b
- kind: patch_queue
  path: patches/gnome-build-meta

config:
  overrides:
    # This along with the patches is required and has to match what gnome-build-meta is using
    freedesktop-sdk.bst: freedesktop-sdk.bst

    # Replace the element so the OCI image doesn't have any apps
    core/meta-gnome-core-apps.bst: core/meta-gnome-core-apps.bst

    # Replace the element so the OCI image generates Bluefin's os-release file
    oci/os-release.bst: oci/os-release.bst
    oci/gnomeos.bst: oci/gnomeos.bst

    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
