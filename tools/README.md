# README

## Configuration Reference

- build.json
    - mtk.make
    - patch.repo
    - helper.aosp
- space.json
    - tmux.space
- win.json
    - tmux.wm
- transmit.conf
    - transmit
- uart.conf
    - uart

## Format

### build.json
```json
default:
    kernel:
        lunch: ...
        dir: ...
    vendor:
        ...
    system:
        ...
runtime:
    pid1:
        kernel:
            lunch: ...
            dir: ...
            out: ...
        vendor:
            ...
        system:
            ...
        update: time
    pid2:
        ...
gerrit:
    username:
    url:
    port:
    filter:
```

### space.json
```json
list:
    [0]:
        name: ...
        dir: ...
    [1]:
        name: ...
        dir: ...
```

### win.json
```json
list:
    [0]:
        name: ...
        dir: ...
        cmd: ...
    [1]:
        name: ...
        dir: ...
        cmd: ...
```

### transmit.json
```json
remote:
    host: ...
    dir:
        [0]: /a/b/c
        [1]: c/b/a
local:
    dir: 'images@$(date +%Y%m%d-%H%M%S)'
    file:
        [0]: 'a/'
        [1]: 'b.img'
        [2]: 'c.bin'
setup:
    bin: 'rsync'
```
