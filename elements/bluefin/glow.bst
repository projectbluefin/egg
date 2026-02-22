kind: stack

(?):
- arch == "x86_64":
    depends:
      - bluefin/glow-x86_64.bst
- arch == "aarch64":
    depends:
      - bluefin/glow-aarch64.bst
