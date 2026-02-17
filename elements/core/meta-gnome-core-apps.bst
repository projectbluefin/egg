# Derived from gnome-build-meta.bst 50~ core/meta-gnome-core-apps.bst

kind: stack
description: |
  Overridden to only keep some applications.

depends:
  - gnome-build-meta.bst:core/baobab.bst
  - gnome-build-meta.bst:core/gnome-disk-utility.bst
  - gnome-build-meta.bst:core/gnome-system-monitor.bst
  - gnome-build-meta.bst:core/nautilus.bst
  - gnome-build-meta.bst:sdk/yelp.bst
