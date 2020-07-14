
" Vimtex supports Neovim. However, since Neovim doesn't support the --servername option yet, you have to install neovim-remote and use
" "
" " pip3 install neovim-remote
  let g:vimtex_compiler_progname = 'nvr'

" Make Vimtex work with YouCompleteMe autocompletion
  if !exists('g:ycm_semantic_triggers')
      let g:ycm_semantic_triggers = {}
    endif
    au VimEnter * let g:ycm_semantic_triggers.tex=g:vimtex#re#youcompleteme

  let g:latex_view_general_viewer = "zathura"
  let g:vimtex_view_method = "zathura"
  let g:tex_conceal = ''
  let g:tex_flavor = "latex"

  let g:vimtex_compiler_latexmk = {
              \ 'build_dir' : 'BUILD',
              \}
