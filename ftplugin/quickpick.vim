if !hasmapto('<Plug>(quickpick-backspace)')
  nmap <silent> <buffer> <BS> <Plug>(quickpick-backspace)
endif

if !hasmapto('<Plug>(quickpick-delete)')
  nmap <silent> <buffer> <Del> <Plug>(quickpick-delete)
  nmap <silent> <buffer> <Del> <Plug>(quickpick-delete)
endif

" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={{{,}}} foldmethod=marker spell:
