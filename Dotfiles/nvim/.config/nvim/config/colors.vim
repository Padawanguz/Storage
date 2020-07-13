
  syntax on
  set bg=dark
	colorscheme ron

" Set cursorline Style
  set cursorline
	hi cursorline term=bold cterm=bold
	hi CursorLineNr term=bold cterm=NONE ctermbg=NONE

" Pmenu colors - YouCompleteMe colorscheme
	highlight Pmenu ctermfg=15 ctermbg=0 guifg=#ffffff guibg=#565655

" Italics
  hi! Comment cterm=italic gui=italic

" Adjust highlighting for MatchParen
  hi! link MatchParen CursorLineNr

" Adjust Git Subject line setting
  hi! link gitcommitSummary Normal
  hi! link gitcommitOverflow ErrorMsg

" Spellcheck
  hi! link SpellBad WarningMsg
