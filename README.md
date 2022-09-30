# Alarm ![Logo](com.github.bytezz.alarm.png)
Alarm app designed for Linux phones.  
Tested with PINE64 PinePhone running Phosh.

[Screenshots Gallery](./screenshots/README.md)

## Features
- system wakes up from power saving mode (suspend) to play the alarm
- single alarm schedule
- alarm is repeated for selected days of the week
- snooze button
- pleasant wake up sound (included)
- gradual volume increase of the alarm
- alarm test mode
- alarm accessible from a lockscreen (via MPRIS)
- landscape and portrait mode layouts

## Todo
- New icon to follow GNOME HIG
- New UI to follow GNOME HIG
- New screenshots

## Install

### Install from source:

```
# get the source
git clone https://github.com/bytezz/alarm.git
cd alarm

# on Mobian/Debian:
sudo apt install gcc make checkinstall python3-psutil python3-pip
pip3 install -r requirements.txt
sudo make install-deb

# on Arch:
sudo pacman -S gst-plugins-base gst-plugins-good python-pip
pip3 install -r requirements.txt
sudo make install

# or generic:
pip3 install -r requirements.txt
sudo make install
```

## Uninstall:

```
# on Mobian/Debian:
sudo dpkg -r alarm

# or generic:
make uninstall
```

## Notes
Forked from [Birdie](https://github.com/Dejvino/birdie) which is forked from [Wake Mobile](https://gitlab.gnome.org/kailueke/wake-mobile), a proof-of-concept alarm app that uses systemd timers to wake up the system.

Current icon is temporary and was kindly "stolen" from Furtherance.