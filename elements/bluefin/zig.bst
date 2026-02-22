kind: stack

(?):
- arch == "x86_64":
    depends:
      - bluefin/zig-x86_64.bst
- arch == "aarch64":
    depends:
      - bluefin/zig-aarch64.bst
