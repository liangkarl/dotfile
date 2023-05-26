" Plugin: Startify
" Show startify when there is no opened buffers
fun! s:ShowStartify()
  if empty(filter(tabpagebuflist(), '!buflisted(v:val)')) && bufname() == ""
    Startify
  endif
endfun

autocmd! BufDelete * call s:ShowStartify()
