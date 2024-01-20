# Configuration for NeoVim

## Plugin

There were some good plugins dropped out the installed list as they
could not handle large project, file or syntax well, or some of them
were with complicated configuration that drive me crazy.

In my perspective, even their ideas were really good for me, I have
no choice but to remove them.

Besides, I don't think using all-in-`lua` is a good idea since the
performance didn't increase too much if you just setup some environment
variables, but there are many script syntax written in `viml` that would
be more readable and much shorter. I prefer to configure the plugins
in `lua` and setup keybinds and options for vim in `viml`.

## Config
```
- nvim
	- misc/
	- lua/
		- config/
			- fzf.lua
			- ...
		- theme/
	- finder/
		- fzf.vim
		- ...
	- init.vim
	- keybind.vim
```

## Neovim Default Configuration
```vim
" Nvim defaults:
" 'autoindent' is enabled
" 'autoread' is enabled
" 'background' defaults to "dark" (unless set automatically by the terminal/UI)
" 'backspace' defaults to "indent,eol,start"
" 'backupdir' defaults to .,~/.local/state/nvim/backup// (|xdg|), auto-created
" 'belloff' defaults to "all"
" 'compatible' is always disabled
" 'complete' excludes "i"
" 'cscopeverbose' is enabled
" 'directory' defaults to ~/.local/state/nvim/swap// (|xdg|), auto-created
" 'display' defaults to "lastline,msgsep"
" 'encoding' is UTF-8 (cf. 'fileencoding' for file-content encoding)
" 'fillchars' defaults (in effect) to "vert:│,fold:·,sep:│"
" 'formatoptions' defaults to "tcqj"
" 'fsync' is disabled
" 'hidden' is enabled
" 'history' defaults to 10000 (the maximum)
" 'hlsearch' is enabled
" 'incsearch' is enabled
" 'joinspaces' is disabled
" 'langnoremap' is enabled
" 'langremap' is disabled
" 'laststatus' defaults to 2 (statusline is always shown)
" 'listchars' defaults to "tab:> ,trail:-,nbsp:+"
" 'mouse' defaults to "nvi"
" 'mousemodel' defaults to "popup_setpos"
" 'nrformats' defaults to "bin,hex"
" 'ruler' is enabled
" 'sessionoptions' includes "unix,slash", excludes "options"
" 'shortmess' includes "F", excludes "S"
" 'showcmd' is enabled
" 'sidescroll' defaults to 1
" 'smarttab' is enabled
" 'startofline' is disabled
" 'switchbuf' defaults to "uselast"
" 'tabpagemax' defaults to 50
" 'tags' defaults to "./tags;,tags"
" 'ttimeoutlen' defaults to 50
" 'ttyfast' is always set
" 'undodir' defaults to ~/.local/state/nvim/undo// (|xdg|), auto-created
" 'viewoptions' includes "unix,slash", excludes "options"
" 'viminfo' includes "!"
" 'wildmenu' is enabled
" 'wildoptions' defaults to "pum,tagfile"
```

## TODO

1. Porting more `.vim` config to `.lua`
	- config/..
	- theme/..
2. Update `fzf.vim` to `lua-fzf`
3. Switch between `editorconfig` and `vim-clang-format` automatically
4. Survey `ccls` and `clangd`

### Fuzzy Finder

In terms of overall features and performance, `fzf` is the strongest of.
However, I have encountered issues when running `fzf` on Linux kernel 4.x,
which is why I need to identify other fuzzy finders as backup solutions.

`telescope`, which is written in `lua`, has the least impressive performance
due to the lack of a binary backend for searching. Furthermore, it is limited
to `nvim` and cannot be used in shells like `bash`. Despite these limitations,
I believe that `telescope` has the potential to be a great fuzzy finder in
the future. Therefore, if the previous commands fail, I'll use `telescope`
as a last resort.

### Available Plugin List

#### Appearance

##### Start Screen
```vim
Plug 'mhinz/vim-startify'
```

##### Statusline/ Bufferline:
```vim
Plug 'nvim-lualine/lualine.nvim'
Plug 'akinsho/bufferline.nvim'
```

##### Theme
```vim
Plug 'sainnhe/sonokai'
Plug 'marko-cerovac/material.nvim'
Plug 'sainnhe/gruvbox-material'
Plug 'navarasu/onedark.nvim'
```

#### Navigator

##### File Explorer
```vim
Plug 'kyazdani42/nvim-tree.lua'
```

##### Symbol Explorer
```vim
Plug 'stevearc/aerial.nvim'
Plug 'nvim-lua/lsp-status.nvim'
```

#### Infrastructure
```vim
Plug 'nvim-lua/plenary.nvim'
Plug 'neovim/nvim-lspconfig'    " LSP configuration
```

