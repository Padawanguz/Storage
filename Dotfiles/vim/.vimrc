 Type :so % to refresh .vimrc after making changes
	set nocompatible

" VIM-PLUG CONFIGURATION
" Vim-Plug Autoinstall Code
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

" Pluggins installed
  call plug#begin()

  Plug 'lambdalisue/suda'
  Plug 'preservim/nerdtree'
  Plug 'tpope/vim-surround'
  Plug 'tomtom/tcomment_vim'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'tpope/vim-obsession'
  Plug 'zhimsel/vim-stay'

  call plug#end()

" MAPPING AND NAVIGATION CONFIGURATIONS
" Easier split navigation
  nnoremap <C-J> <C-W><C-J>
  nnoremap <C-K> <C-W><C-K>
  nnoremap <C-L> <C-W><C-L>
  nnoremap <C-H> <C-W><C-H>

" move among buffers with CTRL
  nnoremap <C-]> :bnext<CR>
  nnoremap <C-[> :bprevious<CR>

" Copy the current word or visually selected text to the clipboard
  nnoremap <F4> "+yiw
  vnoremap <F4> "+y

" Prepare a :substitute command using the current word or the selected text
  nnoremap <F5> yiw:%s/\<<C-r>"\>/<C-r>"/gc<Left><Left><Left>
  vnoremap <F5> y:%s/\<<C-r>"\>/<C-r>"/gc<Left><Left><Left>

" Manual Folding
  inoremap <F9> <C-O>za
  nnoremap <F9> za
  nnoremap ! zD
  onoremap <F9> <C-C>za
  vnoremap <F9> zf

" Move text UP and DOWN
  nnoremap <C-d> :m .+1<CR>==
  nnoremap <C-u> :m .-2<CR>==
  inoremap <C-d> <Esc>:m .+1<CR>==gi
  inoremap <C-u> <Esc>:m .-2<CR>==gi
  vnoremap <C-d> :m '>+1<CR>gv=gv
  vnoremap <C-u> :m '<-2<CR>gv=gv

" Use enter and space w/o entering insert mode
  nmap <Enter> O<Esc>j
  nmap <CR> o<Esc>k
  " nnoremap <space> i<space><esc>

" Resize panes
  nnoremap <silent> <Left> :vertical resize +5<cr>
  nnoremap <silent> <Right> :vertical resize -5<cr>
  nnoremap <silent> <Down> :resize +5<cr>
  nnoremap <silent> <Up> :resize -5<cr>

" Stop highlight after searching set incsearch
  nnoremap <silent> <leader>, :noh<cr>

" Navigate properly when lines are wrapped
  nnoremap j gj
  nnoremap k gk

" NERDTreeToggle
  nnoremap - :NERDTreeFind<CR>

" VARIOUS VIM OPTIONS
  let mapleader = " "
  set ai                                " set autoindent
  set si                                " set smart indent
  set lbr                               " set linebreak
  set wrap                              " tells Vim to word wrap visually
	set backspace=2
	set history=1000
	set ruler
  set viminfo=!,h,f1,'100
	set showcmd
	set laststatus=2
	set autowrite
  set autoread
  set hidden                            " hide buffers instead of closing
  set lazyredraw                        " speed up on large files
  set mouse=                            " disable mouse
  set scrolloff=999                     " always keep cursor at the middle of screen
  set virtualedit=onemore               " allow the cursor to move just past the end of the line
  set undolevels=5000                   " set maximum undo levelsset autoread
  set foldmethod=manual                 " use manual folding
  set diffopt=filler,vertical           " default behavior for diff
  set tabstop=2
  set shiftwidth=2
  set shiftround
  set expandtab
  set softtabstop=2                      " remove <Tab> symbols as it was spaces
  set shiftround                         " round indent to multiple of 'shiftwidth' (for << and >>)
  set wildmode=longest,list,full
  set wildignore+=*.a,*.o,*.pyc,*~,*.swp,*.tmp
  set number relativenumber
  set numberwidth=5
  set splitbelow splitright              " Open new split panes to right and bottom
  set incsearch
	set gdefault
	set ignorecase
	set smartcase
	set showmatch
  set scrolloff=8
  set sidescrolloff=15
  set sidescroll=1
	set shell=/usr/bin/fish
	set clipboard=unnamedplus                   " Allow Copy and Paste - Must instal gvim
  set viewoptions=cursor,folds,slash,unix     " Vim-Stay configuration
  let g:plug_window = 'noautocmd vertical topleft new'

" VIM OPTIONS EXTENDED
" Disables automatic commenting on newline:
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Save file as sudo on files that require root permission
  cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" HTML Editing
  set matchpairs+=<:>

" Treat <li> and <p> tags like the block tags they are
  let g:html_indent_tags = 'li\|p'

" Save whenever switching windows or leaving vim. This is useful when running
" the tests inside vim without having to save all files first.
  au FocusLost,WinLeave * :silent! wa

" Automatically rebalance windows on vim resize
  autocmd VimResized * :wincmd =

" Update dir to current file
  autocmd BufEnter * silent! cd %:p:h

" Automatically deletes all trailing whitespace and newlines at end of file on save.
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufWritepre * %s/\n\+\%$//e

" Automatically save folds after restart
  " augroup remember_folds
  "   autocmd!
  "   au BufWinLeave ?* mkview 1
  "   au BufWinEnter ?* silent! loadview 1
  " augroup END

" Syntax highlighting and theme
  syntax on
  set bg=dark
	colorscheme ron

" Pmenu colors - YouCompleteMe colorscheme
	highlight Pmenu ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#565655

" Highlight the current line
  set cursorline
	hi cursorline term=bold cterm=bold
	hi CursorLineNr term=bold cterm=bold ctermbg=NONE

" Highlight active column
  set cursorcolumn

" BACKUP AND TMP FILES CONFIGURATION
" Save your swp files to a less annoying place than the current directory.
" " If you have .vim-swap in the current directory, it'll use that.
" " Otherwise it saves it to ~/.vim/swap, ~/tmp or .
  if isdirectory($HOME . '/.vim/backup') == 0
    :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
  endif
  set backupdir-=.
  set backupdir+=.
  set backupdir-=~/
  set backupdir^=~/.vim/backup/
  set backupdir^=./.vim-backup/
  set backup

  if isdirectory($HOME . '/.vim/swap') == 0
    :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
  endif
  set directory=./.vim-swap//
  set directory+=~/.vim/swap//
  set directory+=~/tmp//
  set directory+=.

" Viminfo stores the the state of your previous editing session
	set viminfo+=n~/.vim/viminfo

" Undofile - This allows you to use undos after exiting and restarting
" This, like swap and backups, uses .vim-undo first, then ~/.vim/undo
" :help undo-persistence
" This is only present in 7.3+
  if exists("+undofile")
    if isdirectory($HOME . '/.vim/undo') == 0
      :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
    endif
    set undodir=./.vim-undo//
    set undodir+=~/.vim/undo//
    set undofile
  endif

" YOUCOMPLETEME AND UTILSNIPS CONFIGUTARION
" make YCM compatible with UltiSnips (using supertab)
  let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
  let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
  let g:SuperTabDefaultCompletionType = '<C-n>'

" better key bindings for UltiSnipsExpandTrigger
  let g:UltiSnipsExpandTrigger = "<tab>"
  let g:UltiSnipsJumpForwardTrigger = "<tab>"
  let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" FZF CONFIGURATION AND BINDINGS
  let g:fzf_action = {
        \ 'ctrl-s': 'split',
        \ 'ctrl-v': 'vsplit'
        \ }
  let g:fzf_preview_window = 'right:60%'
  nnoremap <c-p> :Files<cr>
  nnoremap <c-o> :Buffers<cr>
  augroup fzf
    autocmd!
    autocmd! FileType fzf
    autocmd  FileType fzf set laststatus=0 noshowmode noruler
      \| autocmd BufLeave <buffer> set laststatus=2 showmode ruler
  augroup END

" Sessions management
  let g:sessions_dir = '~/.vim/session'
  exec 'nnoremap <Leader>ss :Obsession ' . g:sessions_dir . '/*.vim<C-D><BS><BS><BS><BS><BS>'
  exec 'nnoremap <Leader>sr :so ' . g:sessions_dir. '/*.vim<C-D><BS><BS><BS><BS><BS>'

" AIRLINE THEME
	let g:airline_theme='minimalist'
  let g:airline_powerline_fonts = 1
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#formatter = 'unique_tail'
  let g:airline#extensions#tabline#buffer_nr_show = 1
