" Plugin: tig-explorer.vim
" https://github.com/iberianpig/tig-explorer.vim

" As the offical guide said, tig-explorer depends on the plugin, bclose,
" which is an really old plugin.
command! -bang -nargs=1 -complete=buffer Bclose bdelete! <f-args>
