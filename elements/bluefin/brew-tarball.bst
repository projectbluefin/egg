kind: manual

build-depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst
- freedesktop-sdk.bst:components/tar.bst
- freedesktop-sdk.bst:components/zstd.bst
- freedesktop-sdk.bst:components/git.bst

runtime-depends:
- bluefin/brew.bst

sources:
- kind: git_repo
  url: github:Homebrew/brew
  track: "*"
  ref: 5.0.14-0-g6e88ffd4d26b5074cdbcad13f7dcff4222e8677f
variables:
  strip-binaries: "true"

config:
  configure-commands:
  - |
    rm -rf .git
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

    git archive --format=tar --prefix=home/linuxbrew/.linuxbrew/ HEAD | \
    zstd -z -o "%{install-root}%{datadir}/homebrew.tar.zst"
