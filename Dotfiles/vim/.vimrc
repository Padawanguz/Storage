" Type :so % to refresh .vimrc after making changes

" Use Vim settings, rather then Vi settings. This setting must be as early as
" possible, as it has side effects.
	set nocompatible

" Vim-Plug Autoinstall Code
  if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
      \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
  endif

" Pluggins installed
  call plug#begin()

  Plug 'tpope/vim-surround'
  Plug 'tomtom/tcomment_vim'
  Plug 'jeetsukumaran/vim-filebeagle'
  Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'
  Plug 'tpope/vim-fugitive'
  Plug 'tpope/vim-rails'
  Plug 'vim-ruby/vim-ruby'
  Plug 'honza/vim-snippets'
  Plug 'sirver/UltiSnips'
  Plug 'ervandew/supertab'
  Plug 'junegunn/fzf'
  Plug 'junegunn/fzf.vim'
  Plug 'tpope/vim-obsession'
  Plug 'mhinz/vim-startify'

  call plug#end()

" Easier split navigation
  nnoremap <C-J> <C-W><C-J>
  nnoremap <C-K> <C-W><C-K>
  nnoremap <C-L> <C-W><C-L>
  nnoremap <C-H> <C-W><C-H>

" Set fish shell
	set shell=/usr/bin/fish

" Leader - ( Comma )
	let mapleader = ","

" Allow Copy and Paste - Must instal gvim
	set clipboard=unnamedplus

" Various Vim Options
  set ai
  set si
  set lbr
	set backspace=2
	" set nobackup
	" set nowritebackup
	" set noswapfile
	set history=1000
	set ruler
  set viminfo=!,h,f1,'100
	set showcmd
	set laststatus=2
	set autowrite
  set autoread
  set hidden         " hide buffers instead of closing
  set lazyredraw     " speed up on large files
  set mouse=         " disable mouse
  set scrolloff=999       " always keep cursor at the middle of screen
  set virtualedit=onemore " allow the cursor to move just past the end of the line
  set undolevels=5000     " set maximum undo levelsset autoread
  set foldmethod=manual       " use manual folding
  set diffopt=filler,vertical " default behavior for diff

" Trigger autoread when changing buffers or coming back to vim in terminal.
	au FocusGained,BufEnter * :silent! !

" Make searching better
  set incsearch
	set gdefault
	set ignorecase
	set smartcase
  nnoremap <silent> <leader>, :noh<cr> " Stop highlight after searching set incsearch
	set showmatch

" Disables automatic commenting on newline:
  autocmd FileType * setlocal formatoptions-=c formatoptions-=r formatoptions-=o

" Softtabs, 2 spaces
	set tabstop=2
	set shiftwidth=2
	set shiftround
	set expandtab
  set softtabstop=2 " remove <Tab> symbols as it was spaces
  set shiftround    " round indent to multiple of 'shiftwidth' (for << and >>)

" Enable autocompletion:
  set wildmode=longest,list,full
  set wildignore+=*.a,*.o,*.pyc,*~,*.swp,*.tmp

" Numbers
  set number relativenumber
  set numberwidth=5

" Open new split panes to right and bottom, which feels more natural
  set splitbelow splitright

" Save file as sudo on files that require root permission
  cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" " Auto resize Vim splits to active split
"   set winwidth=104
"   set winheight=5
"   set winminheight=5
"   set winheight=999

" HTML Editing
  set matchpairs+=<:>

" Treat <li> and <p> tags like the block tags they are
  let g:html_indent_tags = 'li\|p'

" Scrolling
  set scrolloff=8
  set sidescrolloff=15
  set sidescroll=1

" Use enter to create new lines w/o entering insert mode
  nmap <S-Enter> O<Esc>j
  nmap <CR> o<Esc>k

" Below is to fix issues with the ABOVE mappings in quickfix window
  autocmd CmdwinEnter * nnoremap <CR> <CR>
  autocmd BufReadPost quickfix nnoremap <CR> <CR>

" Navigate properly when lines are wrapped
  nnoremap j gj
  nnoremap k gk

