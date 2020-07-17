" ┏━━━━━━━━━━━━━━━━━┓
" ┃ File Operations ┃
" ┗━━━━━━━━━━━━━━━━━┛
" Save your swp files to a less annoying place than the current directory.
  if isdirectory($HOME . '/.config/nvim/backup') == 0
    :silent !mkdir -p ~/.config/nvim/backup >/dev/null 2>&1
  endif

  set backupdir=~/.config/nvim/backup//
  set backup

  if isdirectory($HOME . '/.config/nvim/swap') == 0
    :silent !mkdir -p ~/.config/nvim/swap >/dev/null 2>&1
  endif

  set directory=~/.config/nvim/swap//

" Viminfo stores the the state of your previous editing session
	set viminfo+=n~/.config/nvim/viminfo

" Undofile - This allows you to use undos after exiting and restarting
  if exists("+undofile")
    if isdirectory($HOME . '/.config/nvim/undo') == 0
      :silent !mkdir -p ~/.config/nvim/undo > /dev/null 2>&1
    endif

    set undodir=~/.config/nvim/undo//
    set undofile
  endif

" ┏━━━━┓
" ┃ UI ┃
" ┗━━━━┛
  set number                                                                " Show line numbers by default
  set relativenumber
  set lazyredraw                                                            " don't bother updating screen during macro playback
  set showmatch                                                             " show matching bracket
  set title                                                                 " show filename at the title of the window
  set cursorcolumn                                                          " highlight column
  set showtabline=2                                                         " always show tabline
  if exists('+emoji')
     set noemoji                                                           " handle emoji correctly (https://www.youtube.com/watch?v=F91VWOelFNE)
  endif

" ┏━━━━━━━━━━━━━━━━━━━━━┓
" ┃ Completion Settings ┃
" ┗━━━━━━━━━━━━━━━━━━━━━┛
  set completeopt+=menuone                                                  " Show the popup if only one completion
  set completeopt+=noinsert                                                 " Don't insert text for a match unless selected
  set completeopt+=noselect                                                 " Don't auto-select the first match
  set completeopt-=preview                                                  " Don't show extra info about the current completion

" ┏━━━━━━━━━━━┓
" ┃ Behaviors ┃
" ┗━━━━━━━━━━━┛
  syntax sync minlines=256                                                  " start highlighting from 256 lines backwards
  set shell=/usr/bin/fish
  set synmaxcol=300                                                         " do not highlight very long lines
  set hidden                                                                " Allow bufs to be sent to background
  set tildeop                                                               " Make tilde command behave like an operator.
  set shortmess+=A                                                          " ignore annoying swapfile messages
  set shortmess+=I                                                          " no splash screen
  set shortmess+=O                                                          " file-read message overwrites previous
  set shortmess+=T                                                          " truncate non-file messages in middle
  set shortmess+=W                                                          " don't echo '[w]'/'[written]' when writing
  set shortmess+=a                                                          " use abbreviations in messages eg. `[RO]` instead of `[readonly]`
  set shortmess+=o                                                          " overwrite file-written messages
  set shortmess+=t                                                          " truncate file messages at start
  set shortmess+=c                                                          " hide annoying completion messages
  if has('showcmd')
      set showcmd                                                           " extra info at end of command line
  endif
  set noshowmode                                                            " Don't Display the mode you're in. since it's already shown on the statusline
  set diffopt+=vertical                                                     " Split diffs vertically
  if has('nvim')
      set inccommand=split                                                  " incremental command live feedback
  endif
  if exists('&belloff')
      set belloff=all                                                       " never ring the bell for any reason
  endif
  set visualbell                                                            " No beeping.
  set noerrorbells                                                          " No flashing.
  set undolevels=5000                                                       " set maximum undo levelsset autoread
  set history=1000
  set clipboard=unnamed                                                     " yank and paste with the system clipboard
  set autowrite
  set autoread                                                              " reload files when changed on disk, i.e. via `git checkout`
  set scrolloff=5                                                           " Start scrolling slightly before the cursor reaches an edge
  set sidescrolloff=5
  set sidescroll=3                                                          " Scroll sideways a character at a time, rather than a screen at a time
  set timeout
  set updatetime=1000
" Timeout on keystrokes
  set ttimeout
  set ttimeoutlen=10
" More natural splitting
  set splitbelow
  set splitright
  if has('virtualedit')
      set virtualedit=block                                                 " allow cursor to move where there is no text in visual block mode
  endif
  set whichwrap=b,h,l,s,<,>,[,],~                                           " allow <BS>/h/l/<Left>/<Right>/<Space>, ~ to cross line boundaries
  set nostartofline                                                         " don't move the cursos after some commands. (:h 'startofline')
  set switchbuf="usetab,newtab"

" ┏━━━━━━━━━━━━━┓
" ┃ Spell Check ┃
" ┗━━━━━━━━━━━━━┛
" https://robots.thoughtbot.com/opt-in-project-specific-vim-spell-checking-and-word-completion
  set spelllang=en_us,es                                                    " set en_US as primary language, pt_BR as secondary
