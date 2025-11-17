kind: manual

depends:
- bluefin/gnome-shell-ext-dash-to-dock.bst
- bluefin/gnome-shell-ext-just-perfection.bst

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
            "dash-to-dock@micxgx.gmail.com",
            "just-perfection-desktop@just-perfection",
          ]
      }
      EOF
