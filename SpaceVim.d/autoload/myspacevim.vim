function! myspacevim#before() abort
    set cc = 80
    let g:clang_format#command = 'clang-format'
    autocmd FileType c,cpp,cc,h setlocal equalprg=clang-format
    autocmd FileType c,cpp,cc,h ClangFormatAutoEnable
    let g:clang_format#detect_style_file = 1
endfunction

function! myspacevim#after() abort
    "" Add your codes here
    set tabstop&
    set softtabstop&
    set shiftwidth&
endfunction
