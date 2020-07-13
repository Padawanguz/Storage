" NERDtree toggle key
  nnoremap - :NERDTreeFind<CR>

" Disable Lightline in nerdtree window
  augroup filetype_nerdtree
      au!
      au FileType nerdtree call s:disable_lightline_on_nerdtree()
      au WinEnter,BufWinEnter,TabEnter * call s:disable_lightline_on_nerdtree()
  augroup END

  fu s:disable_lightline_on_nerdtree() abort
      let nerdtree_winnr = index(map(range(1, winnr('$')), {_,v -> getbufvar(winbufnr(v), '&ft')}), 'nerdtree') + 1
      call timer_start(0, {-> nerdtree_winnr && setwinvar(nerdtree_winnr, '&stl', '%#Normal#')})
  endfu
