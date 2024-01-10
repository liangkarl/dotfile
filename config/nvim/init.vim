" Remember cursor position
fun! s:RestoreCursorPosition()
  " if last visited position is available
  if line("'\"") > 1 && line("'\"") <= line("$")
    " jump to the last position
    exe "normal! g'\""
  endif
endfun

fun! s:toggleEditMode(enable)
  " list: show 'listchars'
  " showbreak: set wrap line symbol
  " colorcolumn: set color column
  " FIXME: move trailing spaces function to somewhere else
  if a:enable
    set list showbreak=↪\  colorcolumn=80
    lua MiniTrailspace.highlight()
    lua vim.diagnostic.config({ virtual_text = false, virtual_lines = false, signs = false})
  else
    set nolist showbreak= colorcolumn=
    lua MiniTrailspace.unhighlight()
    lua vim.diagnostic.config({ virtual_text = true, virtual_lines = true, signs = true})
  endif
endfun

let g:nvim_dir = expand('<sfile>:h/nvim')
let g:lua_dir = g:nvim_dir . '/lua'
let g:config_dir = g:nvim_dir . '/config'
let g:theme_dir = g:config_dir . '/theme'
let g:finder_dir = g:config_dir . '/finder'

source <sfile>:h/config.vim

" import common setup
exe 'source' g:nvim_dir . '/keybind.vim'
exe 'luafile' g:nvim_dir . '/options.lua'
exe 'luafile' g:nvim_dir . '/entry.lua'
" TODO: step into init.lua
" exe 'luafile' g:nvim_dir . '/profile.lua'

" Misc settings:
" Filetype detection is enabled by default. This can be disabled by adding
"   ":filetype off" to |init.vim|.
" Syntax highlighting is enabled by default. This can be disabled by adding
"   ":syntax off" to |init.vim|.
" |man.lua| plugin is enabled, so |:Man| is available by default.
" |matchit| plugin is enabled. To disable it in your config: >
"   :let loaded_matchit = 1
let loaded_matchit = 1

" |g:vimsyn_embed| defaults to "l" to enable Lua highlighting

" allow plugins by file type
filetype plugin indent on

highlight nCursor gui=NONE cterm=NONE ctermbg=1 guibg=SlateBlue
highlight iCursor gui=NONE cterm=NONE ctermbg=15 guibg=#ffffff
highlight rCursor gui=NONE cterm=NONE ctermbg=12 guibg=Red

" Keep cursor line centered only in Normal mode
autocmd! CursorMoved * set scrolloff=999
autocmd! InsertEnter * set scrolloff=5

autocmd! InsertLeave * call s:toggleEditMode(0)
autocmd! InsertEnter * call s:toggleEditMode(1)

" no one is really happy until you have this shortcuts
cab W! w!
cab Q! q!
cab Wa wa
cab Wq wq
cab wQ wq
cab WQ wq
cab W w
cab Q q

" A simple function to restore previous cursor position
autocmd! BufReadPost * call s:RestoreCursorPosition()
" set no line number in terminal buffer
autocmd! TermOpen * setlocal nonumber norelativenumber
" FIXME: WA for autocmd not working
autocmd! FileReadPost,BufReadPost * :GuessIndent
