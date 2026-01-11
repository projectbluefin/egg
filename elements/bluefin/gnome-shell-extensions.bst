kind: manual

depends:
# FIXME: Remove compiled schemas leftovers
# FIXME: cleanup custom make destdirs set when not needed
- bluefin/shell-extensions/app-indicators.bst
# FIXME: does not install in /usr
- bluefin/shell-extensions/blur-my-shell.bst
- bluefin/shell-extensions/dash-to-dock.bst
- bluefin/shell-extensions/gsconnect.bst
# - bluefin/shell-extensions/logomenu.bst
# FIXME: installs in .local
- bluefin/shell-extensions/search-light.bst
# Since we use gnomeos nightly atm, no extension works
# with the current shell version
- bluefin/shell-extensions/disable-ext-validator.bst

variables:
  strip-binaries: ''

config:
  install-commands:
    - mkdir -p %{install-root}/usr/share/gnome-shell/modes
    - |
      cat <<EOF > %{install-root}/usr/share/gnome-shell/modes/bluefin.json
      {
          "parentMode": "user",
          "enabledExtensions": [
            "appindicatorsupport@rgcjonas.gmail.com",
            "blur-my-shell@aunetx",
            "dash-to-dock@micxgx.gmail.com",
            "gsconnect@andyholmes.github.io",
            "logomenu@aryan_k",
            "search-light@icedman.github.com",
          ]
      }
      EOF
