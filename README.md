# Introduction

A light weight dotfile for Linux BASH shell environment.

Though there are many fancy CLI tools on the internet, not all
of them are suitable for large projects due to performance issues.
I've filtered out some tools and keep the rest putting together
working efficiently.

To make the environment more simple, easy and efficient, I would
follow the KISS principle as possible as I can.

# Minimal Requirements
- `bash` >= 4.x

# Package Install / Uninstall

All packages under this dotfile repository now provide both install and uninstall entries.

- Install one or more packages:
  - `make install <pkg1> <pkg2> ...`
- Uninstall one or more packages:
  - `make uninstall <pkg1> <pkg2> ...`

Examples:

- `make install git nvim tmux`
- `make uninstall git nvim tmux`

`make uninstall` will invoke each package's own `uninstall` logic before deleting the copied config directory.

# Integration

## Terminal/ Shell
- bash
- tmux
- enhanced
- kitty
- fasd

## VCS/ Patch
- git
- tig
- quilt

## Editor
- nvim

## System
- top
- htop

# Directory Stucture
- `misc`
    - for those dotfiles with only one configuration
- `profile`
    - a set of profile for specific environment or usage
- `test`
    - test file
- (still working)
