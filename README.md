# My Ubuntu Shell Config

## Introduce

  Since I hate re-typing every command while installing a new Ubuntu system from
zero, I tried to write some simple script before, but they are difficult to maintain
or modify after system update or other kind of circumstances. I want to try another
way to break such goddamn infinite loop.

## Goal

1. Simple scripts to mantain/modify
2. Less manual operation while installing
3. Make integrated key-binding while using many programming tools
4. Main key-bindings are vi-like

## Include

tmux
git
bash
(still adding)

## Platform

Ubuntu 18.04

## Usage

### Install All

Execute `install.sh`

### Manual Install

1. Set environment

```bash=
. manual.sh
```

2. Choose the application you want. For example

```bash=
. lib/git.sh
install
```

## Notice

Still on progress, many bugs, many works needed to do.
