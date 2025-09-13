# Description

This is a script to automatically enable/disable the virtual keyboard when your laptop enters "tablet mode".
This will only work on KDE due to the DBus objects it uses.
Tested on the Framework Laptop 12, but might work on other convertibles.

# Install

Install the script for everybody:
```
sudo install -o0 -g0 -m755 vkbd_toggle.pl /usr/local/bin/vkbd_toggle.pl
```

Install the unit file for your user:
```
install -D -m644 vkbd_toggle.service ~/.config/systemd/user/vkbd_toggle.service
```

Enable the service for your user:
```
systemctl --user enable --now vkbd_toggle.service
```

Check for problems:
```
journalctl --user -u vkbd_toggle.service -f
```
