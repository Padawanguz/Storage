
" VIM-PLUG CONFIGURATION
" Vim-Plug Autoinstall Code
  let plug_install = 0
  let autoload_plug_path = stdpath('config') . '/autoload/plug.vim'
  if !filereadable(autoload_plug_path)
      silent exe '!curl -fL --create-dirs -o ' . autoload_plug_path .
          \ ' https://raw.github.com/junegunn/vim-plug/master/plug.vim'
      execute 'source ' . fnameescape(autoload_plug_path)
      let plug_install = 1
  endif
  unlet autoload_plug_path

  call plug#begin('~/.config/nvim/plugins')

  " Plug 'ervandew/supertab'
  Plug 'dense-analysis/ale'
  Plug 'filipekiss/cursed.vim'
  Plug 'tomtom/tcomment_vim'
  Plug 'honza/vim-snippets'
  Plug 'sirver/UltiSnips'
  Plug 'metalelf0/supertab'
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'tpope/vim-obsession'
  Plug 'mhinz/vim-startify'
  Plug 'zhimsel/vim-stay'
  Plug 'itchyny/lightline.vim'
  Plug 'mengelbrecht/lightline-bufferline'
  Plug 'preservim/nerdtree'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rails'
  Plug 'vim-ruby/vim-ruby'
  Plug 'chuling/equinusocio-material.vim'
  Plug 'ryanoasis/vim-devicons'
  Plug 'tpope/vim-surround'
  Plug 'psliwka/vim-smoothie'
  Plug 'lervag/vimtex'
  Plug 'airblade/vim-rooter'

  call plug#end()

  if plug_install
      PlugInstall --sync
  endif
  unlet plug_install

" CONFIGURATIONS FOR EACH PLUGIN
" example:
" " source $VIMHOME/plugins/config/plugin.vim

source $VIMHOME/config/plugins/config/ale.vim
source $VIMHOME/config/plugins/config/youcompleteme.vim
source $VIMHOME/config/plugins/config/cursorline.vim
source $VIMHOME/config/plugins/config/SiB.vim
source $VIMHOME/config/plugins/config/fzf.vim
source $VIMHOME/config/plugins/config/startify.vim
source $VIMHOME/config/plugins/config/obsession.vim
source $VIMHOME/config/plugins/config/lightline.vim
source $VIMHOME/config/plugins/config/nerdtree.vim
source $VIMHOME/config/plugins/config/vimtex.vim
source $VIMHOME/config/plugins/config/vim-rooter.vim

" REMENBER to use :PlugInstall or :PlugClean once you ADD or REMOVE a pluggin from the list
