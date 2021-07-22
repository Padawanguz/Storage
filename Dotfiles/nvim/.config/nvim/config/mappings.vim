
" ┌────────┐
" │ Leader │
" └────────┘

" nnoremap <SPACE> <Nop>
let mapleader = ","
let maplocalleader =","

" ┌──────────────────────┐
" │ Cursor/Text Movement │
" └──────────────────────┘

" Use enter and space w/o entering insert mode
nmap <Enter> O<Esc>
nmap <CR> o<Esc>k
nnoremap <space> i<space><esc>

" Disable arrow keys (hardcore)
nmap  <up>    <nop>
nmap  <down>  <nop>
nmap  <left>  <nop>
nmap  <right> <nop>

" Make arrowkey do something usefull, resize the viewports accordingly
"" [N] <Left> -- Make window larger horizontally
"" [N] <Right> -- Make window smaller horizontally
"" [N] <Up> -- Make window bigger vertically
"" [N] <Down> -- Make window smaller vertically
nnoremap <Left> :vertical resize +2<CR>
nnoremap <Right> :vertical resize -2<CR>
nnoremap <Up> :resize +2<CR>
nnoremap <Down> :resize -2<CR>

" Treat overflowing lines as having line breaks.
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
xnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
xnoremap <expr> k (v:count == 0 ? 'gk' : 'k')

" Quickly move current line up/down, also accepts counts 2<leader>j
" and also works with visual selection
"" [N] <ctrl>d -- Move current line {count}lines down
"" [N] <ctrl>u -- Move current line {count}lines up
"" [V] <ctrl>d -- Move current line {count}lines down
"" [V] <ctrl>u -- Move current line {count}lines up
"" [I] <ctrl>d -- Move current line {count}lines down
"" [I] <ctrl>u -- Move current line {count}lines up
nnoremap <C-d> :m .+1<CR>==
nnoremap <C-u> :m .-2<CR>==
inoremap <C-d> <Esc>:m .+1<CR>==gi
inoremap <C-u> <Esc>:m .-2<CR>==gi
vnoremap <C-d> :m '>+1<CR>gv=gv
vnoremap <C-u> :m '<-2<CR>gv=gv

" Make `Y` behave like `C` and `D` (to the end of line)
"" [N] Y -- Copy from curent cursor position until EOL
nnoremap Y y$

" keep search matches in the middle of the window.
nmap n nzz
nmap N Nzz

" https://github.com/mhinz/vim-galore#dont-lose-selection-when-shifting-sidewards
xnoremap <  <gv
xnoremap >  >gv

" Don't move cursor when yanking stuff!
" See http://ddrscott.github.io/blog/2016/yank-without-jank/
vnoremap <expr>y "my\"" . v:register . "y`y"

" Add line to the beggining/end of the file. Add a mark o/O to make it easy to get back to where you
" were
"" [N] <Leader>o -- Add a line at the beggining of the file
"" [N] <Leader>O -- Add a line at the end of file
nnoremap <Leader>o moGGo
nnoremap <Leader>O mOggO

" Easily move to beggining and end of the line
" https://github.com/shelldandy/dotfiles/blob/master/config/nvim/keys.vim#L114
"" [N] H -- Go to the beggining of the line
"" [N] L -- Go the the end of the line
nnoremap H ^
nnoremap L $

" ┌──────────────────────┐
" │ Insert mode mappings │
" └──────────────────────┘

" Make better undo chunks when writing long texts (prose) without exiting insert mode.
" :h i_CTRL-G_u
" https://twitter.com/vimgifs/status/913390282242232320
inoremap . .<c-g>u
inoremap ? ?<c-g>u
inoremap ! !<c-g>u
inoremap , ,<c-g>u

" Pressing up/down exits insert mode
inoremap <silent> <Up> <ESC>
inoremap <silent> <Down> <ESC>

" ┌────────────────────────┐
" │ Window/Buffer Mappings │
" └────────────────────────┘

" Use CTRL+[HJKL] to navigate between panes, instead of CTRL+W CTRL+[HJKL]
"" [N] <C-h> -- Go to pane to the right of the current one
"" [N] <C-j> -- Go to the pane below current one
"" [N] <C-k> -- Go to the pane above current one
"" [N] <C-l> -- Go to the pane to the left of the current one
nnoremap <C-h> <C-w><C-h>
nnoremap <C-j> <C-w><C-j>
nnoremap <C-k> <C-w><C-k>
nnoremap <C-l> <C-w><C-l>

"" [N] <Bar> -- Split window vertically
"" [N] _ -- Split Window Horizontally
" nnoremap <expr><silent> <Bar> v:count == 0 ? "<C-W>v<C-W><Right>" : ":<C-U>normal! 0".v:count."<Bar><CR>"
" nnoremap <expr><silent> _     v:count == 0 ? "<C-W>s<C-W><Down>"  : ":<C-U>normal! ".v:count."_<CR>"
nnoremap <expr><silent> <Bar> v:count == 0 ? ":vnew +terminal<CR>" : ":<C-U>normal! 0".v:count."<Bar><CR>"
nnoremap <expr><silent> _     v:count == 0 ? ":new +terminal<CR>"  : ":<C-U>normal! ".v:count."_<CR>"

"" [N] <tab> -- Next buffer
"" [N] <S-tab> -- Previous buffer
nnoremap <tab>   :bnext<CR>
nnoremap <S-tab> :bprevious<CR>

" [N] <Ctrl> q quits all windows
" [N] <Ctrl> s saves all windows
" [N] <space> xx close buffer AND closes window - destroy layout
nnoremap <C-q> :qall<CR>
nnoremap <C-s> :wall<CR>
nnoremap <Leader>xx :bdelete<CR>

" ┌──────────────────┐
" │ Utility Mappings │
" └──────────────────┘

" PlugInstall & PlugClean - Vim-Plug
  nnoremap <Leader>pi :w <bar> :so % <bar> :PlugInstall<CR>
  nnoremap <Leader>pc :w <bar> :so % <bar> :PlugClean<CR>

" Toggle Spellcheck
  nnoremap <Leader>sc :setlocal spell! spelllang=es<CR>

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

  "Autoclose Settings
  " inoremap " ""<left>
  " inoremap ' ''<left>
  " inoremap ( ()<left>
  " inoremap [ []<left>
  " inoremap { {}<left>
  " inoremap < <><left>
  " inoremap ~ ~~<left>
  " inoremap {<CR> {<CR>}<ESC>O
  " inoremap {;<CR> {<CR>};<ESC>O " inoremap (; (<CR>);<C-c>O