" Set both spellfiles
  execute 'set spellfile='.$VIMHOME.'/spell/en.utf-8.add'.','.$VIMHOME.'/spell/es.utf-8.add'
  set complete+=kspell                                                      " Use spell suggestions for completion
  if has('syntax')
      set spellcapcheck=                                                    " don't check for capital letters at start of sentence
  endif

" ┏━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┓
" ┃ Selection Menu (when editing files, for example) ┃
" ┗━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━┛
  set wildmenu                                                              " Enhanced mode command line completion
  set wildmode=longest:full,list,full                                       " show a navigable menu for tab completion
  " ────────────────────────────────────────────────────⇥  Ignore files that are…
  set wildignore+=.hg,.git,.svn                                             " …from Version control
  set wildignore+=*.jpg,*.bmp,*.gif,*.png,*.jpeg                            " …binary images
  set wildignore+=*.o,*.obj,*.exe,*.dll,*.manifest                          " …compiled object files
  set wildignore+=*.spl                                                     " …compiled spelling word lists
  set wildignore+=*.sw?                                                     " …Vim swap files
  set wildignore+=*.DS_Store                                                " …OSX bullshit
  set wildignore+=migrations                                                " …Laravel migrations
  set wildignore+=*.pyc                                                     " …Python byte code
  set wildignore+=*.orig                                                    " …merge resolution files
  set wildignore+=*.rbc,*.rbo,*.gem                                         " …compiled stuff from Ruby
  set wildignore+=*/vendor/*,*/.bundle/*,*/.sass-cache/*                    " …vendor files
  set wildignore+=*/node_modules/*                                          " …JavaScript modules
  set wildignore+=package-lock.json                                         " …package-lock.json
  set wildignore+=tags                                                      " …(c)tags files

" ┏━━━━━━━━━━━━━┓
" ┃ Text Format ┃
" ┗━━━━━━━━━━━━━┛
  set expandtab                                                             " always use spaces instead of tabs
  set tabstop=2                                                             " units per tab
  set softtabstop=2                                                         " spaces per tab
  set shiftwidth=2                                                          " spaces per tab (when shifting)
  set shiftround                                                            " always indent by multiple of shiftwidth
  set nowrap                                                                " no wrap
  set textwidth=80                                                          " maximum text width
                                                                            " Formating options…
  set foldmethod=syntax                                                     " use manual folding
  set formatoptions+=n                                                      " …smart auto-indenting inside numbered lists
  set formatoptions+=r                                                      " …insert current comment leader when entering new-line in insert mode
  set formatoptions+=1                                                      " …try to break lines before one letter words instead of after

" ┏━━━━━━━━━━━┓
" ┃ Searching ┃
" ┗━━━━━━━━━━━┛
  set ignorecase smartcase                                                  " Ignore case in search.
  set incsearch                                                             " Incremental search
  set nohlsearch                                                            " Highlight search matches
  set showmatch

" ┏━━━━━━━━┓
" ┃ Visual ┃
" ┗━━━━━━━━┛
  " set list                                                                  " show trailing whitespace
  " set listchars=nbsp:░                                                      " Show non-breaking space - LIGHT SHADE (U+2591)
  " set listchars+=eol:¬                                                      " Show End of Line - NOT SIGN (U+00AC)
  " set listchars+=trail:·                                                    " Show trailing space - MID DOT (U+00B7)
  " set listchars=tab:▸\ ,                                                    " Show Tab characters - BLACK RIGH SMALL POINTING TRIANGLE (U+25B8)
  " set listchars+=precedes:«                                                 " Show Line extending indicator to the left - RIGHT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00AB)
  " set listchars+=extends:»                                                  " Show Line extending indicator to the right - LEFT-POINTING DOUBLE ANGLE QUOTATION MARK (U+00BB)
  " set nojoinspaces                                                          " don't autoinsert two spaces after '.', '?', '!' for join command
  " set concealcursor=n                                                       " Keep it concealed in normal mode, unconceal otherwise
  " set conceallevel=2                                                        " Conceal everything that is concealable
  " set virtualedit=block

  if has('windows')
      set fillchars=diff:⣿                                                  " deleted lines in diffs - BRAILLE PATTERN (U+28FF)
      set fillchars+=vert:┃                                                 " vertical splits - BOX DRAWINGS HEAVY VERTICAL (U+2503)
      set fillchars+=fold:─                                                 " filling for foldtext - BOX DRAWINGS LIGHT HORIZONTAL (U+2500)
  endif

  if has('linebreak')
      set linebreak                                                         " smart line wrapping (:h linebreak and :h breakat)
      let &showbreak='↳ '                                                   " DOWNWARDS ARROW WITH TIP RIGHTWARDS (U+21B3)
      set breakindent                                                       " indent wrapped lines to match start
      if exists('&breakindentopt')
          set breakindentopt=shift:2                                        " emphasize broken lines by indenting them
      endif
  endif

" ┏━━━━━━━┓
" ┃ Mouse ┃
" ┗━━━━━━━┛
  if has('mouse')
      set mouse=                                                           " Disable mouse support
  endif

  set guicursor=a:blinkon100                                               " Enable cursor blink
