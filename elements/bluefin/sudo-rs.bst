kind: make

public:
  bst:
    overlap-whitelist:
    - /usr/bin/sudo
    - /usr/bin/sudoedit
    - /usr/lib/debug/usr/bin/sudo.debug

build-depends:
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst
- freedesktop-sdk.bst:components/linux-pam.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/linux-pam.bst

config:
  build-commands:
  - cargo build --release

  install-commands:
  - install -Dm4755 target/release/sudo "%{install-root}/usr/bin/sudo"
  - ln -sr "%{install-root}/usr/bin/sudo" "%{install-root}/usr/bin/sudoedit"

sources:
- kind: git_repo
  url: github:memorysafety/sudo-rs.git
  track: 74e0db4f7f89b7429dd7ebbdfa94b0c55eba40cb
  ref: 74e0db4f7f89b7429dd7ebbdfa94b0c55eba40cb
- kind: cargo2
  url: crates:crates
  ref:
  - kind: registry
    name: glob
    version: 0.3.3
    sha: 0cc23270f6e1808e30a928bdc84dea0b9b4136a8bc82338574f23baf47bbd280
  - kind: registry
    name: libc
    version: 0.2.180
    sha: bcc35a38544a891a5f7c865aca548a982ccb3b8650a5b06d0fd33a10283c56fc
