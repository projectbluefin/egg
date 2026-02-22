kind: stack

(?):
- arch == "x86_64":
    depends:
      - bluefin/gum-x86_64.bst
- arch == "aarch64":
    depends:
      - bluefin/gum-aarch64.bst
