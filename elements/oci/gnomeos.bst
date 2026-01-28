kind: script

build-depends:
- gnome-build-meta.bst:freedesktop-sdk.bst:components/fakecap.bst
# - freedesktop-sdk.bst:components/oci-builder.bst
- core/build-oci-rs.bst
- gnome-build-meta.bst:freedesktop-sdk.bst:vm/prepare-image.bst
- gnome-build-meta.bst:oci/layers/gnomeos-init-scripts.bst
- filename: gnome-build-meta.bst:oci/platform.bst
  config:
    location: /parent
- filename: gnome-build-meta.bst:oci/layers/gnomeos.bst
  config:
    location: /layer

environment:
  LD_PRELOAD: /usr/libexec/fakecap/fakecap.so
  FAKECAP_DB: /fakecap

variables:
  sysroot-seed: b57666f6-0fe5-4310-adff-f256936d164d

config:
  commands:
  - mkdir /fakecap
  - |
    prepare-image.sh \
       --sysroot /layer \
       --initscripts /initial_scripts \
       --seed "%{sysroot-seed}" \
       --noroot --noboot >/dev/null

  - |
    systemd-sysusers --root /layer

  - |
    cd "%{install-root}"
    build-oci -j %{max-jobs} <<EOF
    mode: oci
    gzip: disabled
    images:
    - os: linux
      architecture: "%{go-arch}"
      parent:
        image: /parent
      layer: /layer
      comment: "Import the OS layer from GNOME OS"
      config:
        Labels:
          'com.github.containers.toolbox': 'true'
          'org.opencontainers.image.source': 'https://gitlab.gnome.org/GNOME/gnome-build-meta/'
          'org.opencontainers.image.url': 'https://gitlab.gnome.org/GNOME/gnome-build-meta/'
          'containers.bootc': '1'
      index-annotations:
        'org.opencontainers.image.ref.name': 'quay.io/gnome_infrastructure/gnome-build-meta:gnomeos-%{branch}'
    EOF
