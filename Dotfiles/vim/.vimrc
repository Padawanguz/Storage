" Type :so % to refresh .vimrc after making changes

	set nocompatible
	set shell=/usr/bin/fish
	set clipboard=unnamedplus   " Allow Copy and Paste - Must instal gvim
	let mapleader = ","

" VIM-PLUG CONFIGURATION
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

" MAPPING AND NAVIGATION CONFIGURATIONS
" Easier split navigation
  nnoremap <C-J> <C-W><C-J>
  nnoremap <C-K> <C-W><C-K>
  nnoremap <C-L> <C-W><C-L>
  nnoremap <C-H> <C-W><C-H>

" move among buffers with CTRL
  nnoremap <C-w> :bnext<CR>
  nnoremap <C-q> :bprevious<CR>

" Manual Folding
  inoremap <F9> <C-O>za
  nnoremap <F9> za
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
  nnoremap <space> i<space><esc>

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

" VARIOUS VIM OPTIONS
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
  augroup AutoSaveFolds
    autocmd!
    autocmd BufWinLeave * mkview
    autocmd BufWinEnter * silent loadview
  augroup END

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

" SEEING IS BELIEVING CONFIGURATION
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

" RUBY ON RAILS CONFIGURATION
" Ruby stuff
  filetype plugin indent on
    augroup myfiletypes
    " Clear old autocmds in group
      autocmd!

    " autoindent with two spaces, always expand tabs
      autocmd FileType ruby,eruby,yaml,markdown set ai sw=2 sts=2 et
    augroup END

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

" STARTIFY CONFIGURATION
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

" Sessions management
  let g:sessions_dir = '~/.vim/session'
  exec 'nnoremap <Leader>ss :Obsession ' . g:sessions_dir . '/*.vim<C-D><BS><BS><BS><BS><BS>'
  exec 'nnoremap <Leader>sr :so ' . g:sessions_dir. '/*.vim<C-D><BS><BS><BS><BS><BS>'

" AIRLINE THEME
	let g:airline_theme='solarized_flood'
  let g:airline_powerline_fonts = 1
