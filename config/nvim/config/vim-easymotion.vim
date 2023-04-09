" Plugin: vim-easymotion
" https://github.com/easymotion/vim-easymotion

" recommoand mininal setup

let g:EasyMotion_do_mapping = 0 " Disable default mappings

" Jump to anywhere you want with minimal keystrokes, with just one key binding.
" `s{char}{label}`
" nmap <leader>s <Plug>(easymotion-overwin-f)
" or
" `s{char}{char}{label}`
" Need one more keystroke, but on average, it may be more comfortable.
nmap <leader>ff <Plug>(easymotion-overwin-f2)

" Turn on case-insensitive feature
let g:EasyMotion_smartcase = 1

" JK motions: Line motions
map <leader>fj <Plug>(easymotion-j)
map <leader>fk <Plug>(easymotion-k)
