
" Sessions management
  if isdirectory($HOME . '/.config/nvim/sessions') == 0
    :silent !mkdir -p ~/.config/nvim/sessions >/dev/null 2>&1
  endif
  let g:sessions_dir = '~/.config/nvim/sessions'
  exec 'nnoremap <Leader>ss :Obsession ' . g:sessions_dir . '/*.vim<C-D><BS><BS><BS><BS><BS>'
  exec 'nnoremap <Leader>sr :so ' . g:sessions_dir. '/*.vim<C-D><BS><BS><BS><BS><BS>'
