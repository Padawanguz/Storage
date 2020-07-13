
" STARTIFY CONFIGURATION

" Sessions Directory
  let g:startify_session_dir = '~/.config/nvim/sessions'

" 'Most Recent Files' number
  let g:startify_files_number           = 30

" Update session automatically as you exit vim
  let g:startify_session_persistence    = 1

" Simplify the startify list to just recent files and sessions

  let g:startify_lists = [
    \ { 'type': 'dir',       'header': ['   - RECENT FILES -'] },
    \ { 'type': 'sessions',  'header': ['   - SAVED SESSIONS -'] },
    \ { 'type': 'bookmarks', 'header': ['   - BOOKMARKS -']      },
    \ ]

" Fancy custom header
  let g:startify_custom_header = [
                \ "      .            .      ",
                \ "    .,;'           :,.    ",
                \ "  .,;;;,,.         ccc;.  ",
                \ ".;c::::,,,'        ccccc: ",
                \ ".::cc::,,,,,.      cccccc.",
                \ ".cccccc;;;;;;'     llllll.",
                \ ".cccccc.,;;;;;;.   llllll.",
                \ ".cccccc  ';;;;;;'  oooooo.",
                \ "'lllllc   .;;;;;;;.oooooo'",
                \ "'lllllc     ,::::::looooo'",
                \ "'llllll      .:::::lloddd'",
                \ ".looool       .;::coooodo.",
                \ "  .cool         'ccoooc.  ",
                \ "    .co          .:o:.    ",
                \ "      .           .'      ",
                \]

                " \ '     ________ ;;     ________',
                " \ '    /********\;;;;  /********\',
                " \ '    \********/;;;;;;\********/',
                " \ '     |******|;;;;;;;;/*****/',
                " \ '     |******|;;;;;;/*****/''',
                " \ '    ;|******|;;;;/*****/'';',
                " \ '  ;;;|******|;;/*****/'';;;;;',
                " \ ';;;;;|******|/*****/'';;;;;;;;;',
                " \ '  ;;;|***********/'';;;;;;;;;',
                " \ '    ;|*********/'';;;;;;;;;',
                " \ '     |*******/'';;;;;;;;;',
                " \ '     |*****/'';;;;;;;;;',
                " \ '     |***/'';;;;;;;;;',
                " \ '     |*/''   ;;;;;;',
                " \ '              ;;',
                " \]

  let g:startify_skiplist = [
        \ 'COMMIT_EDITMSG',
        \ '^/tmp',
        \ escape(fnamemodify(resolve($VIMRUNTIME), ':p'), '\') .'doc',
        \ 'bundle/.*/doc',
        \ ]

let g:startify_bookmarks = [
            \ '~/.config/nvim/config/base.vim',
            \ '~/.config/nvim/config/plugins/plugins.vim',
            \ '~/.config/nvim/config/mappings.vim',
            \ '~/.config/nvim/config/plugins/config',
            \ ]

  let g:startify_padding_left = 5
  let g:startify_relative_path = 0
  let g:startify_fortune_use_unicode = 1
  let g:startify_change_to_vcs_root = 1
  let g:startify_session_autoload = 1
  let g:startify_update_oldfiles = 1
  let g:startify_use_env = 1
  let g:startify_session_before_save = [
    \ 'silent! NERDTreeClose'
    \ ]

  hi! link StartifyHeader Normal
  hi! link StartifyFile Directory
  hi! link StartifyPath LineNr
  hi! link StartifySlash StartifyPath
  hi! link StartifyBracket StartifyPath
  hi! link StartifyNumber Title

  autocmd User Startified setlocal cursorline
