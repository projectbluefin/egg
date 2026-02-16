kind: manual

build-depends:
  - freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
  - freedesktop-sdk.bst:components/sed.bst

sources:
  - kind: tar
    url: onepassword_files:linux/tar/stable/x86_64/1password-8.12.2.x64.tar.gz
    ref: bc9f86c108e50c29faef6dead7eff115416437d5e323dff47827ed9984204b5b

variables:
  strip-binaries: ""

config:
  install-commands:
    - |
      mkdir -p "%{install-root}/opt/1Password"
      cp -a . "%{install-root}/opt/1Password/"
    - |
      install -dm755 "%{install-root}%{bindir}"
      ln -sf /opt/1Password/1password "%{install-root}%{bindir}/1password"
    - |
      sed 's|/opt/1Password/1password|1password|g' \
          resources/1password.desktop > 1password.desktop.patched
      install -Dm644 1password.desktop.patched \
          "%{install-root}%{datadir}/applications/1password.desktop"
    - |
      for size in 32x32 64x64 256x256 512x512; do
        install -Dm644 "resources/icons/hicolor/${size}/apps/1password.png" \
            "%{install-root}%{datadir}/icons/hicolor/${size}/apps/1password.png"
      done
    - |
      chmod 4755 "%{install-root}/opt/1Password/chrome-sandbox"
    - |
      sed 's/${POLICY_OWNERS}//g' com.1password.1Password.policy.tpl \
          > com.1password.1Password.policy
      install -Dm644 -t "%{install-root}%{datadir}/polkit-1/actions" \
          com.1password.1Password.policy
    - |
      %{install-extra}
