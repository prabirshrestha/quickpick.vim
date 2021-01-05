if exists('g:quickpick_vim')
    finish
endif
let g:quickpick = 1

command! -nargs=+ QuickpickEmbed :call quickpick#embedder#embed(<f-args>)
