kind: junction

sources:
- kind: git_repo
  url: https://gitlab.gnome.org/gnome/gnome-build-meta.git
  # Custom branch with bootc and generate-keys support
  # bootc: https://gitlab.gnome.org/GNOME/gnome-build-meta/-/merge_requests/4256
  # keys: https://gitlab.gnome.org/GNOME/gnome-build-meta/-/merge_requests/4289
  track: valentindavid/automatically-generate-keys
  ref: 49-branchpoint-284-gee4b15e7160e502fa3e007de2c55859f9f0963b6
# - kind: patch_queue
#   path: patches/gnome-build-meta

config:
  overrides:
    # This along with the patches is required and has to match
    # what gnome-build-meta is using
    freedesktop-sdk.bst: freedesktop-sdk.bst

    # Replace the element so the OCI image doesn't have any apps
    core/meta-gnome-core-apps.bst: core/meta-gnome-core-apps.bst

    plugins/buildstream-plugins.bst: plugins/buildstream-plugins.bst
    plugins/buildstream-plugins-community.bst: plugins/buildstream-plugins-community.bst
