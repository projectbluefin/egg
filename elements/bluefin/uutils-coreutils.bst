kind: make

config:
  build-commands:
  - cargo build --release --features feat_os_unix --no-default-features

  install-commands:
  - install -Dm755 target/release/coreutils "%{install-root}/usr/bin/uutils-coreutils"
  - |
    for prog in $(target/release/coreutils --list); do
      ln -sr "%{install-root}/usr/bin/uutils-coreutils" "%{install-root}/usr/bin/uutils-${prog}"
      ln -sr "%{install-root}/usr/bin/uutils-coreutils" "%{install-root}/usr/bin/${prog}"
    done

public:
  bst:
    overlap-whitelist:
    - /usr/bin/[
    - /usr/bin/arch
    - /usr/bin/b2sum
    - /usr/bin/base32
    - /usr/bin/base64
    - /usr/bin/basename
    - /usr/bin/basenc
    - /usr/bin/cat
    - /usr/bin/chgrp
    - /usr/bin/chmod
    - /usr/bin/chown
    - /usr/bin/chroot
    - /usr/bin/cksum
    - /usr/bin/comm
    - /usr/bin/cp
    - /usr/bin/csplit
    - /usr/bin/cut
    - /usr/bin/date
    - /usr/bin/dd
    - /usr/bin/df
    - /usr/bin/dir
    - /usr/bin/dircolors
    - /usr/bin/dirname
    - /usr/bin/du
    - /usr/bin/echo
    - /usr/bin/env
    - /usr/bin/expand
    - /usr/bin/expr
    - /usr/bin/factor
    - /usr/bin/false
    - /usr/bin/fmt
    - /usr/bin/fold
    - /usr/bin/groups
    - /usr/bin/head
    - /usr/bin/hostid
    - /usr/bin/hostname
    - /usr/bin/id
    - /usr/bin/install
    - /usr/bin/join
    - /usr/bin/kill
    - /usr/bin/link
    - /usr/bin/ln
    - /usr/bin/logname
    - /usr/bin/ls
    - /usr/bin/md5sum
    - /usr/bin/mkdir
    - /usr/bin/mkfifo
    - /usr/bin/mknod
    - /usr/bin/mktemp
    - /usr/bin/more
    - /usr/bin/mv
    - /usr/bin/nice
    - /usr/bin/nl
    - /usr/bin/nohup
    - /usr/bin/nproc
    - /usr/bin/numfmt
    - /usr/bin/od
    - /usr/bin/paste
    - /usr/bin/pathchk
    - /usr/bin/pinky
    - /usr/bin/pr
    - /usr/bin/printenv
    - /usr/bin/printf
    - /usr/bin/ptx
    - /usr/bin/pwd
    - /usr/bin/readlink
    - /usr/bin/realpath
    - /usr/bin/rm
    - /usr/bin/rmdir
    - /usr/bin/seq
    - /usr/bin/sha1sum
    - /usr/bin/sha224sum
    - /usr/bin/sha256sum
    - /usr/bin/sha384sum
    - /usr/bin/sha512sum
    - /usr/bin/shred
    - /usr/bin/shuf
    - /usr/bin/sleep
    - /usr/bin/sort
    - /usr/bin/split
    - /usr/bin/stat
    - /usr/bin/stdbuf
    - /usr/bin/stty
    - /usr/bin/sum
    - /usr/bin/sync
    - /usr/bin/tac
    - /usr/bin/tail
    - /usr/bin/tee
    - /usr/bin/test
    - /usr/bin/timeout
    - /usr/bin/touch
    - /usr/bin/tr
    - /usr/bin/true
    - /usr/bin/truncate
    - /usr/bin/tsort
    - /usr/bin/tty
    - /usr/bin/uname
    - /usr/bin/unexpand
    - /usr/bin/uniq
    - /usr/bin/unlink
    - /usr/bin/uptime
    - /usr/bin/users
    - /usr/bin/vdir
    - /usr/bin/wc
    - /usr/bin/who
    - /usr/bin/whoami
    - /usr/bin/yes

build-depends:
- freedesktop-sdk.bst:components/rust.bst
- freedesktop-sdk.bst:public-stacks/buildsystem-make.bst

depends:
- freedesktop-sdk.bst:public-stacks/runtime-minimal.bst

sources:
- kind: git_repo
  url: github:uutils/coreutils.git
  track: e7f2fd9c80417265707e54fb0b260531c86cc39e
  ref: e7f2fd9c80417265707e54fb0b260531c86cc39e
- kind: cargo2
  url: crates:crates
  ref:
  - kind: registry
    name: adler2
    version: 2.0.1
    sha: 320119579fcad9c21884f5c4861d16174d0e06250625266f50fe6898340abefa
  - kind: registry
    name: ahash
    version: 0.8.12
    sha: 5a15f179cd60c4584b8a8c596927aadc462e27f2ca70c04e0071964a73ba7a75
  - kind: registry
    name: aho-corasick
    version: 1.1.4
    sha: ddd31a130427c27518df266943a5308ed92d4b226cc639f5a8f1002816174301
  - kind: registry
    name: allocator-api2
    version: 0.2.21
    sha: 683d7910e743518b0e34f1186f92494becacb047c7b6bf616c96772180fef923
  - kind: registry
    name: android_system_properties
    version: 0.1.5
    sha: 819e7219dbd41043ac279b19830f2efc897156490d7fd6ea916720117ee66311
  - kind: registry
    name: ansi-width
    version: 0.1.0
    sha: 219e3ce6f2611d83b51ec2098a12702112c29e57203a6b0a0929b2cddb486608
  - kind: registry
    name: anstream
    version: 0.6.21
    sha: 43d5b281e737544384e969a5ccad3f1cdd24b48086a0fc1b2a5262a26b8f4f4a
  - kind: registry
    name: anstyle
    version: 1.0.13
    sha: 5192cca8006f1fd4f7237516f40fa183bb07f8fbdfedaa0036de5ea9b0b45e78
  - kind: registry
    name: anstyle-parse
    version: 0.2.7
    sha: 4e7644824f0aa2c7b9384579234ef10eb7efb6a0deb83f9630a49594dd9c15c2
  - kind: registry
    name: anstyle-query
    version: 1.1.5
    sha: 40c48f72fd53cd289104fc64099abca73db4166ad86ea0b4341abe65af83dadc
  - kind: registry
    name: anstyle-wincon
    version: 3.0.11
    sha: 291e6a250ff86cd4a820112fb8898808a366d8f9f58ce16d1f538353ad55747d
  - kind: registry
    name: anyhow
    version: 1.0.101
    sha: 5f0e0fee31ef5ed1ba1316088939cea399010ed7731dba877ed44aeb407a75ea
  - kind: registry
    name: approx
    version: 0.5.1
    sha: cab112f0a86d568ea0e627cc1d6be74a1e9cd55214684db5561995f6dad897c6
  - kind: registry
    name: arrayref
    version: 0.3.9
    sha: 76a2e8124351fda1ef8aaaa3bbd7ebbcb486bbcd4225aca0aa0d84bb2db8fecb
  - kind: registry
    name: arrayvec
    version: 0.7.6
    sha: 7c02d123df017efcdfbd739ef81735b36c5ba83ec3c59c80a9d7ecc718f92e50
  - kind: registry
    name: autocfg
    version: 1.5.0
    sha: c08606f8c3cbf4ce6ec8e28fb0014a2c086708fe954eaa885384a6165172e7e8
  - kind: registry
    name: base64-simd
    version: 0.8.0
    sha: 339abbe78e73178762e23bea9dfd08e697eb3f3301cd4be981c0f78ba5859195
  - kind: registry
    name: bigdecimal
    version: 0.4.10
    sha: 4d6867f1565b3aad85681f1015055b087fcfd840d6aeee6eee7f2da317603695
  - kind: registry
    name: binary-heap-plus
    version: 0.5.0
    sha: e4551d8382e911ecc0d0f0ffb602777988669be09447d536ff4388d1def11296
  - kind: registry
    name: bindgen
    version: 0.72.1
    sha: 993776b509cfb49c750f11b8f07a46fa23e0a1386ffc01fb1e7d343efc387895
  - kind: registry
    name: bitflags
    version: 1.3.2
    sha: bef38d45163c2f1dde094a7dfd33ccf595c92905c8f8f4fdc18d06fb1037718a
  - kind: registry
    name: bitflags
    version: 2.10.0
    sha: 812e12b5285cc515a9c72a5c1d3b6d46a19dac5acfef5265968c166106e31dd3
  - kind: registry
    name: bitvec
    version: 1.0.1
    sha: 1bc2832c24239b0141d5674bb9174f9d68a8b5b3f2753311927c172ca46f7e9c
  - kind: registry
    name: blake2b_simd
    version: 1.0.4
    sha: b79834656f71332577234b50bfc009996f7449e0c056884e6a02492ded0ca2f3
  - kind: registry
    name: blake3
    version: 1.8.3
    sha: 2468ef7d57b3fb7e16b576e8377cdbde2320c60e1491e961d11da40fc4f02a2d
  - kind: registry
    name: block-buffer
    version: 0.10.4
    sha: 3078c7629b62d3f0439517fa394996acacc5cbc91c5a20d8c658e77abd503a71
  - kind: registry
    name: block2
    version: 0.6.2
    sha: cdeb9d870516001442e364c5220d3574d2da8dc765554b4a617230d33fa58ef5
  - kind: registry
    name: bstr
    version: 1.12.1
    sha: 63044e1ae8e69f3b5a92c736ca6269b8d12fa7efe39bf34ddb06d102cf0e2cab
  - kind: registry
    name: bumpalo
    version: 3.19.1
    sha: 5dd9dc738b7a8311c7ade152424974d8115f2cdad61e8dab8dac9f2362298510
  - kind: registry
    name: bytecount
    version: 0.6.9
    sha: 175812e0be2bccb6abe50bb8d566126198344f707e304f45c648fd8f2cc0365e
  - kind: registry
    name: byteorder
    version: 1.5.0
    sha: 1fd0f2584146f6f2ef48085050886acf353beff7305ebd1ae69500e27c67f64b
  - kind: registry
    name: calendrical_calculations
    version: 0.2.3
    sha: 3a0b39595c6ee54a8d0900204ba4c401d0ab4eb45adaf07178e8d017541529e7
  - kind: registry
    name: cc
    version: 1.2.55
    sha: 47b26a0954ae34af09b50f0de26458fa95369a0d478d8236d3f93082b219bd29
  - kind: registry
    name: cexpr
    version: 0.6.0
    sha: 6fac387a98bb7c37292057cffc56d62ecb629900026402633ae9160df93a8766
  - kind: registry
    name: cfg-if
    version: 1.0.4
    sha: 9330f8b2ff13f34540b44e946ef35111825727b38d33286ef986142615121801
  - kind: registry
    name: cfg_aliases
    version: 0.2.1
    sha: 613afe47fcd5fac7ccf1db93babcb082c5994d996f20b8b159f2ad1658eb5724
  - kind: registry
    name: chrono
    version: 0.4.43
    sha: fac4744fb15ae8337dc853fee7fb3f4e48c0fbaa23d0afe49c447b4fab126118
  - kind: registry
    name: clang-sys
    version: 1.8.1
    sha: 0b023947811758c97c59bf9d1c188fd619ad4718dcaa767947df1cadb14f39f4
  - kind: registry
    name: clap
    version: 4.5.58
    sha: 63be97961acde393029492ce0be7a1af7e323e6bae9511ebfac33751be5e6806
  - kind: registry
    name: clap_builder
    version: 4.5.58
    sha: 7f13174bda5dfd69d7e947827e5af4b0f2f94a4a3ee92912fba07a66150f21e2
  - kind: registry
    name: clap_complete
    version: 4.5.66
    sha: c757a3b7e39161a4e56f9365141ada2a6c915a8622c408ab6bb4b5d047371031
  - kind: registry
    name: clap_lex
    version: 1.0.0
    sha: 3a822ea5bc7590f9d40f1ba12c0dc3c2760f3482c6984db1573ad11031420831
  - kind: registry
    name: clap_mangen
    version: 0.2.31
    sha: 439ea63a92086df93893164221ad4f24142086d535b3a0957b9b9bea2dc86301
  - kind: registry
    name: codspeed
    version: 4.3.0
    sha: 38c2eb3388ebe26b5a0ab6bf4969d9c4840143d7f6df07caa3cc851b0606cef6
  - kind: registry
    name: codspeed-divan-compat
    version: 4.3.0
    sha: b2de65b7489a59709724d489070c6d05b7744039e4bf751d0a2006b90bb5593d
  - kind: registry
    name: codspeed-divan-compat-macros
    version: 4.3.0
    sha: 56ca01ce4fd22b8dcc6c770dcd6b74343642e842482b94e8920d14e10c57638d
  - kind: registry
    name: codspeed-divan-compat-walltime
    version: 4.3.0
    sha: 720ab9d0714718afe5f5832be6e5f5eb5ce97836e24ca7bf7042eea4308b9fb8
  - kind: registry
    name: colorchoice
    version: 1.0.4
    sha: b05b61dc5112cbb17e4b6cd61790d9845d13888356391624cbe7e41efeac1e75
  - kind: registry
    name: colored
    version: 2.2.0
    sha: 117725a109d387c937a1533ce01b450cbde6b88abceea8473c4d7a85853cda3c
  - kind: registry
    name: compare
    version: 0.1.0
    sha: 120133d4db2ec47efe2e26502ee984747630c67f51974fca0b6c1340cf2368d3
  - kind: registry
    name: condtype
    version: 1.3.0
    sha: baf0a07a401f374238ab8e2f11a104d2851bf9ce711ec69804834de8af45c7af
  - kind: registry
    name: console
    version: 0.16.2
    sha: 03e45a4a8926227e4197636ba97a9fc9b00477e9f4bd711395687c5f0734bec4
  - kind: registry
    name: const-random
    version: 0.1.18
    sha: 87e00182fe74b066627d63b85fd550ac2998d4b0bd86bfed477a0ae4c7c71359
  - kind: registry
    name: const-random-macro
    version: 0.1.16
    sha: f9d839f2a20b0aee515dc581a6172f2321f96cab76c1a38a4c584a194955390e
  - kind: registry
    name: constant_time_eq
    version: 0.4.2
    sha: 3d52eff69cd5e647efe296129160853a42795992097e8af39800e1060caeea9b
  - kind: registry
    name: core-foundation-sys
    version: 0.8.7
    sha: 773648b94d0e5d620f64f280777445740e61fe701025087ec8b57f45c791888b
  - kind: registry
    name: core_maths
    version: 0.1.1
    sha: 77745e017f5edba1a9c1d854f6f3a52dac8a12dd5af5d2f54aecf61e43d80d30
  - kind: registry
    name: cpufeatures
    version: 0.2.17
    sha: 59ed5838eebb26a2bb2e58f6d5b5316989ae9d08bab10e0e6d103e656d1b0280
  - kind: registry
    name: crc
    version: 3.3.0
    sha: 9710d3b3739c2e349eb44fe848ad0b7c8cb1e42bd87ee49371df2f7acaf3e675
  - kind: registry
    name: crc-catalog
    version: 2.4.0
    sha: 19d374276b40fb8bbdee95aef7c7fa6b5316ec764510eb64b8dd0e2ed0d7e7f5
  - kind: registry
    name: crc-fast
    version: 1.9.0
    sha: 2fd92aca2c6001b1bf5ba0ff84ee74ec8501b52bbef0cac80bf25a6c1d87a83d
  - kind: registry
    name: crc32fast
    version: 1.5.0
    sha: 9481c1c90cbf2ac953f07c8d4a58aa3945c425b7185c9154d67a65e4230da511
  - kind: registry
    name: crossbeam-deque
    version: 0.8.6
    sha: 9dd111b7b7f7d55b72c0a6ae361660ee5853c9af73f70c3c2ef6858b950e2e51
  - kind: registry
    name: crossbeam-epoch
    version: 0.9.18
    sha: 5b82ac4a3c2ca9c3460964f020e1402edd5753411d7737aa39c3714ad1b5420e
  - kind: registry
    name: crossbeam-utils
    version: 0.8.21
    sha: d0a5c400df2834b80a4c3327b3aad3a4c4cd4de0629063962b03235697506a28
  - kind: registry
    name: crossterm
    version: 0.29.0
    sha: d8b9f2e4c67f833b660cdb0a3523065869fb35570177239812ed4c905aeff87b
  - kind: registry
    name: crossterm_winapi
    version: 0.9.1
    sha: acdd7c62a3665c7f6830a51635d9ac9b23ed385797f70a83bb8bafe9c572ab2b
  - kind: registry
    name: crunchy
    version: 0.2.4
    sha: 460fbee9c2c2f33933d720630a6a0bac33ba7053db5344fac858d4b8952d77d5
  - kind: registry
    name: crypto-common
    version: 0.1.7
    sha: 78c8292055d1c1df0cce5d180393dc8cce0abec0a7102adb6c7b1eef6016d60a
  - kind: registry
    name: ctor
    version: 0.6.3
    sha: 424e0138278faeb2b401f174ad17e715c829512d74f3d1e81eb43365c2e0590e
  - kind: registry
    name: ctor-proc-macro
    version: 0.0.7
    sha: 52560adf09603e58c9a7ee1fe1dcb95a16927b17c127f0ac02d6e768a0e25bc1
  - kind: registry
    name: ctrlc
    version: 3.5.1
    sha: 73736a89c4aff73035ba2ed2e565061954da00d4970fc9ac25dcc85a2a20d790
  - kind: registry
    name: data-encoding
    version: 2.10.0
    sha: d7a1e2f27636f116493b8b860f5546edb47c8d8f8ea73e1d2a20be88e28d1fea
  - kind: registry
    name: data-encoding-macro
    version: 0.1.19
    sha: 8142a83c17aa9461d637e649271eae18bf2edd00e91f2e105df36c3c16355bdb
  - kind: registry
    name: data-encoding-macro-internal
    version: 0.1.17
    sha: 7ab67060fc6b8ef687992d439ca0fa36e7ed17e9a0b16b25b601e8757df720de
  - kind: registry
    name: deranged
    version: 0.5.5
    sha: ececcb659e7ba858fb4f10388c250a7252eb0a27373f1a72b8748afdd248e587
  - kind: registry
    name: diff
    version: 0.1.13
    sha: 56254986775e3233ffa9c4d7d3faaf6d36a2c09d30b20687e9f88bc8bafc16c8
  - kind: registry
    name: digest
    version: 0.10.7
    sha: 9ed9a281f7bc9b7576e61468ba615a66a5c8cfdff42420a70aa82701a3b1e292
  - kind: registry
    name: dispatch2
    version: 0.3.0
    sha: 89a09f22a6c6069a18470eb92d2298acf25463f14256d24778e1230d789a2aec
  - kind: registry
    name: displaydoc
    version: 0.2.5
    sha: 97369cbbc041bc366949bc74d34658d6cda5621039731c6310521892a3a20ae0
  - kind: registry
    name: divan-macros
    version: 0.1.17
    sha: 8dc51d98e636f5e3b0759a39257458b22619cac7e96d932da6eeb052891bb67c
  - kind: registry
    name: dlv-list
    version: 0.5.2
    sha: 442039f5147480ba31067cb00ada1adae6892028e40e45fc5de7b7df6dcc1b5f
  - kind: registry
    name: dns-lookup
    version: 3.0.1
    sha: 6e39034cee21a2f5bbb66ba0e3689819c4bb5d00382a282006e802a7ffa6c41d
  - kind: registry
    name: document-features
    version: 0.2.12
    sha: d4b8a88685455ed29a21542a33abd9cb6510b6b129abadabdcef0f4c55bc8f61
  - kind: registry
    name: dtor
    version: 0.1.1
    sha: 404d02eeb088a82cfd873006cb713fe411306c7d182c344905e101fb1167d301
  - kind: registry
    name: dtor-proc-macro
    version: 0.0.6
    sha: f678cf4a922c215c63e0de95eb1ff08a958a81d47e485cf9da1e27bf6305cfa5
  - kind: registry
    name: dunce
    version: 1.0.5
    sha: 92773504d58c093f6de2459af4af33faa518c13451eb8f2b5698ed3d36e7c813
  - kind: registry
    name: either
    version: 1.15.0
    sha: 48c757948c5ede0e46177b7add2e67155f70e33c07fea8284df6576da70b3719
  - kind: registry
    name: encode_unicode
    version: 1.0.0
    sha: 34aa73646ffb006b8f5147f3dc182bd4bcb190227ce861fc4a4844bf8e3cb2c0
  - kind: registry
    name: equivalent
    version: 1.0.2
    sha: 877a4ace8713b0bcf2a4e7eec82529c029f1d0619886d18145fea96c3ffe5c0f
  - kind: registry
    name: errno
    version: 0.3.14
    sha: 39cab71617ae0d63f51a36d69f866391735b51691dbda63cf6f96d042b63efeb
  - kind: registry
    name: exacl
    version: 0.12.0
    sha: 22be12de19decddab85d09f251ec8363f060ccb22ec9c81bc157c0c8433946d8
  - kind: registry
    name: fastrand
    version: 2.3.0
    sha: 37909eebbb50d72f9059c3b6d82c0463f2ff062c9e95845c43a6c9c0355411be
  - kind: registry
    name: file_diff
    version: 1.0.0
    sha: 31a7a908b8f32538a2143e59a6e4e2508988832d5d4d6f7c156b3cbc762643a5
  - kind: registry
    name: filedescriptor
    version: 0.8.3
    sha: e40758ed24c9b2eeb76c35fb0aebc66c626084edd827e07e1552279814c6682d
  - kind: registry
    name: filetime
    version: 0.2.27
    sha: f98844151eee8917efc50bd9e8318cb963ae8b297431495d3f758616ea5c57db
  - kind: registry
    name: find-msvc-tools
    version: 0.1.9
    sha: 5baebc0774151f905a1a2cc41989300b1e6fbb29aff0ceffa1064fdd3088d582
  - kind: registry
    name: fixed_decimal
    version: 0.7.1
    sha: 35eabf480f94d69182677e37571d3be065822acfafd12f2f085db44fbbcc8e57
  - kind: registry
    name: flate2
    version: 1.1.9
    sha: 843fba2746e448b37e26a819579957415c8cef339bf08564fe8b7ddbd959573c
  - kind: registry
    name: fluent
    version: 0.17.0
    sha: 8137a6d5a2c50d6b0ebfcb9aaa91a28154e0a70605f112d30cb0cd4a78670477
  - kind: registry
    name: fluent-bundle
    version: 0.16.0
    sha: 01203cb8918f5711e73891b347816d932046f95f54207710bda99beaeb423bf4
  - kind: registry
    name: fluent-langneg
    version: 0.13.1
    sha: 7eebbe59450baee8282d71676f3bfed5689aeab00b27545e83e5f14b1195e8b0
  - kind: registry
    name: fluent-syntax
    version: 0.12.0
    sha: 54f0d287c53ffd184d04d8677f590f4ac5379785529e5e08b1c8083acdd5c198
  - kind: registry
    name: foldhash
    version: 0.1.5
    sha: d9c4f5dac5e15c24eb999c26181a6ca40b39fe946cbe4c263c7209467bc83af2
  - kind: registry
    name: fs_extra
    version: 1.3.0
    sha: 42703706b716c37f96a77aea830392ad231f44c9e9a67872fa5548707e11b11c
  - kind: registry
    name: fsevent-sys
    version: 4.1.0
    sha: 76ee7a02da4d231650c7cea31349b889be2f45ddb3ef3032d2ec8185f6313fd2
  - kind: registry
    name: fts-sys
    version: 0.2.17
    sha: 9c03259139c9b098dd92241b046fedfeebcd6b000d491c821b24ced28558a9c2
  - kind: registry
    name: funty
    version: 2.0.0
    sha: e6d5a32815ae3f33302d95fdcb2ce17862f8c65363dcfd29360480ba1001fc9c
  - kind: registry
    name: futures-core
    version: 0.3.31
    sha: 05f29059c0c2090612e8d742178b0580d2dc940c837851ad723096f87af6663e
  - kind: registry
    name: futures-macro
    version: 0.3.31
    sha: 162ee34ebcb7c64a8abebc059ce0fee27c2262618d7b60ed8faf72fef13c3650
  - kind: registry
    name: futures-task
    version: 0.3.31
    sha: f90f7dce0722e95104fcb095585910c0977252f286e354b5e3bd38902cd99988
  - kind: registry
    name: futures-timer
    version: 3.0.3
    sha: f288b0a4f20f9a56b5d1da57e2227c661b7b16168e2f72365f57b63326e29b24
  - kind: registry
    name: futures-util
    version: 0.3.31
    sha: 9fa08315bb612088cc391249efdc3bc77536f16c91f6cf495e6fbe85b20a4a81
  - kind: registry
    name: gcd
    version: 2.3.0
    sha: 1d758ba1b47b00caf47f24925c0074ecb20d6dfcffe7f6d53395c0465674841a
  - kind: registry
    name: generic-array
    version: 0.14.7
    sha: 85649ca51fd72272d7821adaf274ad91c288277713d9c18820d8499a7ff69e9a
  - kind: registry
    name: getrandom
    version: 0.2.17
    sha: ff2abc00be7fca6ebc474524697ae276ad847ad0a6b3faa4bcb027e9a4614ad0
  - kind: registry
    name: getrandom
    version: 0.3.4
    sha: 899def5c37c4fd7b2664648c28120ecec138e4d395b459e5ca34f9cce2dd77fd
  - kind: registry
    name: glob
    version: 0.3.3
    sha: 0cc23270f6e1808e30a928bdc84dea0b9b4136a8bc82338574f23baf47bbd280
  - kind: registry
    name: half
    version: 2.7.1
    sha: 6ea2d84b969582b4b1864a92dc5d27cd2b77b622a8d79306834f1be5ba20d84b
  - kind: registry
    name: hashbrown
    version: 0.14.5
    sha: e5274423e17b7c9fc20b6e7e208532f9b19825d82dfd615708b70edd83df41f1
  - kind: registry
    name: hashbrown
    version: 0.15.5
    sha: 9229cfe53dfd69f0609a49f65461bd93001ea1ef889cd5529dd176593f5338a1
  - kind: registry
    name: hashbrown
    version: 0.16.1
    sha: 841d1cc9bed7f9236f321df977030373f4a4163ae1a7dbfe1a51a2c1a51d9100
  - kind: registry
    name: hex
    version: 0.4.3
    sha: 7f24254aa9a54b5c858eaee2f5bccdb46aaf0e486a595ed5fd8f86ba55232a70
  - kind: registry
    name: hex-literal
    version: 1.1.0
    sha: e712f64ec3850b98572bffac52e2c6f282b29fe6c5fa6d42334b30be438d95c1
  - kind: registry
    name: hostname
    version: 0.4.2
    sha: 617aaa3557aef3810a6369d0a99fac8a080891b68bd9f9812a1eeda0c0730cbd
  - kind: registry
    name: iana-time-zone
    version: 0.1.65
    sha: e31bc9ad994ba00e440a8aa5c9ef0ec67d5cb5e5cb0cc7f8b744a35b389cc470
  - kind: registry
    name: iana-time-zone-haiku
    version: 0.1.2
    sha: f31827a206f56af32e590ba56d5d2d085f558508192593743f16b2306495269f
  - kind: registry
    name: icu_calendar
    version: 2.1.1
    sha: d6f0e52e009b6b16ba9c0693578796f2dd4aaa59a7f8f920423706714a89ac4e
  - kind: registry
    name: icu_calendar_data
    version: 2.1.1
    sha: 527f04223b17edfe0bd43baf14a0cb1b017830db65f3950dc00224860a9a446d
  - kind: registry
    name: icu_collator
    version: 2.1.1
    sha: 32eed11a5572f1088b63fa21dc2e70d4a865e5739fc2d10abc05be93bae97019
  - kind: registry
    name: icu_collator_data
    version: 2.1.1
    sha: 5ab06f0e83a613efddba3e4913e00e43ed4001fae651cb7d40fc7e66b83b6fb9
  - kind: registry
    name: icu_collections
    version: 2.1.1
    sha: 4c6b649701667bbe825c3b7e6388cb521c23d88644678e83c0c4d0a621a34b43
  - kind: registry
    name: icu_datetime
    version: 2.1.1
    sha: 1b9d49f41ded8e63761b6b4c3120dfdc289415a1ed10107db6198eb311057ca5
  - kind: registry
    name: icu_datetime_data
    version: 2.1.2
    sha: 46597233625417b7c8052a63d916e4fdc73df21614ac0b679492a5d6e3b01aeb
  - kind: registry
    name: icu_decimal
    version: 2.1.1
    sha: a38c52231bc348f9b982c1868a2af3195199623007ba2c7650f432038f5b3e8e
  - kind: registry
    name: icu_decimal_data
    version: 2.1.1
    sha: 2905b4044eab2dd848fe84199f9195567b63ab3a93094711501363f63546fef7
  - kind: registry
    name: icu_locale
    version: 2.1.1
    sha: 532b11722e350ab6bf916ba6eb0efe3ee54b932666afec989465f9243fe6dd60
  - kind: registry
    name: icu_locale_core
    version: 2.1.1
    sha: edba7861004dd3714265b4db54a3c390e880ab658fec5f7db895fae2046b5bb6
  - kind: registry
    name: icu_locale_data
    version: 2.1.2
    sha: 1c5f1d16b4c3a2642d3a719f18f6b06070ab0aef246a6418130c955ae08aa831
  - kind: registry
    name: icu_normalizer
    version: 2.1.1
    sha: 5f6c8828b67bf8908d82127b2054ea1b4427ff0230ee9141c54251934ab1b599
  - kind: registry
    name: icu_normalizer_data
    version: 2.1.1
    sha: 7aedcccd01fc5fe81e6b489c15b247b8b0690feb23304303a9e560f37efc560a
  - kind: registry
    name: icu_pattern
    version: 0.4.1
    sha: 7a7ff8c0ff6f61cdce299dcb54f557b0a251adbc78f6f0c35a21332c452b4a1b
  - kind: registry
    name: icu_plurals
    version: 2.1.1
    sha: 4f9cfe49f5b1d1163cc58db451562339916a9ca5cbcaae83924d41a0bf839474
  - kind: registry
    name: icu_plurals_data
    version: 2.1.1
    sha: f018a98dccf7f0eb02ba06ac0ff67d102d8ded80734724305e924de304e12ff0
  - kind: registry
    name: icu_properties
    version: 2.1.2
    sha: 020bfc02fe870ec3a66d93e677ccca0562506e5872c650f893269e08615d74ec
  - kind: registry
    name: icu_properties_data
    version: 2.1.2
    sha: 616c294cf8d725c6afcd8f55abc17c56464ef6211f9ed59cccffe534129c77af
  - kind: registry
    name: icu_provider
    version: 2.1.1
    sha: 85962cf0ce02e1e0a629cc34e7ca3e373ce20dda4c4d7294bbd0bf1fdb59e614
  - kind: registry
    name: icu_time
    version: 2.1.1
    sha: 8242b00da3b3b6678f731437a11c8833a43c821ae081eca60ba1b7579d45b6d8
  - kind: registry
    name: icu_time_data
    version: 2.1.1
    sha: 3e10b0e5e87a2c84bd5fa407705732052edebe69291d347d0c3033785470edbf
  - kind: registry
    name: indexmap
    version: 2.13.0
    sha: 7714e70437a7dc3ac8eb7e6f8df75fd8eb422675fc7678aff7364301092b1017
  - kind: registry
    name: indicatif
    version: 0.18.3
    sha: 9375e112e4b463ec1b1c6c011953545c65a30164fbab5b581df32b3abf0dcb88
  - kind: registry
    name: inotify
    version: 0.11.0
    sha: f37dccff2791ab604f9babef0ba14fbe0be30bd368dc541e2b08d07c8aa908f3
  - kind: registry
    name: inotify-sys
    version: 0.1.5
    sha: e05c02b5e89bff3b946cedeca278abc628fe811e604f027c45a8aa3cf793d0eb
  - kind: registry
    name: intl-memoizer
    version: 0.5.3
    sha: 310da2e345f5eb861e7a07ee182262e94975051db9e4223e909ba90f392f163f
  - kind: registry
    name: intl_pluralrules
    version: 7.0.2
    sha: 078ea7b7c29a2b4df841a7f6ac8775ff6074020c6776d48491ce2268e068f972
  - kind: registry
    name: is_terminal_polyfill
    version: 1.70.2
    sha: a6cb138bb79a146c1bd460005623e142ef0181e3d0219cb493e02f7d08a35695
  - kind: registry
    name: itertools
    version: 0.13.0
    sha: 413ee7dfc52ee1a4949ceeb7dbc8a33f2d6c088194d9f922fb8318faf1f01186
  - kind: registry
    name: itertools
    version: 0.14.0
    sha: 2b192c782037fadd9cfa75548310488aabdbf3d2da73885b31bd0abd03351285
  - kind: registry
    name: itoa
    version: 1.0.17
    sha: 92ecc6618181def0457392ccd0ee51198e065e016d1d527a7ac1b6dc7c1f09d2
  - kind: registry
    name: ixdtf
    version: 0.6.4
    sha: 84de9d95a6d2547d9b77ee3f25fa0ee32e3c3a6484d47a55adebc0439c077992
  - kind: registry
    name: jiff
    version: 0.2.20
    sha: c867c356cc096b33f4981825ab281ecba3db0acefe60329f044c1789d94c6543
  - kind: registry
    name: jiff-icu
    version: 0.2.2
    sha: 0e67c2beaae8b10a82d849b9aabb698a43a682f32b17bcdc035d5ecadb44d646
  - kind: registry
    name: jiff-static
    version: 0.2.20
    sha: f7946b4325269738f270bb55b3c19ab5c5040525f83fd625259422a9d25d9be5
  - kind: registry
    name: jiff-tzdb
    version: 0.1.5
    sha: 68971ebff725b9e2ca27a601c5eb38a4c5d64422c4cbab0c535f248087eda5c2
  - kind: registry
    name: jiff-tzdb-platform
    version: 0.1.3
    sha: 875a5a69ac2bab1a891711cf5eccbec1ce0341ea805560dcd90b7a2e925132e8
  - kind: registry
    name: js-sys
    version: 0.3.85
    sha: 8c942ebf8e95485ca0d52d97da7c5a2c387d0e7f0ba4c35e93bfcaee045955b3
  - kind: registry
    name: keccak
    version: 0.1.5
    sha: ecc2af9a1119c51f12a14607e783cb977bde58bc069ff0c3da1095e635d70654
  - kind: registry
    name: kqueue
    version: 1.1.1
    sha: eac30106d7dce88daf4a3fcb4879ea939476d5074a9b7ddd0fb97fa4bed5596a
  - kind: registry
    name: kqueue-sys
    version: 1.0.4
    sha: ed9625ffda8729b85e45cf04090035ac368927b8cebc34898e7c120f52e4838b
  - kind: registry
    name: lazy_static
    version: 1.5.0
    sha: bbd2bcb4c963f2ddae06a2efc7e9f3591312473c50c6685e1f298068316e66fe
  - kind: registry
    name: libc
    version: 0.2.180
    sha: bcc35a38544a891a5f7c865aca548a982ccb3b8650a5b06d0fd33a10283c56fc
  - kind: registry
    name: libloading
    version: 0.8.9
    sha: d7c4b02199fee7c5d21a5ae7d8cfa79a6ef5bb2fc834d6e9058e89c825efdc55
  - kind: registry
    name: libm
    version: 0.2.16
    sha: b6d2cec3eae94f9f509c767b45932f1ada8350c4bdb85af2fcab4a3c14807981
  - kind: registry
    name: libredox
    version: 0.1.12
    sha: 3d0b95e02c851351f877147b7deea7b1afb1df71b63aa5f8270716e0c5720616
  - kind: registry
    name: linux-raw-sys
    version: 0.11.0
    sha: df1d3c3b53da64cf5760482273a98e575c651a67eec7f77df96b5b642de8f039
  - kind: registry
    name: litemap
    version: 0.8.1
    sha: 6373607a59f0be73a39b6fe456b8192fcc3585f602af20751600e974dd455e77
  - kind: registry
    name: litrs
    version: 1.0.0
    sha: 11d3d7f243d5c5a8b9bb5d6dd2b1602c0cb0b9db1621bafc7ed66e35ff9fe092
  - kind: registry
    name: lock_api
    version: 0.4.14
    sha: 224399e74b87b5f3557511d98dff8b14089b3dadafcab6bb93eab67d3aace965
  - kind: registry
    name: log
    version: 0.4.29
    sha: 5e5032e24019045c762d3c0f28f5b6b8bbf38563a65908389bf7978758920897
  - kind: registry
    name: lru
    version: 0.12.5
    sha: 234cf4f4a04dc1f57e24b96cc0cd600cf2af460d4161ac5ecdd0af8e1f3b2a38
  - kind: registry
    name: lscolors
    version: 0.21.0
    sha: d60e266dfb1426eb2d24792602e041131fdc0236bb7007abc0e589acafd60929
  - kind: registry
    name: md-5
    version: 0.10.6
    sha: d89e7ee0cfbedfc4da3340218492196241d89eefb6dab27de5df917a6d2e78cf
  - kind: registry
    name: memchr
    version: 2.8.0
    sha: f8ca58f447f06ed17d5fc4043ce1b10dd205e060fb3ce5b979b8ed8e59ff3f79
  - kind: registry
    name: memmap2
    version: 0.9.9
    sha: 744133e4a0e0a658e1374cf3bf8e415c4052a15a111acd372764c55b4177d490
  - kind: registry
    name: memoffset
    version: 0.9.1
    sha: 488016bfae457b036d996092f6cb448677611ce4449e970ceaf42695203f218a
  - kind: registry
    name: minimal-lexical
    version: 0.2.1
    sha: 68354c5c6bd36d73ff3feceb05efa59b6acb7626617f4962be322a825e61f79a
  - kind: registry
    name: miniz_oxide
    version: 0.8.9
    sha: 1fa76a2c86f704bdb222d66965fb3d63269ce38518b83cb0575fca855ebb6316
  - kind: registry
    name: mio
    version: 1.1.1
    sha: a69bcab0ad47271a0234d9422b131806bf3968021e5dc9328caf2d4cd58557fc
  - kind: registry
    name: nix
    version: 0.30.1
    sha: 74523f3a35e05aba87a1d978330aef40f67b0304ac79c1c00b294c9830543db6
  - kind: registry
    name: nom
    version: 7.1.3
    sha: d273983c5a657a70a3e8f2a01329822f3b8c8172b73826411a55751e404a0a4a
  - kind: registry
    name: nom
    version: 8.0.0
    sha: df9761775871bdef83bee530e60050f7e54b1105350d6884eb0fb4f46c2f9405
  - kind: registry
    name: notify
    version: 8.2.0
    sha: 4d3d07927151ff8575b7087f245456e549fea62edf0ec4e565a5ee50c8402bc3
  - kind: registry
    name: notify-types
    version: 2.1.0
    sha: 42b8cfee0e339a0337359f3c88165702ac6e600dc01c0cc9579a92d62b08477a
  - kind: registry
    name: nu-ansi-term
    version: 0.50.3
    sha: 7957b9740744892f114936ab4a57b3f487491bbeafaf8083688b16841a4240e5
  - kind: registry
    name: num-bigint
    version: 0.4.6
    sha: a5e44f723f1133c9deac646763579fdb3ac745e418f2a7af9cd0c431da1f20b9
  - kind: registry
    name: num-conv
    version: 0.2.0
    sha: cf97ec579c3c42f953ef76dbf8d55ac91fb219dde70e49aa4a6b7d74e9919050
  - kind: registry
    name: num-integer
    version: 0.1.46
    sha: 7969661fd2958a5cb096e56c8e1ad0444ac2bbcd0061bd28660485a44879858f
  - kind: registry
    name: num-modular
    version: 0.5.1
    sha: 64a5fe11d4135c3bcdf3a95b18b194afa9608a5f6ff034f5d857bc9a27fb0119
  - kind: registry
    name: num-prime
    version: 0.4.4
    sha: e238432a7881ec7164503ccc516c014bf009be7984cde1ba56837862543bdec3
  - kind: registry
    name: num-traits
    version: 0.2.19
    sha: 071dfc062690e90b734c0b2273ce72ad0ffa95f0c74596bc250dcfd960262841
  - kind: registry
    name: num_threads
    version: 0.1.7
    sha: 5c7398b9c8b70908f6371f47ed36737907c87c52af34c268fed0bf0ceb92ead9
  - kind: registry
    name: objc2
    version: 0.6.3
    sha: b7c2599ce0ec54857b29ce62166b0ed9b4f6f1a70ccc9a71165b6154caca8c05
  - kind: registry
    name: objc2-encode
    version: 4.1.0
    sha: ef25abbcd74fb2609453eb695bd2f860d389e457f67dc17cafc8b8cbc89d0c33
  - kind: registry
    name: once_cell
    version: 1.21.3
    sha: 42f5e15c9953c5e4ccceeb2e7382a716482c34515315f7b03532b8b4e8393d2d
  - kind: registry
    name: once_cell_polyfill
    version: 1.70.2
    sha: 384b8ab6d37215f3c5301a95a4accb5d64aa607f1fcb26a11b5303878451b4fe
  - kind: registry
    name: onig
    version: 6.5.1
    sha: 336b9c63443aceef14bea841b899035ae3abe89b7c486aaf4c5bd8aafedac3f0
  - kind: registry
    name: onig_sys
    version: 69.9.1
    sha: c7f86c6eef3d6df15f23bcfb6af487cbd2fed4e5581d58d5bf1f5f8b7f6727dc
  - kind: registry
    name: ordered-multimap
    version: 0.7.3
    sha: 49203cdcae0030493bad186b28da2fa25645fa276a51b6fec8010d281e02ef79
  - kind: registry
    name: os_display
    version: 0.1.4
    sha: ad5fd71b79026fb918650dde6d125000a233764f1c2f1659a1c71118e33ea08f
  - kind: registry
    name: outref
    version: 0.5.2
    sha: 1a80800c0488c3a21695ea981a54918fbb37abf04f4d0720c453632255e2ff0e
  - kind: registry
    name: parking_lot
    version: 0.12.5
    sha: 93857453250e3077bd71ff98b6a65ea6621a19bb0f559a85248955ac12c45a1a
  - kind: registry
    name: parking_lot_core
    version: 0.9.12
    sha: 2621685985a2ebf1c516881c026032ac7deafcda1a2c9b7850dc81e3dfcb64c1
  - kind: registry
    name: parse_datetime
    version: 0.14.0
    sha: 413775a7eac2261d2211a79d10ef275e5b6f7b527eec42ad09adce2ffa92b6e5
  - kind: registry
    name: phf
    version: 0.13.1
    sha: c1562dc717473dbaa4c1f85a36410e03c047b2e7df7f45ee938fbef64ae7fadf
  - kind: registry
    name: phf_codegen
    version: 0.13.1
    sha: 49aa7f9d80421bca176ca8dbfebe668cc7a2684708594ec9f3c0db0805d5d6e1
  - kind: registry
    name: phf_generator
    version: 0.13.1
    sha: 135ace3a761e564ec88c03a77317a7c6b80bb7f7135ef2544dbe054243b89737
  - kind: registry
    name: phf_shared
    version: 0.13.1
    sha: e57fef6bc5981e38c2ce2d63bfa546861309f875b8a75f092d1d54ae2d64f266
  - kind: registry
    name: pin-project-lite
    version: 0.2.16
    sha: 3b3cff922bd51709b605d9ead9aa71031d81447142d828eb4a6eba76fe619f9b
  - kind: registry
    name: pin-utils
    version: 0.1.0
    sha: 8b870d8c151b6f2fb93e84a13146138f05d02ed11c7e7c54f8826aaaf7c9f184
  - kind: registry
    name: pkg-config
    version: 0.3.32
    sha: 7edddbd0b52d732b21ad9a5fab5c704c14cd949e5e9a1ec5929a24fded1b904c
  - kind: registry
    name: platform-info
    version: 2.0.5
    sha: 7539aeb3fdd8cb4f6a331307cf71a1039cee75e94e8a71725b9484f4a0d9451a
  - kind: registry
    name: portable-atomic
    version: 1.13.1
    sha: c33a9471896f1c69cecef8d20cbe2f7accd12527ce60845ff44c153bb2a21b49
  - kind: registry
    name: portable-atomic-util
    version: 0.2.5
    sha: 7a9db96d7fa8782dd8c15ce32ffe8680bbd1e978a43bf51a34d39483540495f5
  - kind: registry
    name: potential_utf
    version: 0.1.4
    sha: b73949432f5e2a09657003c25bca5e19a0e9c84f8058ca374f49e0ebe605af77
  - kind: registry
    name: powerfmt
    version: 0.2.0
    sha: 439ee305def115ba05938db6eb1644ff94165c5ab5e9420d1c1bcedbba909391
  - kind: registry
    name: ppv-lite86
    version: 0.2.21
    sha: 85eae3c4ed2f50dcfe72643da4befc30deadb458a9b590d720cde2f2b1e97da9
  - kind: registry
    name: pretty_assertions
    version: 1.4.1
    sha: 3ae130e2f271fbc2ac3a40fb1d07180839cdbbe443c7a27e1e3c13c5cac0116d
  - kind: registry
    name: prettyplease
    version: 0.2.37
    sha: 479ca8adacdd7ce8f1fb39ce9ecccbfe93a3f1344b3d0d97f20bc0196208f62b
  - kind: registry
    name: proc-macro-crate
    version: 3.4.0
    sha: 219cb19e96be00ab2e37d6e299658a0cfa83e52429179969b0f0121b4ac46983
  - kind: registry
    name: proc-macro2
    version: 1.0.106
    sha: 8fd00f0bb2e90d81d1044c2b32617f68fcb9fa3bb7640c23e9c748e53fb30934
  - kind: registry
    name: procfs
    version: 0.18.0
    sha: 25485360a54d6861439d60facef26de713b1e126bf015ec8f98239467a2b82f7
  - kind: registry
    name: procfs-core
    version: 0.18.0
    sha: e6401bf7b6af22f78b563665d15a22e9aef27775b79b149a66ca022468a4e405
  - kind: registry
    name: quote
    version: 1.0.44
    sha: 21b2ebcf727b7760c461f091f9f0f539b77b8e87f2fd88131e7f1b433b3cece4
  - kind: registry
    name: r-efi
    version: 5.3.0
    sha: 69cdb34c158ceb288df11e18b4bd39de994f6657d83847bdffdbd7f346754b0f
  - kind: registry
    name: radium
    version: 0.7.0
    sha: dc33ff2d4973d518d823d61aa239014831e521c75da58e3df4840d3f47749d09
  - kind: registry
    name: rand
    version: 0.8.5
    sha: 34af8d1a0e25924bc5b7c43c079c942339d8f0a8b57c39049bef581b46327404
  - kind: registry
    name: rand
    version: 0.9.2
    sha: 6db2770f06117d490610c7488547d543617b21bfa07796d7a12f6f1bd53850d1
  - kind: registry
    name: rand_chacha
    version: 0.3.1
    sha: e6c10a63a0fa32252be49d21e7709d4d4baf8d231c2dbce1eaa8141b9b127d88
  - kind: registry
    name: rand_chacha
    version: 0.9.0
    sha: d3022b5f1df60f26e1ffddd6c66e8aa15de382ae63b3a0c1bfc0e4d3e3f325cb
  - kind: registry
    name: rand_core
    version: 0.6.4
    sha: ec0be4795e2f6a28069bec0b5ff3e2ac9bafc99e6a9a7dc3547996c5c816922c
  - kind: registry
    name: rand_core
    version: 0.9.5
    sha: 76afc826de14238e6e8c374ddcc1fa19e374fd8dd986b0d2af0d02377261d83c
  - kind: registry
    name: rayon
    version: 1.11.0
    sha: 368f01d005bf8fd9b1206fb6fa653e6c4a81ceb1466406b81792d87c5677a58f
  - kind: registry
    name: rayon-core
    version: 1.13.0
    sha: 22e18b0f0062d30d4230b2e85ff77fdfe4326feb054b9783a3460d8435c8ab91
  - kind: registry
    name: redox_syscall
    version: 0.5.18
    sha: ed2bf2547551a7053d6fdfafda3f938979645c44812fbfcda098faae3f1a362d
  - kind: registry
    name: redox_syscall
    version: 0.7.0
    sha: 49f3fe0889e69e2ae9e41f4d6c4c0181701d00e4697b356fb1f74173a5e0ee27
  - kind: registry
    name: regex
    version: 1.12.3
    sha: e10754a14b9137dd7b1e3e5b0493cc9171fdd105e0ab477f51b72e7f3ac0e276
  - kind: registry
    name: regex-automata
    version: 0.4.14
    sha: 6e1dd4122fc1595e8162618945476892eefca7b88c52820e74af6262213cae8f
  - kind: registry
    name: regex-lite
    version: 0.1.9
    sha: cab834c73d247e67f4fae452806d17d3c7501756d98c8808d7c9c7aa7d18f973
  - kind: registry
    name: regex-syntax
    version: 0.8.9
    sha: a96887878f22d7bad8a3b6dc5b7440e0ada9a245242924394987b21cf2210a4c
  - kind: registry
    name: relative-path
    version: 1.9.3
    sha: ba39f3699c378cd8970968dcbff9c43159ea4cfbd88d43c00b22f2ef10a435d2
  - kind: registry
    name: rlimit
    version: 0.11.0
    sha: f35ee2729c56bb610f6dba436bf78135f728b7373bdffae2ec815b2d3eb98cc3
  - kind: registry
    name: roff
    version: 0.2.2
    sha: 88f8660c1ff60292143c98d08fc6e2f654d722db50410e3f3797d40baaf9d8f3
  - kind: registry
    name: rstest
    version: 0.26.1
    sha: f5a3193c063baaa2a95a33f03035c8a72b83d97a54916055ba22d35ed3839d49
  - kind: registry
    name: rstest_macros
    version: 0.26.1
    sha: 9c845311f0ff7951c5506121a9ad75aec44d083c31583b2ea5a30bcb0b0abba0
  - kind: registry
    name: rust-ini
    version: 0.21.3
    sha: 796e8d2b6696392a43bea58116b667fb4c29727dc5abd27d6acf338bb4f688c7
  - kind: registry
    name: rustc-hash
    version: 2.1.1
    sha: 357703d41365b4b27c590e3ed91eabb1b663f07c4c084095e60cbed4362dff0d
  - kind: registry
    name: rustc_version
    version: 0.4.1
    sha: cfcb3a22ef46e85b45de6ee7e79d063319ebb6594faafcf1c225ea92ab6e9b92
  - kind: registry
    name: rustix
    version: 1.1.3
    sha: 146c9e247ccc180c1f61615433868c99f3de3ae256a30a43b49f67c2d9171f34
  - kind: registry
    name: rustversion
    version: 1.0.22
    sha: b39cdef0fa800fc44525c84ccb54a029961a8215f9619753635a9c0d2538d46d
  - kind: registry
    name: same-file
    version: 1.0.6
    sha: 93fc1dc3aaa9bfed95e02e6eadabb4baf7e3078b0bd1b4d7b6b0b68378900502
  - kind: registry
    name: scopeguard
    version: 1.2.0
    sha: 94143f37725109f92c262ed2cf5e59bce7498c01bcc1502d7b9afe439a4e9f49
  - kind: registry
    name: self_cell
    version: 1.2.2
    sha: b12e76d157a900eb52e81bc6e9f3069344290341720e9178cde2407113ac8d89
  - kind: registry
    name: selinux
    version: 0.6.0
    sha: 7f4d7a0c34b924081f7fbdcb93121399f0d4182c0ec4bf9c01bfe4e7e21fcf16
  - kind: registry
    name: selinux-sys
    version: 0.6.15
    sha: debaba5832b4831ffe0ba9118b526c752c960f41c46c4ef197d9a15f5179d6fd
  - kind: registry
    name: semver
    version: 1.0.27
    sha: d767eb0aabc880b29956c35734170f26ed551a859dbd361d140cdbeca61ab1e2
  - kind: registry
    name: serde
    version: 1.0.228
    sha: 9a8e94ea7f378bd32cbbd37198a4a91436180c5bb472411e48b5ec2e2124ae9e
  - kind: registry
    name: serde_core
    version: 1.0.228
    sha: 41d385c7d4ca58e59fc732af25c3983b67ac852c1a25000afe1175de458b67ad
  - kind: registry
    name: serde_derive
    version: 1.0.228
    sha: d540f220d3187173da220f885ab66608367b6574e925011a9353e4badda91d79
  - kind: registry
    name: serde_json
    version: 1.0.149
    sha: 83fc039473c5595ace860d8c4fafa220ff474b3fc6bfdb4293327f1a37e94d86
  - kind: registry
    name: sha1
    version: 0.10.6
    sha: e3bf829a2d51ab4a5ddf1352d8470c140cadc8301b2ae1789db023f01cedd6ba
  - kind: registry
    name: sha2
    version: 0.10.9
    sha: a7507d819769d01a365ab707794a4084392c824f54a7a6a7862f8c3d0892b283
  - kind: registry
    name: sha3
    version: 0.10.8
    sha: 75872d278a8f37ef87fa0ddbda7802605cb18344497949862c0d4dcb291eba60
  - kind: registry
    name: shlex
    version: 1.3.0
    sha: 0fda2ff0d084019ba4d7c6f371c95d8fd75ce3524c3cb8fb653a3023f6323e64
  - kind: registry
    name: signal-hook
    version: 0.3.18
    sha: d881a16cf4426aa584979d30bd82cb33429027e42122b169753d6ef1085ed6e2
  - kind: registry
    name: signal-hook-mio
    version: 0.2.5
    sha: b75a19a7a740b25bc7944bdee6172368f988763b744e3d4dfe753f6b4ece40cc
  - kind: registry
    name: signal-hook-registry
    version: 1.4.8
    sha: c4db69cba1110affc0e9f7bcd48bbf87b3f4fc7c61fc9155afd4c469eb3d6c1b
  - kind: registry
    name: simd-adler32
    version: 0.3.8
    sha: e320a6c5ad31d271ad523dcf3ad13e2767ad8b1cb8f047f75a8aeaf8da139da2
  - kind: registry
    name: siphasher
    version: 1.0.2
    sha: b2aa850e253778c88a04c3d7323b043aeda9d3e30d5971937c1855769763678e
  - kind: registry
    name: slab
    version: 0.4.12
    sha: 0c790de23124f9ab44544d7ac05d60440adc586479ce501c1d6d7da3cd8c9cf5
  - kind: registry
    name: sm3
    version: 0.4.2
    sha: ebb9a3b702d0a7e33bc4d85a14456633d2b165c2ad839c5fd9a8417c1ab15860
  - kind: registry
    name: smallvec
    version: 1.15.1
    sha: 67b1b7a3b5fe4f1376887184045fcf45c69e92af734b7aaddc05fb777b6fbd03
  - kind: registry
    name: smawk
    version: 0.3.2
    sha: b7c388c1b5e93756d0c740965c41e8822f866621d41acbdf6336a6a168f8840c
  - kind: registry
    name: socket2
    version: 0.6.2
    sha: 86f4aa3ad99f2088c990dfa82d367e19cb29268ed67c574d10d0a4bfe71f07e0
  - kind: registry
    name: spin
    version: 0.10.0
    sha: d5fe4ccb98d9c292d56fec89a5e07da7fc4cf0dc11e156b41793132775d3e591
  - kind: registry
    name: stable_deref_trait
    version: 1.2.1
    sha: 6ce2be8dc25455e1f91df71bfa12ad37d7af1092ae736f3a6cd0e37bc7810596
  - kind: registry
    name: statrs
    version: 0.18.0
    sha: 2a3fe7c28c6512e766b0874335db33c94ad7b8f9054228ae1c2abd47ce7d335e
  - kind: registry
    name: string-interner
    version: 0.19.0
    sha: 23de088478b31c349c9ba67816fa55d9355232d63c3afea8bf513e31f0f1d2c0
  - kind: registry
    name: strsim
    version: 0.11.1
    sha: 7da8b5736845d9f2fcb837ea5d9e2628564b3b043a70948a3f0b778838c5fb4f
  - kind: registry
    name: syn
    version: 2.0.114
    sha: d4d107df263a3013ef9b1879b0df87d706ff80f65a86ea879bd9c31f9b307c2a
  - kind: registry
    name: synstructure
    version: 0.13.2
    sha: 728a70f3dbaf5bab7f0c4b1ac8d7ae5ea60a4b5549c8a5914361c99147a709d2
  - kind: registry
    name: tap
    version: 1.0.1
    sha: 55937e1799185b12863d447f42597ed69d9928686b8d88a1df17376a097d8369
  - kind: registry
    name: tempfile
    version: 3.25.0
    sha: 0136791f7c95b1f6dd99f9cc786b91bb81c3800b639b3478e561ddb7be95e5f1
  - kind: registry
    name: terminal_size
    version: 0.4.3
    sha: 60b8cb979cb11c32ce1603f8137b22262a9d131aaa5c37b5678025f22b8becd0
  - kind: registry
    name: textwrap
    version: 0.16.2
    sha: c13547615a44dc9c452a8a534638acdf07120d4b6847c8178705da06306a3057
  - kind: registry
    name: thiserror
    version: 1.0.69
    sha: b6aaf5339b578ea85b50e080feb250a3e8ae8cfcdff9a461c9ec2904bc923f52
  - kind: registry
    name: thiserror
    version: 2.0.18
    sha: 4288b5bcbc7920c07a1149a35cf9590a2aa808e0bc1eafaade0b80947865fbc4
  - kind: registry
    name: thiserror-impl
    version: 1.0.69
    sha: 4fee6c4efc90059e10f81e6d42c60a18f76588c3d74cb83a0b242a2b6c7504c1
  - kind: registry
    name: thiserror-impl
    version: 2.0.18
    sha: ebc4ee7f67670e9b64d05fa4253e753e016c6c95ff35b89b7941d6b856dec1d5
  - kind: registry
    name: time
    version: 0.3.47
    sha: 743bd48c283afc0388f9b8827b976905fb217ad9e647fae3a379a9283c4def2c
  - kind: registry
    name: time-core
    version: 0.1.8
    sha: 7694e1cfe791f8d31026952abf09c69ca6f6fa4e1a1229e18988f06a04a12dca
  - kind: registry
    name: time-macros
    version: 0.2.27
    sha: 2e70e4c5a0e0a8a4823ad65dfe1a6930e4f4d756dcd9dd7939022b5e8c501215
  - kind: registry
    name: tiny-keccak
    version: 2.0.2
    sha: 2c9d3793400a45f954c52e73d068316d76b6f4e36977e3fcebb13a2721e80237
  - kind: registry
    name: tinystr
    version: 0.8.2
    sha: 42d3e9c45c09de15d06dd8acf5f4e0e399e85927b7f00711024eb7ae10fa4869
  - kind: registry
    name: toml_datetime
    version: 0.7.5+spec-1.1.0
    sha: 92e1cfed4a3038bc5a127e35a2d360f145e1f4b971b551a2ba5fd7aedf7e1347
  - kind: registry
    name: toml_edit
    version: 0.23.10+spec-1.0.0
    sha: 84c8b9f757e028cee9fa244aea147aab2a9ec09d5325a9b01e0a49730c2b5269
  - kind: registry
    name: toml_parser
    version: 1.0.6+spec-1.1.0
    sha: a3198b4b0a8e11f09dd03e133c0280504d0801269e9afa46362ffde1cbeebf44
  - kind: registry
    name: type-map
    version: 0.5.1
    sha: cb30dbbd9036155e74adad6812e9898d03ec374946234fbcebd5dfc7b9187b90
  - kind: registry
    name: typed-path
    version: 0.12.2
    sha: 3015e6ce46d5ad8751e4a772543a30c7511468070e98e64e20165f8f81155b64
  - kind: registry
    name: typenum
    version: 1.19.0
    sha: 562d481066bde0658276a35467c4af00bdc6ee726305698a55b86e61d7ad82bb
  - kind: registry
    name: unic-langid
    version: 0.9.6
    sha: a28ba52c9b05311f4f6e62d5d9d46f094bd6e84cb8df7b3ef952748d752a7d05
  - kind: registry
    name: unic-langid-impl
    version: 0.9.6
    sha: dce1bf08044d4b7a94028c93786f8566047edc11110595914de93362559bc658
  - kind: registry
    name: unicode-ident
    version: 1.0.22
    sha: 9312f7c4f6ff9069b165498234ce8be658059c6728633667c526e27dc2cf1df5
  - kind: registry
    name: unicode-linebreak
    version: 0.1.5
    sha: 3b09c83c3c29d37506a3e260c08c03743a6bb66a9cd432c6934ab501a190571f
  - kind: registry
    name: unicode-width
    version: 0.1.14
    sha: 7dd6e30e90baa6f72411720665d41d89b9a3d039dc45b8faea1ddd07f617f6af
  - kind: registry
    name: unicode-width
    version: 0.2.2
    sha: b4ac048d71ede7ee76d585517add45da530660ef4390e49b098733c6e897f254
  - kind: registry
    name: unindent
    version: 0.2.4
    sha: 7264e107f553ccae879d21fbea1d6724ac785e8c3bfc762137959b5802826ef3
  - kind: registry
    name: unit-prefix
    version: 0.5.2
    sha: 81e544489bf3d8ef66c953931f56617f423cd4b5494be343d9b9d3dda037b9a3
  - kind: registry
    name: utf16_iter
    version: 1.0.5
    sha: c8232dd3cdaed5356e0f716d285e4b40b932ac434100fe9b7e0e8e935b9e6246
  - kind: registry
    name: utf8_iter
    version: 1.0.4
    sha: b6c140620e7ffbb22c2dee59cafe6084a59b5ffc27a8859a5f0d494b5d52b6be
  - kind: registry
    name: utf8parse
    version: 0.2.2
    sha: 06abde3611657adf66d383f00b093d7faecc7fa57071cce2578660c9f1010821
  - kind: registry
    name: utmp-classic
    version: 0.1.6
    sha: e24c654e19afaa6b8f3877ece5d3bed849c2719c56f6752b18ca7da4fcc6e85a
  - kind: registry
    name: utmp-classic-raw
    version: 0.1.3
    sha: 22c226537a3d6e01c440c1926ca0256dbee2d19b2229ede6fc4863a6493dd831
  - kind: registry
    name: uuid
    version: 1.20.0
    sha: ee48d38b119b0cd71fe4141b30f5ba9c7c5d9f4e7a3a8b4a674e4b6ef789976f
  - kind: registry
    name: uutils_term_grid
    version: 0.7.0
    sha: fcba141ce511bad08e80b43f02976571072e1ff4286f7d628943efbd277c6361
  - kind: registry
    name: version_check
    version: 0.9.5
    sha: 0b928f33d975fc6ad9f86c8f283853ad26bdd5b10b7f1542aa2fa15e2289105a
  - kind: registry
    name: vsimd
    version: 0.8.0
    sha: 5c3082ca00d5a5ef149bb8b555a72ae84c9c59f7250f013ac822ac2e49b19c64
  - kind: registry
    name: walkdir
    version: 2.5.0
    sha: 29790946404f91d9c5d06f9874efddea1dc06c5efe94541a7d6863108e3a5e4b
  - kind: registry
    name: wasi
    version: 0.11.1+wasi-snapshot-preview1
    sha: ccf3ec651a847eb01de73ccad15eb7d99f80485de043efb2f370cd654f4ea44b
  - kind: registry
    name: wasip2
    version: 1.0.2+wasi-0.2.9
    sha: 9517f9239f02c069db75e65f174b3da828fe5f5b945c4dd26bd25d89c03ebcf5
  - kind: registry
    name: wasm-bindgen
    version: 0.2.108
    sha: 64024a30ec1e37399cf85a7ffefebdb72205ca1c972291c51512360d90bd8566
  - kind: registry
    name: wasm-bindgen-macro
    version: 0.2.108
    sha: 008b239d9c740232e71bd39e8ef6429d27097518b6b30bdf9086833bd5b6d608
  - kind: registry
    name: wasm-bindgen-macro-support
    version: 0.2.108
    sha: 5256bae2d58f54820e6490f9839c49780dff84c65aeab9e772f15d5f0e913a55
  - kind: registry
    name: wasm-bindgen-shared
    version: 0.2.108
    sha: 1f01b580c9ac74c8d8f0c0e4afb04eeef2acf145458e52c03845ee9cd23e3d12
  - kind: registry
    name: web-time
    version: 1.1.0
    sha: 5a6580f308b1fad9207618087a65c04e7a10bc77e02c8e84e9b00dd4b12fa0bb
  - kind: registry
    name: wild
    version: 2.2.1
    sha: a3131afc8c575281e1e80f36ed6a092aa502c08b18ed7524e86fbbb12bb410e1
  - kind: registry
    name: winapi
    version: 0.3.9
    sha: 5c839a674fcd7a98952e593242ea400abe93992746761e38641405d28b00f419
  - kind: registry
    name: winapi-i686-pc-windows-gnu
    version: 0.4.0
    sha: ac3b87c63620426dd9b991e5ce0329eff545bccbbb34f3be09ff6fb6ab51b7b6
  - kind: registry
    name: winapi-util
    version: 0.1.11
    sha: c2a7b1c03c876122aa43f3020e6c3c3ee5c05081c9a00739faf7503aeba10d22
  - kind: registry
    name: winapi-x86_64-pc-windows-gnu
    version: 0.4.0
    sha: 712e227841d057c1ee1cd2fb22fa7e5a5461ae8e48fa2ca79ec42cfc1931183f
  - kind: registry
    name: windows-core
    version: 0.62.2
    sha: b8e83a14d34d0623b51dce9581199302a221863196a1dde71a7663a4c2be9deb
  - kind: registry
    name: windows-implement
    version: 0.60.2
    sha: 053e2e040ab57b9dc951b72c264860db7eb3b0200ba345b4e4c3b14f67855ddf
  - kind: registry
    name: windows-interface
    version: 0.59.3
    sha: 3f316c4a2570ba26bbec722032c4099d8c8bc095efccdc15688708623367e358
  - kind: registry
    name: windows-link
    version: 0.2.1
    sha: f0805222e57f7521d6a62e36fa9163bc891acd422f971defe97d64e70d0a4fe5
  - kind: registry
    name: windows-result
    version: 0.4.1
    sha: 7781fa89eaf60850ac3d2da7af8e5242a5ea78d1a11c49bf2910bb5a73853eb5
  - kind: registry
    name: windows-strings
    version: 0.5.1
    sha: 7837d08f69c77cf6b07689544538e017c1bfcf57e34b4c0ff58e6c2cd3b37091
  - kind: registry
    name: windows-sys
    version: 0.59.0
    sha: 1e38bc4d79ed67fd075bcc251a1c39b32a1776bbe92e5bef1f0bf1f8c531853b
  - kind: registry
    name: windows-sys
    version: 0.60.2
    sha: f2f500e4d28234f72040990ec9d39e3a6b950f9f22d3dba18416c35882612bcb
  - kind: registry
    name: windows-sys
    version: 0.61.2
    sha: ae137229bcbd6cdf0f7b80a31df61766145077ddf49416a728b02cb3921ff3fc
  - kind: registry
    name: windows-targets
    version: 0.52.6
    sha: 9b724f72796e036ab90c1021d4780d4d3d648aca59e491e6b98e725b84e99973
  - kind: registry
    name: windows-targets
    version: 0.53.5
    sha: 4945f9f551b88e0d65f3db0bc25c33b8acea4d9e41163edf90dcd0b19f9069f3
  - kind: registry
    name: windows_aarch64_gnullvm
    version: 0.52.6
    sha: 32a4622180e7a0ec044bb555404c800bc9fd9ec262ec147edd5989ccd0c02cd3
  - kind: registry
    name: windows_aarch64_gnullvm
    version: 0.53.1
    sha: a9d8416fa8b42f5c947f8482c43e7d89e73a173cead56d044f6a56104a6d1b53
  - kind: registry
    name: windows_aarch64_msvc
    version: 0.52.6
    sha: 09ec2a7bb152e2252b53fa7803150007879548bc709c039df7627cabbd05d469
  - kind: registry
    name: windows_aarch64_msvc
    version: 0.53.1
    sha: b9d782e804c2f632e395708e99a94275910eb9100b2114651e04744e9b125006
  - kind: registry
    name: windows_i686_gnu
    version: 0.52.6
    sha: 8e9b5ad5ab802e97eb8e295ac6720e509ee4c243f69d781394014ebfe8bbfa0b
  - kind: registry
    name: windows_i686_gnu
    version: 0.53.1
    sha: 960e6da069d81e09becb0ca57a65220ddff016ff2d6af6a223cf372a506593a3
  - kind: registry
    name: windows_i686_gnullvm
    version: 0.52.6
    sha: 0eee52d38c090b3caa76c563b86c3a4bd71ef1a819287c19d586d7334ae8ed66
  - kind: registry
    name: windows_i686_gnullvm
    version: 0.53.1
    sha: fa7359d10048f68ab8b09fa71c3daccfb0e9b559aed648a8f95469c27057180c
  - kind: registry
    name: windows_i686_msvc
    version: 0.52.6
    sha: 240948bc05c5e7c6dabba28bf89d89ffce3e303022809e73deaefe4f6ec56c66
  - kind: registry
    name: windows_i686_msvc
    version: 0.53.1
    sha: 1e7ac75179f18232fe9c285163565a57ef8d3c89254a30685b57d83a38d326c2
  - kind: registry
    name: windows_x86_64_gnu
    version: 0.52.6
    sha: 147a5c80aabfbf0c7d901cb5895d1de30ef2907eb21fbbab29ca94c5b08b1a78
  - kind: registry
    name: windows_x86_64_gnu
    version: 0.53.1
    sha: 9c3842cdd74a865a8066ab39c8a7a473c0778a3f29370b5fd6b4b9aa7df4a499
  - kind: registry
    name: windows_x86_64_gnullvm
    version: 0.52.6
    sha: 24d5b23dc417412679681396f2b49f3de8c1473deb516bd34410872eff51ed0d
  - kind: registry
    name: windows_x86_64_gnullvm
    version: 0.53.1
    sha: 0ffa179e2d07eee8ad8f57493436566c7cc30ac536a3379fdf008f47f6bb7ae1
  - kind: registry
    name: windows_x86_64_msvc
    version: 0.52.6
    sha: 589f6da84c646204747d1270a2a5661ea66ed1cced2631d546fdfb155959f9ec
  - kind: registry
    name: windows_x86_64_msvc
    version: 0.53.1
    sha: d6bbff5f0aada427a1e5a6da5f1f98158182f26556f345ac9e04d36d0ebed650
  - kind: registry
    name: winnow
    version: 0.7.14
    sha: 5a5364e9d77fcdeeaa6062ced926ee3381faa2ee02d3eb83a5c27a8825540829
  - kind: registry
    name: wit-bindgen
    version: 0.51.0
    sha: d7249219f66ced02969388cf2bb044a09756a083d0fab1e566056b04d9fbcaa5
  - kind: registry
    name: write16
    version: 1.0.0
    sha: d1890f4022759daae28ed4fe62859b1236caebfc61ede2f63ed4e695f3f6d936
  - kind: registry
    name: writeable
    version: 0.6.2
    sha: 9edde0db4769d2dc68579893f2306b26c6ecfbe0ef499b013d731b7b9247e0b9
  - kind: registry
    name: wyz
    version: 0.5.1
    sha: 05f360fc0b24296329c78fda852a1e9ae82de9cf7b27dae4b7f62f118f77b9ed
  - kind: registry
    name: xattr
    version: 1.6.1
    sha: 32e45ad4206f6d2479085147f02bc2ef834ac85886624a23575ae137c8aa8156
  - kind: registry
    name: yansi
    version: 1.0.1
    sha: cfe53a6657fd280eaa890a3bc59152892ffa3e30101319d168b781ed6529b049
  - kind: registry
    name: yoke
    version: 0.8.1
    sha: 72d6e5c6afb84d73944e5cedb052c4680d5657337201555f9f2a16b7406d4954
  - kind: registry
    name: yoke-derive
    version: 0.8.1
    sha: b659052874eb698efe5b9e8cf382204678a0086ebf46982b79d6ca3182927e5d
  - kind: registry
    name: z85
    version: 3.0.7
    sha: c6e61e59a957b7ccee15d2049f86e8bfd6f66968fcd88f018950662d9b86e675
  - kind: registry
    name: zerocopy
    version: 0.7.35
    sha: 1b9b4fd18abc82b8136838da5d50bae7bdea537c574d8dc1a34ed098d6c166f0
  - kind: registry
    name: zerocopy
    version: 0.8.39
    sha: db6d35d663eadb6c932438e763b262fe1a70987f9ae936e60158176d710cae4a
  - kind: registry
    name: zerocopy-derive
    version: 0.7.35
    sha: fa4f8080344d4671fb4e831a13ad1e68092748387dfc4f55e356242fae12ce3e
  - kind: registry
    name: zerocopy-derive
    version: 0.8.39
    sha: 4122cd3169e94605190e77839c9a40d40ed048d305bfdc146e7df40ab0f3e517
  - kind: registry
    name: zerofrom
    version: 0.1.6
    sha: 50cc42e0333e05660c3587f3bf9d0478688e15d870fab3346451ce7f8c9fbea5
  - kind: registry
    name: zerofrom-derive
    version: 0.1.6
    sha: d71e5d6e06ab090c67b5e44993ec16b72dcbaabc526db883a360057678b48502
  - kind: registry
    name: zerotrie
    version: 0.2.3
    sha: 2a59c17a5562d507e4b54960e8569ebee33bee890c70aa3fe7b97e85a9fd7851
  - kind: registry
    name: zerovec
    version: 0.11.5
    sha: 6c28719294829477f525be0186d13efa9a3c602f7ec202ca9e353d310fb9a002
  - kind: registry
    name: zerovec-derive
    version: 0.11.2
    sha: eadce39539ca5cb3985590102671f2567e659fca9666581ad3411d59207951f3
  - kind: registry
    name: zip
    version: 7.4.0
    sha: cc12baa6db2b15a140161ce53d72209dacea594230798c24774139b54ecaa980
  - kind: registry
    name: zlib-rs
    version: 0.6.0
    sha: a7948af682ccbc3342b6e9420e8c51c1fe5d7bf7756002b4a3c6cabfe96a7e3c
  - kind: registry
    name: zmij
    version: 1.0.19
    sha: 3ff05f8caa9038894637571ae6b9e29466c1f4f829d26c9b28f869a29cbe3445
  - kind: registry
    name: zopfli
    version: 0.8.3
    sha: f05cd8797d63865425ff89b5c4a48804f35ba0ce8d125800027ad6017d2b5249
