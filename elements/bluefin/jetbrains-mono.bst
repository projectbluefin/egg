kind: manual

build-depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: zip
  url: github_files:JetBrains/JetBrainsMono/releases/download/v2.304/JetBrainsMono-2.304.zip
  ref: 6f6376c6ed2960ea8a963cd7387ec9d76e3f629125bc33d1fdcd7eb7012f7bbf
variables:
  strip-binaries: ''

config:
  install-commands:
  - mkdir -p "%{install-root}%{datadir}/fonts/JetBrains Mono"
  - cp -r ttf variable webfonts "%{install-root}%{datadir}/fonts/JetBrains Mono"
  - |
    %{install-extra}

