# Configuration for NeoVim

## Plugin

There were some good plugins dropped out the installed list as they
could not handle large project, file or syntax well, or some of them
were with complicated configuration that drive me crazy.

In my perspective, even their ideas were really good for me, I have
no choice but to remove them.

### Fuzzy Finder

I list three fuzzy finders, `fzf`, `skim` and `telescope`.

In terms of overall features and performance, `fzf` is the strongest of
the three. However, I have encountered issues when running `fzf` on Linux
kernel 4.x, which is why I need to identify other fuzzy finders as backup
solutions.

`skim` is a `rust`-based version of `fzf`. While it has replicated most
of `fzf`'s features and arguments, it takes longer to search than `fzf`
does. That said, some users have reported that the difference is only
noticeable in extreme cases, such as when dealing with a huge number of
files. Additionally, `skim` can work with `enhancd`, a small CLI tool that
enhances the `cd` command, which is included in this dotfile. Overall,
`skim` is almost as good as `fzf`, which is why I've chosen it as a backup
solution.

`telescope`, which is written in `lua`, has the least impressive performance
of the three due to the lack of a binary backend for searching. Furthermore,
it is limited to `nvim` and cannot be used in shells like `bash`. Despite
these limitations, I believe that `telescope` has the potential to be a 
great fuzzy finder in the future. Therefore, if the previous commands fail,
I'll use `telescope` as a last resort.

### Dropped List With Reason

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
