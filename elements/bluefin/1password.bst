kind: stack

(?):
- arch == "x86_64":
    depends:
      - bluefin/1password-x86_64.bst
- arch == "aarch64":
    depends:
      - bluefin/1password-aarch64.bst
