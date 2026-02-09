kind: manual

build-depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/tar.bst
- freedesktop-sdk.bst:components/zstd.bst
- freedesktop-sdk.bst:components/git.bst

runtime-depends:
- bluefin/brew.bst

sources:
- kind: tar
  url: https://github.com/Homebrew/brew/archive/refs/tags/5.0.13.tar.gz
  ref: 1fa35433c49b9ae1e8600af5c5cbd04badfc96d68f5a4a3427ab2c654a6baf77
variables:
  strip-binaries: "true"

config:
  configure-commands:
  - |
    git init -b main
    
    git config --global user.email "buildstream@projectbluefin.io"
    git config --global user.name "Dakota"
    
    git remote add origin https://github.com/Homebrew/brew
    git add --force .
    git commit -m "Buildstreamed"
    
    git update-ref refs/remotes/origin/main "$(git rev-parse HEAD)"

  install-commands:
  - |
    install -d "%{install-root}%{datadir}"
    
    git archive --format=tar --prefix=linuxbrew/.linuxbrew/ HEAD | \
    zstd -z -o "%{install-root}%{datadir}/homebrew.tar.zst"
