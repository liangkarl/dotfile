# README

## input-watch

It would capture every keyboard or mouse event for the last 30 minutes.

### Install

```sh
sudo cp input-watch /usr/local/sbin/input-watch
sudo cp input-watch.service /etc/systemd/system/input-watch.service
sudo systemctl daemon-reload

# Start Service Now
# systemctl status input-watch.service

# Check Service Status
# sudo systemctl enable --now input-watch.service
```

### Start / Enable
```sh
sudo systemctl enable --now input-watch.service
sudo systemctl restart input-watch.service
```

### Stop / Disable
```sh
sudo systemctl disable input-watch.service
sudo systemctl stop input-watch.service
```
