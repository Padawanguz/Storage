
augroup CursedCursorLine
    autocmd!
    autocmd WinEnter *  if !cursed#is_disabled() | set cursorline | endif
    autocmd User CursedStartedMoving :set nocursorline
    autocmd User CursedStoppedMoving :set cursorline
augroup END
