" NERDtree toggle key
  " nnoremap - :NERDTreeFind<CR>

" Toggle nerdtree window and keep cursor in file window,
" adapted from https://stackoverflow.com/q/24808932/6064933
nnoremap <silent> - :NERDTreeToggle<CR>:wincmd p<CR>

" Reveal currently editted file in nerdtree widnow,
" see https://stackoverflow.com/q/7692233/6064933
nnoremap <silent> <C-f> :NERDTreeFind<CR>

" Ignore certain files and folders
let NERDTreeIgnore = ['\.pyc$', '^__pycache__$']

" Automatically show nerdtree window on entering nvim,
" see https://github.com/scrooloose/nerdtree. But now the cursor
" is in nerdtree window, so we need to change it to the file window,
" extracted from https://stackoverflow.com/q/24808932/6064933
" autocmd VimEnter * NERDTree | wincmd l

" Delete a file buffer when you have deleted it in nerdtree
let NERDTreeAutoDeleteBuffer = 1

" Show current root as realtive path from HOME in status bar,
" see https://github.com/scrooloose/nerdtree/issues/891
let NERDTreeStatusline="%{exists('b:NERDTree')?fnamemodify(b:NERDTree.root.path.str(), ':~'):''}"

" Disable bookmark and 'press ? for help' text
let NERDTreeMinimalUI=0

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
