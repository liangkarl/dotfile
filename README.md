# My Ubuntu Shell Config #

## Introduce ##

  Since I hate re-type every command while installing a new Ubuntu system from zero,
I tried to write some simple script before, but they are hard to mantain or modify
after system update or something else happended. I want to try another way to break
such goddamn infinite loop.

## Goal ##

1. Simple scripts to mantain/modify
2. Less manual operation while installing
3. Make integrated key-binding while using many programming tools
4. Main key-bindings are vi-like

## Include ##

tmux
git
bash
(still adding)

## Platform ##

Ubuntu 18.04

## Usage ##

### Install All ###

Execute `install.sh`

### Partial Install ###

1. Set environment

```
source core/env.sh`
init_env
```

2. Choose which application you want to install. For example

```
source lib/git.sh
install
```

## Notice ##

Still on progress, many works needed to do.
