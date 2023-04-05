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
- transmitt.conf
    - transmit
- uart.conf
    - uart

## Format

### build.json
```json
lunch:
	kernel: ...
	vendor: ...
	system: ...
lsp:
    dir:
        kernel: ...
        lk: ...
        preloader: ...
runtime:
	pid1:
		lunch:
			kernel: ...
			vendor: ...
			system: ...
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