##### Debug Tools
```vim
"   vim-startuptime is a Vim plugin for viewing vim and nvim startup
" event timing information. The data is automatically obtained by
" launching (n)vim with the --startuptime argument. See
" :help startuptime-configuration for details on customization
" options.
" https://github.com/dstein64/vim-startuptime
Plug 'dstein64/vim-startuptime'
Plug 'mfussenegger/nvim-dap'
```

#### Enhancements
```vim
Plug 'roxma/vim-tmux-clipboard' " share clipboard between tmux and vim
Plug 'andymass/vim-matchup'     " enhance '%' function, like if-endif
Plug 'markonm/traces.vim'       " enhance replace/search result,
                                "  previewing the last result.
Plug 'haya14busa/is.vim'        " make string search more convenient.
Plug 'osyo-manga/vim-anzu'      " show matched string number and total
Plug 'Krasjet/auto.pairs'       " enhance [/{/'..., auto balance pairs
Plug 'terryma/vim-expand-region'    " enhance visual mode, +/- to increase
                                    " or decrease selected visual range
Plug 'easymotion/vim-easymotion'    " move cursor location like vimium
Plug 'tpope/vim-commentary'     " comment codes easily
Plug 'tyru/open-browser.vim'    " open url from vim
Plug 'rmagatti/alternate-toggler'   " switch boolean value easily,
Plug 'arithran/vim-delete-hidden-buffers'   " delete hidden buffers
Plug 'ntpeters/vim-better-whitespace'       " show/remove trailing space
Plug 'ahmedkhalf/project.nvim'  " provides superior project management
```

#### Operation

##### Cheatsheet
```vim
Plug 'folke/which-key.nvim'     " display shortcut-mapping functions
```

##### Autocompletion (without LSP source)

###### Core
```vim
Plug 'hrsh7th/nvim-cmp'         " primary autocomplete function
Plug 'saadparwaiz1/cmp_luasnip' " interface between nvim-cmp and LuaSnip
```

###### Source
```vim
Plug 'L3MON4D3/LuaSnip'         " snippet engine for neovim written in Lua
Plug 'tzachar/cmp-tabnine', { 'do': './install.sh' }    " AI assist for completion
Plug 'hrsh7th/cmp-buffer'       " snippet engine of buffer words
Plug 'hrsh7th/cmp-nvim-lsp'     " snippet engine of LSP client
```

###### Misc
```vim
Plug 'onsails/lspkind.nvim'     " adjust scroll menu width
```

##### Fuzzy Finder
```vim
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.1' }
```

#### Programming

##### Formatter
```vim
Plug 'rhysd/vim-clang-format'   " format source code by clang-format
Plug 'editorconfig/editorconfig-vim'    " coding style file
```

##### Language Support
```vim
Plug 'williamboman/mason.nvim'  " simplify the install of LSP
Plug 'm-pilia/vim-ccls'     " provide unique ccls function
Plug 'dhruvasagar/vim-table-mode'   " edit Markdown table easily
```

##### Syntax Highlight / Lint
```vim
Plug 'nvim-treesitter/nvim-treesitter'
```

##### Git
```vim
Plug 'mhinz/vim-signify'        " show diff symbols aside via git diff
Plug 'liangkarl/tig-explorer.vim'   " use tig inside vim
Plug 'rbgrouleff/bclose.vim'    " needed by tig-explorer in Nvim config
Plug 'TimUntersberger/neogit'   " git status
Plug 'sindrets/diffview.nvim'   " git diff
```

### Dropped Plugin List

#### Startup Screen

- nvim-dashboard:
	- Screen layout looks strange for me.
	- Lots of unused functions.

#### Statusline/ Bufferline:

- vim-airline: 
	- Poor performance
- lightline:
	- Performance was much better than vim-airline, but it used VimL

#### File Explorer:

- NerdTree:
	- good plugin, but use VimL

#### Operation Hint

- vim-which-key:
	- compared to 'which-key.nvim', this plugin is with much complicated setup

#### Autocompletion (without LSP source)

- coc:
	- easy and powerful, but `coc` do too many things.
	- [the comparison between `coc` and `lsp`](https://github.com/neovim/nvim-lspconfig/wiki/Comparison-to-other-LSP-ecosystems-(CoC,-vim-lsp,-etc.))

#### Terminal

- vim-floaterm:
	- fashion, but too much useless features make configure it harder

#### Lint

- ALE:
	- slow performance

#### Symbol Manager

- symbols-outline:
	- only support LSP
- Vista:
	- LSP function is buggy
	- too much legacy setup for `ctags`

#### Cursor Movement

- vim_current_word:
	- hard to setup blacklist and highlight style
- vim-multiple-cursors:
	- multiple cursor editing is fasion, but I seldom need this feature.

#### Git

- vim-gitgutter:
	- poor performance in large project

#### Misc

- neomake
	- already built in NeoVim

#### Fuzzy finder 

- vim-clap
	- similiar to `telescope`, but I always meet strange problem on it.
	- `vim-clap.vim` was out-of-date
- skim.vim
	- both the binary tool and vim plugin are problematic.
	- `skim.vim` was out-of-date
