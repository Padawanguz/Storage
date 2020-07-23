
" FZF CONFIGURATION AND BINDINGS
  let g:fzf_action = {
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit'
        \ }
  " let $FZF_DEFAULT_COMMAND = "find -L"
  let g:fzf_preview_window = 'right:60%'
  nnoremap <c-p> :Files<cr>
  nnoremap <c-o> :Buffers<cr>
  augroup fzf
    autocmd!
    autocmd! FileType fzf
    autocmd  FileType fzf set laststatus=0 noshowmode noruler
      \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
  augroup END
