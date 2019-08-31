if !hasmapto('<Plug>(quickpick_accept)')
    nmap <silent> <buffer> <CR> <Plug>(quickpick_accept)
endif

if !hasmapto('<Plug>(quickpick_backspace)')
    nmap <silent> <buffer> <BS> <Plug>(quickpick_backspace)
endif

if !hasmapto('<Plug>(quickpick_delete)')
    nmap <silent> <buffer> <Del> <Plug>(quickpick_delete)
    nmap <silent> <buffer> <Del> <Plug>(quickpick_delete)
endif

if !hasmapto('<Plug>(quickpick_cancel)')
    nmap <silent> <buffer> <C-c> <Plug>(quickpick_cancel)
    nmap <silent> <buffer> <Esc> <Plug>(quickpick_cancel)
endif

if !hasmapto('<Plug>(quickpick_move_next)')
    nmap <silent> <buffer> <C-n> <Plug>(quickpick_move_next)
    nmap <silent> <buffer> <C-j> <Plug>(quickpick_move_next)
endif

if !hasmapto('<Plug>(quickpick_move_previous)')
    nmap <silent> <buffer> <C-p> <Plug>(quickpick_move_previous)
    nmap <silent> <buffer> <C-k> <Plug>(quickpick_move_previous)
endif

" vim: set sw=4 ts=4 sts=4 et tw=78 foldmarker={{{,}}} foldmethod=marker spell:
