
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
