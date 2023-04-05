# Configuration for NeoVim

## Plugin

There were some good plugins dropped out the installed list as they
could not handle large project, file or syntax well, or some of them
were with complicated configuration that drive me crazy.

In my perspective, even their ideas were really good for me, I have
no choice but to remove them.

### Dropped List With Reason

- Start Screen
    - nvim-dashboard:
        - Screen layout looked strange.
        - Lots of unused functions.
- Statusline/ Bufferline:
    - vim-airline: 
        - Poor performance
    - lightline:
        - Performance was much better than vim-airline, but it used VimL
- File Explorer:
    - NerdTree:
        - good plugin, but use VimL
- Operation Hint
    - vim-which-key:
        - compared to 'which-key.nvim', this plugin is with
          much complicated setup
- Autocompletion (without LSP source)
    - coc:
        - easy and powerful, but much complicated to customization
- Terminal
    - vim-floaterm:
        - fashion, but too much useless features make configure it harder
- Lint
    - ALE:
        - slow performance
- Symbol Manager
    - symbols-outline:
        - only support LSP
    - Vista:
        - LSP function is problematic that make it need Ctags support
- Cursor Movement
    - vim_current_word:
        - hard to setup blacklist and highlight style
- Git
    - vim-gitgutter:
        - poor performance in large project
- Cursor
    - vim-multiple-cursors
        - multiple cursor editing is fasion, but I seldom need this feature.
- Editor
    - neomake
        - pre-load in NeoVim
