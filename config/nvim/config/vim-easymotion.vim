" Plugin: vim-easymotion
" https://github.com/easymotion/vim-easymotion

" recommoand mininal setup

let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
" nmap <leader>s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.

" meaning of symbols
" f2 => hit two chars
" f => hit one char
" w => move to the begin of word
" l => move to the begin of line
" sol => start of line
" eol => end of line
nmap <leader>jj <Plug>(easymotion-overwin-f2)