" Resize panes
  nnoremap <silent> <Right> :vertical resize +5<cr>
  nnoremap <silent> <Left> :vertical resize -5<cr>
  nnoremap <silent> <Up> :resize +5<cr>
  nnoremap <silent> <Down> :resize -5<cr>

" Save whenever switching windows or leaving vim. This is useful when running
" the tests inside vim without having to save all files first.
  au FocusLost,WinLeave * :silent! wa

" Automatically rebalance windows on vim resize
  autocmd VimResized * :wincmd =

" Update dir to current file
  autocmd BufEnter * silent! cd %:p:h

" Ruby stuff
  filetype plugin indent on
    augroup myfiletypes
    " Clear old autocmds in group
      autocmd!

    " autoindent with two spaces, always expand tabs
      autocmd FileType ruby,eruby,yaml,markdown set ai sw=2 sts=2 et
    augroup END

" Omnifunction
  set omnifunc=syntaxcomplete#Complete

" Automatically deletes all trailing whitespace and newlines at end of file on
" save.
  autocmd BufWritePre * %s/\s\+$//e
  autocmd BufWritepre * %s/\n\+\%$//e

" Syntax highlighting and theme
  syntax on
  set bg=dark
	colorscheme ron

" Pmenu colors - YouCompleteMe colorscheme
	highlight Pmenu ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#565655

" Don't be a noob, join the no arrows key movement
  " inoremap  <Up>     <NOP>
  " inoremap  <Down>   <NOP>
  " inoremap  <Left>   <NOP>
  " inoremap  <Right>  <NOP>
  " noremap   <Up>     <NOP>
  " noremap   <Down>   <NOP>
  " noremap   <Left>   <NOP>
  " noremap   <Right>  <NOP>

" Highlight the current line
  set cursorline
	hi cursorline term=bold cterm=bold
	hi CursorLineNr term=bold cterm=bold ctermbg=NONE

" Highlight active column
  set cursorcolumn

" Backup / Tmp files
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

" ===== Seeing Is Believing =====
" Assumes you have a Ruby with SiB available in the PATH
" If it doesn't work, you may need to `gem install seeing_is_believing`

  function! WithoutChangingCursor(fn)
    let cursor_pos     = getpos('.')
    let wintop_pos     = getpos('w0')
    let old_lazyredraw = &lazyredraw
    let old_scrolloff  = &scrolloff
    set lazyredraw

    call a:fn()

    call setpos('.', wintop_pos)
    call setpos('.', cursor_pos)
    redraw
    let &lazyredraw = old_lazyredraw
    let scrolloff   = old_scrolloff
  endfun

  function! SibAnnotateAll(scope)
    call WithoutChangingCursor(function('execute', [a:scope . "!seeing_is_believing --timeout 12 --line-length 500 --number-of-captures 300 --alignment-strategy chunk"]))
  endfun

  function! SibAnnotateMarked(scope)
    call WithoutChangingCursor(function('execute', [a:scope . "!seeing_is_believing --xmpfilter-style --timeout 12 --line-length 500 --number-of-captures 300 --alignment-strategy chunk"]))
  endfun

  function! SibCleanAnnotations(scope)
    call WithoutChangingCursor(function('execute', [a:scope . "!seeing_is_believing --clean"]))
  endfun

  function! SibToggleMark()
    let pos  = getpos('.')
    let line = getline(".")
    if line =~ '^\s*$'
      let line = '# => '
    elseif line =~ '# =>'
      let line = substitute(line, ' *# =>.*', '', '')
    else
      let line .= '  # => '
    end
    call setline('.', line)
    call setpos('.', pos)
  endfun

