
" Explicitily set $VIMHOME
  let $VIMHOME=expand('~/.config/nvim')

" Add $VIMHOME/after to runtimepath
" :h 'runtimepath'
  let &runtimepath .= ','.$VIMHOME.','.$VIMHOME.'/after'.','.$VIMHOME.'/doc'

" MODULAR NVIM CONFIGURATION

" Contains general nvim settings
  source $VIMHOME/config/base.vim

" Constains nvim mapping settings
  source $VIMHOME/config/mappings.vim

" Contains vim-plug settings
  source $VIMHOME/config/plugins/plugins.vim

" Contains colorscheme settings
  source $VIMHOME/config/colors.vim

" Contains vim autocommand settings
  source $VIMHOME/config/commands.vim
