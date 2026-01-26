# Derived from gnome-build-meta.bst 50~ core/meta-gnome-core-apps.bst

# The core set is not expected to change as frequently as core-deps.
# Adding or removing elements from here should be approved by
# release team. Review the technical conditions to enter GNOME core:
# https://gitlab.gnome.org/GNOME/gnome-build-meta/-/wikis/home#technical-conditions-to-enter-gnome-core
#
# Additional design team approval is required before adding or removing
# desktop applications from core. Current contact: Allan Day.
kind: stack
description: |
  Overridden to only keep some applications.

depends:
- gnome-build-meta.bst:core/baobab.bst
- gnome-build-meta.bst:core/gnome-disk-utility.bst
- gnome-build-meta.bst:core/gnome-system-monitor.bst
- gnome-build-meta.bst:core/nautilus.bst
- gnome-build-meta.bst:core/simple-scan.bst
# Until there is ptyxis in the iso
- gnome-build-meta.bst:core/gnome-console.bst
# - gnome-build-meta.bst:sdk/yelp.bst