" Enable seeing-is-believing mappings only for Ruby
  augroup seeingIsBelievingSettings
  " clear the settings if they already exist (so we don't run them twice)
    autocmd!
    autocmd FileType ruby nmap <buffer> <Leader>m :call SibAnnotateAll("%")<CR>;
    " autocmd FileType ruby nmap <buffer>  <Enter>  :call SibAnnotateMarked("%")<CR>;
    autocmd FileType ruby nmap <buffer> <Leader>n :call SibCleanAnnotations("%")<CR>;
    autocmd FileType ruby nmap <buffer> <Leader>b :call SibToggleMark()<CR>;
    autocmd FileType ruby vmap <buffer> <Leader>b :call SibToggleMark()<CR>;
    autocmd FileType ruby vmap <buffer> <Leader>m :call SibAnnotateAll("'<,'>")<CR>;
    " autocmd FileType ruby vmap <buffer> <Enter>   :call SibAnnotateMarked("'<,'>")<CR>;
    autocmd FileType ruby vmap <buffer> <Leader>n :call SibCleanAnnotations("'<,'>")<CR>;
  augroup END

" Airline Theme
	let g:airline_theme='solarized_flood'

" make YCM compatible with UltiSnips (using supertab)
  let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
  let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
  let g:SuperTabDefaultCompletionType = '<C-n>'

" better key bindings for UltiSnipsExpandTrigger
  let g:UltiSnipsExpandTrigger = "<tab>"
  let g:UltiSnipsJumpForwardTrigger = "<tab>"
  let g:UltiSnipsJumpBackwardTrigger = "<s-tab>"

" FZF configuration and bindings
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

" move among buffers with CTRL
  nnoremap <C-w> :bnext<CR>
  nnoremap <C-q> :bprevious<CR>

" Rails.vim bindings
  map <Leader>oc :Rcontroller<Space>
  map <Leader>ov :Rview<Space>
  map <Leader>om :Rmodel<Space>
  map <Leader>oh :Rhelper<Space>
  map <Leader>oj :Rjavascript<Space>
  map <Leader>os :Rstylesheet<Space>
  map <Leader>oi :Rintegration<Space>

" surround for adding surround 'physics'
  " # to surround with ruby string interpolation
  let g:surround_35 = "#{\r}"
  " - to surround with no-output erb tag
  let g:surround_45 = "<% \r %>"
  " = to surround with output erb tag
  let g:surround_61 = "<%= \r %>"
"
" Startify configuration
" 'Most Recent Files' number
    let g:startify_files_number           = 30

  " Update session automatically as you exit vim
    let g:startify_session_persistence    = 1

  " Simplify the startify list to just recent files and sessions

    let g:startify_lists = [
      \ { 'type': 'dir',       'header': ['   - RECENT FILES -'] },
      \ { 'type': 'sessions',  'header': ['   - SAVED SESSIONS -'] },
      \ ]

  " Fancy custom header
    let g:startify_custom_header = [
                  \ '     ________ ;;     ________',
                  \ '    /********\;;;;  /********\',
                  \ '    \********/;;;;;;\********/',
                  \ '     |******|;;;;;;;;/*****/',
                  \ '     |******|;;;;;;/*****/''',
                  \ '    ;|******|;;;;/*****/'';',
                  \ '  ;;;|******|;;/*****/'';;;;;',
                  \ ';;;;;|******|/*****/'';;;;;;;;;',
                  \ '  ;;;|***********/'';;;;;;;;;',
                  \ '    ;|*********/'';;;;;;;;;',
                  \ '     |*******/'';;;;;;;;;',
                  \ '     |*****/'';;;;;;;;;',
                  \ '     |***/'';;;;;;;;;',
                  \ '     |*/''   ;;;;;;',
                  \ '              ;;',
                  \]

    let g:startify_skiplist = [
          \ 'COMMIT_EDITMSG',
          \ '^/tmp',
          \ escape(fnamemodify(resolve($VIMRUNTIME), ':p'), '\') .'doc',
          \ 'bundle/.*/doc',
          \ ]

  let g:startify_padding_left = 5
  let g:startify_relative_path = 0
  let g:startify_fortune_use_unicode = 1
  let g:startify_change_to_vcs_root = 1
  let g:startify_session_autoload = 1
  let g:startify_update_oldfiles = 1
  let g:startify_use_env = 1

  hi! link StartifyHeader Normal
  hi! link StartifyFile Directory
  hi! link StartifyPath LineNr
  hi! link StartifySlash StartifyPath
  hi! link StartifyBracket StartifyPath
  hi! link StartifyNumber Title

  autocmd User Startified setlocal cursorline
