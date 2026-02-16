kind: stack

(?):
- arch == "x86_64":
    depends:
      - bluefin/1password-cli-x86_64.bst
- arch == "aarch64":
    depends:
      - bluefin/1password-cli-aarch64.bst
