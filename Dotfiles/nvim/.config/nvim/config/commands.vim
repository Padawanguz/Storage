
" ┌──────────────────────────────────────────────────┐
" │ Make these commonly mistyped commands still work │
" └──────────────────────────────────────────────────┘
  command! WQ wq
  command! Wq wq
  command! Wqa wqa
  command! W w
  command! Q q

" ┌───────────────────────────────────────┐
" │ Force write readonly files using sudo │
" └───────────────────────────────────────┘
  " cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!
  cnoremap SW execute 'SudaWrite'

" ┌──────────────────────────────────────────┐
" │ Disables automatic commenting on newline │
" └──────────────────────────────────────────┘
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" ┌─────────────────────────────────────────────────┐
" │ Save whenever switching windows or leaving vim. │
" └─────────────────────────────────────────────────┘
  autocmd FocusLost,WinLeave * :silent! wa

" ┌─────────────────────────────────────────────────┐
" │ Automatically rebalance windows on vim resize   │
" └─────────────────────────────────────────────────┘
  autocmd VimResized * :wincmd =

" ┌────────────────────────────────────────────────────────────┐
" │ Automatically deletes all trailing whitespace and newlines │
" └────────────────────────────────────────────────────────────┘
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufWritepre * %s/\n\+\%$//e

" ┌───────────────────────────────────────────────┐
" │ Automatically mantains dark bg for ALE Plugin │
" └───────────────────────────────────────────────┘
  autocmd VimEnter * :hi clear SignColumn
