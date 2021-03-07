# My Ubuntu Shell Config

## Introduce

  Since I hate re-typing every command while installing a new Ubuntu system
from zero, I tried to write some simple scripts before, but they are difficult
to maintain or modify after system update or other kind of circumstances. I
want to try another way to break such goddamn infinite loop.

## Goal

1. Simple scripts to mantain/modify
2. Less manual operation while installing
3. Make integrated key-binding while using many programming tools
4. Main key-bindings are vi-like

## Include

tmux (with tpm)
git / tig
bash
nvim (with coc)
gcc
python
ccls
clang / llvm
some small tools
(still adding)

## OS & Shell

Ubuntu 16.04 / bash
Ubuntu 18.04 / bash

## Usage

### Install All

Execute `install.sh`

### Manually Install

1. Set environment

```bash=
. manual.sh
```

2. Choose the application you want. For example

```bash=
# old ways
. lib/git.sh
install

# new ways
# type 'worker' to print help
worker n git i # install git
```

## Notice

Still develop in progress, many bugs, many works there.
