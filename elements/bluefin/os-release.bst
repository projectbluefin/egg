kind: manual

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

variables:
  strip-binaries: ''

environment:
  # FIXME: configurable
  # IMAGE_REF="ostree-image-signed:docker://ghcr.io/${IMAGE_VENDOR}/${IMAGE_NAME}"
  IMAGE_NAME: "bluefin-distroless"
  IMAGE_VENDOR: "projectbluefin"
  IMAGE_REF: "ostree-image-signed:docker://ghcr.io/projectbluefin/distrolesss"
  IMAGE_FLAVOR: "main"
  IMAGE_TAG: "latest"

  IMAGE_PRETTY_NAME: "Bluefin"
  HOME_URL: "https://projectbluefin.io"
  DOCUMENTATION_URL: "https://docs.projectbluefin.io"
  SUPPORT_URL: "https://github.com/projectbluefin/distroless/issues"
  BUG_SUPPORT_URL: "https://github.com/projectbluefin/distroless/issues"
  CODE_NAME: "Dakotaraptor"
  ID: "bluefin-distroless"

config:
  build-commands:
  - mkdir -p %{install-root}%{indep-libdir}/
  - |
    cat >"%{install-root}%{indep-libdir}/os-release" <<EOF
    NAME="${IMAGE_PRETTY_NAME}"
    ID="${ID}"
    ID_LIKE="org.gnome.os"
    VERSION="${IMAGE_TAG}"
    VERSION_CODENAME="${CODE_NAME}"
    PRETTY_NAME="${IMAGE_PRETTY_NAME}"
    BUG_REPORT_URL="${BUG_SUPPORT_URL}"
    HOME_URL="${HOME_URL}"
    DOCUMENTATION_URL="${DOCUMENTATION_URL}"
    SUPPORT_URL="${SUPPORT_URL}"
    LOGO=img-logo-icon
    DEFAULT_HOSTNAME="bluefin"
    EOF

  - mkdir -p "%{install-root}%{datadir}/ublue-os"
  - |
    cat >"%{install-root}%{datadir}/ublue-os/image-info.json" <<EOF
    {
      "image-name": "${IMAGE_NAME}",
      "image-ref": "${IMAGE_REF}",
      "image-flavor": "${IMAGE_FLAVOR}",
      "image-vendor": "${IMAGE_VENDOR}",
      "image-tag": "${IMAGE_TAG}"
    }
    EOF
