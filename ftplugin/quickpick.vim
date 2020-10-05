if !hasmapto('<Plug>(quickpick-accept)')
  nmap <silent> <buffer> <CR> <Plug>(quickpick-accept)
endif

if !hasmapto('<Plug>(quickpick-backspace)')
  nmap <silent> <buffer> <BS> <Plug>(quickpick-backspace)
endif

if !hasmapto('<Plug>(quickpick-delete)')
  nmap <silent> <buffer> <Del> <Plug>(quickpick-delete)
  nmap <silent> <buffer> <Del> <Plug>(quickpick-delete)
endif

if !hasmapto('<Plug>(quickpick-cancel)')
  nmap <silent> <buffer> <C-c> <Plug>(quickpick-cancel)
  nmap <silent> <buffer> <Esc> <Plug>(quickpick-cancel)
endif

if !hasmapto('<Plug>(quickpick-move-next)')
  nmap <silent> <buffer> <C-n> <Plug>(quickpick-move-next)
  nmap <silent> <buffer> <C-j> <Plug>(quickpick-move-next)
endif

if !hasmapto('<Plug>(quickpick-move-previous)')
  nmap <silent> <buffer> <C-p> <Plug>(quickpick-move-previous)
  nmap <silent> <buffer> <C-k> <Plug>(quickpick-move-previous)
endif

" vim: set sw=2 ts=2 sts=2 et tw=78 foldmarker={{{,}}} foldmethod=marker spell:
