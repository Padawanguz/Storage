
" Toggle ALE
  nmap <leader>a :ALEToggle<CR>

let g:ale_enabled = 0
let g:ale_fix_on_save = 1
let g:ale_lint_on_save = 1
let g:ale_lint_on_insert_leave = 1
let g:ale_lint_on_enter = 0
let g:ale_lint_on_text_changed = 'normal'
let g:ale_open_list = 0
let g:ale_set_signs = 1
let g:ale_set_loclist = 1
let g:ale_set_quickfix = 0
let g:ale_javascript_eslint_suppress_missing_config = 1
let g:ale_javascript_eslint_suppress_eslintignore = 1
let g:ale_javascript_prettier_use_local_config = 1
let g:ale_linters_explicit = 1
function! s:PRETTIER_OPTIONS()
  return '--config-precedence prefer-file --prose-wrap preserve'
endfunction
let g:ale_javascript_prettier_options = <SID>PRETTIER_OPTIONS()
augroup PrettierTextWidth
    " Auto update the option when textwidth is dynamically set or changed in a ftplugin file
    au! OptionSet textwidth let g:ale_javascript_prettier_options = <SID>PRETTIER_OPTIONS()
augroup END

let g:ale_linters = {
            \ 'javascript' : ['eslint'],
            \ 'typescript' : ['eslint'],
            \ 'vue'        : ['eslint'],
            \ 'vim'        : ['vint'],
            \ 'markdown'   : ['alex'],
            \ 'sh'         : ['shellcheck'],
            \ 'bash'       : ['shellcheck'],
            \ 'ruby'       : ['rubocop'],
            \}

let g:ale_fixers = {
            \ 'markdown'       : ['prettier'],
            \ 'javascript'     : ['prettier'],
            \ 'javascript.jsx' : ['prettier'],
            \ 'javascriptreact' : ['prettier'],
            \ 'typescript'     : ['prettier'],
            \ 'typescript.tsx' : ['prettier'],
            \ 'typescriptreact' : ['prettier'],
            \ 'vue'            : ['prettier'],
            \ 'json'           : ['prettier'],
            \ 'css'            : ['prettier'],
            \ 'scss'           : ['prettier'],
            \ 'html'           : ['prettier'],
            \ 'graphql'        : ['prettier'],
            \ 'sh'             : ['shfmt'],
            \ 'bash'           : ['shfmt'],
            \ 'ruby'           : ['rubocop'],
            \}

" Don't auto fix (format) files inside `node_modules`, minified files and jquery (for legacy codebases)
" Also, don't lint markdown files that end in a pattern that resembles
" a language code (for example index.pt.md or index.pt-br.md) because `alex`
" only understands english
let g:ale_pattern_options_enabled = 1
let g:ale_pattern_options = {
            \   '\.min\.(js\|css)$': {
            \       'ale_linters': [],
            \       'ale_fixers': []
            \   },
            \   'jquery.*': {
            \       'ale_linters': [],
            \       'ale_fixers': []
            \   },
            \   'node_modules/.*': {
            \       'ale_linters': [],
            \       'ale_fixers': []
            \   },
            \   '.*\.[a-z]{2}(-[a-z]{2})?\.md': {
            \       'ale_linters': [],
            \   },
            \}
