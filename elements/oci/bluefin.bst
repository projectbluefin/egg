kind: script

build-depends:
  - gnome-build-meta.bst:freedesktop-sdk.bst:components/fakecap.bst
  - gnome-build-meta.bst:freedesktop-sdk.bst:components/oci-builder.bst
  - freedesktop-sdk.bst:components/glib.bst
  - gnome-build-meta.bst:freedesktop-sdk.bst:vm/prepare-image.bst
  - oci/layers/bluefin-init-scripts.bst
  - filename: oci/gnomeos.bst
    config:
      location: /parent
  - filename: oci/layers/bluefin.bst
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
      glib-compile-schemas /layer/usr/share/glib-2.0/schemas

    # bootc images must not have both /etc and /usr/etc.
    # /usr/etc is an ostree implementation detail generated client-side;
    # the image should only ship /etc.
    - |
      if [ -d /layer/usr/etc ]; then
        mkdir -p /layer/etc
        cp -a /layer/usr/etc/. /layer/etc/
        rm -rf /layer/usr/etc
      fi

    - |
      cd "%{install-root}"
      build-oci <<EOF
      mode: oci
      gzip: disabled
      images:
      - os: linux
        architecture: "%{go-arch}"
        parent:
          image: /parent
        layer: /layer
        comment: "Import Bluefin layer"
        config:
          Labels:
            'com.github.containers.toolbox': 'true'
            'org.opencontainers.image.title': 'Bluefin'
            'org.opencontainers.image.description': 'A custom GNOME-based desktop image'
            'org.opencontainers.image.vendor': 'Project Bluefin'
            'org.opencontainers.image.licenses': 'Apache-2.0'
            'org.opencontainers.image.url': 'https://projectbluefin.io'
            'org.opencontainers.image.source': 'https://github.com/projectbluefin/egg'
            'containers.bootc': '1'
        index-annotations:
          'org.opencontainers.image.ref.name': 'ghcr.io/projectbluefin/egg:latest'
      EOF
