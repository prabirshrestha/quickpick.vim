function! quickpick#open(opt) abort
  call quickpick#close() " hide existing picker if exists

  let s:state = extend({
      \ 'prompt': '>',
      \ 'cursor': 0,
      \ 'items': [],
      \ 'busy': 0,
      \ 'busyframes': [ '-', '\', '|', '/' ],
      \ 'busycurrentframe': 0,
      \ 'filetype': 'quickpick',
      \ 'promptfiletype': 'quickpick-filter',
      \ 'plug': 'quickpick-',
      \ 'input': '',
      \ 'maxheight': 10,
      \ }, a:opt)

  let s:inputecharpre = 0
    
  " create result buffer
  exe printf('keepalt botright 1new %s', s:state['filetype'])
  let s:state['bufnr'] = bufnr('%')
  let s:state['winid'] = win_getid(s:state['bufnr'])
  call s:set_buffer_options()
  call setline(1, s:state['items'])
  exe printf('resize %d', min([len(s:state['items']), s:state['maxheight']]))
  setlocal cursorline
  exec printf('setlocal filetype=' . s:state['filetype'])
  call s:notify('open', { 'bufnr': s:state['bufnr'] })

  " create prompt buffer
  exe printf('keepalt botright 1new %s', s:state['promptfiletype'])
  let s:state['promptbufnr'] = bufnr('%')
  let s:state['promptwinid'] = win_getid(s:state['promptbufnr'])
  call s:set_buffer_options()
  call setline(1, s:state['input'])
  resize 1

  " map keys
  inoremap <buffer><silent> <Plug>(quickpick-accept) <ESC>:<C-u>call <SID>on_accept()<CR>
  nnoremap <buffer><silent> <Plug>(quickpick-accept) :<C-u>call <SID>on_accept()<CR>

  inoremap <buffer><silent> <Plug>(quickpick-cancel) <ESC>:<C-u>call <SID>on_cancel()<CR>
  nnoremap <buffer><silent> <Plug>(quickpick-cancel) :<C-u>call <SID>on_cancel()<CR>

  inoremap <buffer><silent> <Plug>(quickpick-move-next) <ESC>:<C-u>call <SID>on_move_next()<CR>
  nnoremap <buffer><silent> <Plug>(quickpick-move-next) :<C-u>call <SID>on_move_next()<CR>

  inoremap <buffer><silent> <Plug>(quickpick-move-previous) <ESC>:<C-u>call <SID>on_move_previous()<CR>
  nnoremap <buffer><silent> <Plug>(quickpick-move-previous) :<C-u>call <SID>on_move_previous()<CR>

  exec printf('setlocal filetype=' . s:state['promptfiletype'])

  if !hasmapto('<Plug>(quickpick-accept)')
    imap <buffer><cr> <Plug>(quickpick-accept)
    nmap <buffer><cr> <Plug>(quickpick-accept)
  endif

  if !hasmapto('<Plug>(quickpick-cancel)')
    imap <silent> <buffer> <C-c> <Plug>(quickpick-cancel)
    map  <silent> <buffer> <C-c> <Plug>(quickpick-cancel)
    imap <silent> <buffer> <Esc> <Plug>(quickpick-cancel)
    map  <silent> <buffer> <Esc> <Plug>(quickpick-cancel)
  endif

  if !hasmapto('<Plug>(quickpick-move-next)')
    imap <silent> <buffer> <C-n> <Plug>(quickpick-move-next)
    nmap <silent> <buffer> <C-n> <Plug>(quickpick-move-next)
    imap <silent> <buffer> <C-j> <Plug>(quickpick-move-next)
    nmap <silent> <buffer> <C-j> <Plug>(quickpick-move-next)
  endif

  if !hasmapto('<Plug>(quickpick-move-previous)')
    imap <silent> <buffer> <C-p> <Plug>(quickpick-move-previous)
    nmap <silent> <buffer> <C-p> <Plug>(quickpick-move-previous)
    imap <silent> <buffer> <C-p> <Plug>(quickpick-move-previous)
    nmap <silent> <buffer> <C-k> <Plug>(quickpick-move-previous)
  endif

  call cursor(line('$'), 0)
  startinsert!

  augroup quickpick
    autocmd!
    autocmd InsertCharPre <buffer> call s:on_insertcharpre()
    autocmd TextChangedI <buffer> call s:on_inputchanged()
    autocmd InsertEnter <buffer> call s:on_insertenter()

    if exists('##TextChangedP')
      autocmd TextChangedP <buffer> call s:on_inputchanged()
    endif
  augroup END
endfunction

function! s:set_buffer_options() abort
  " set buffer options
  abc <buffer>
  setlocal bufhidden=unload           " unload buf when no longer displayed
  setlocal buftype=nofile             " buffer is not related to any file<Paste>
  setlocal noswapfile                 " don't create swap file
  setlocal nowrap                     " don't soft-wrap
  setlocal nonumber                   " don't show line numbers
  setlocal nolist                     " don't use list mode (visible tabs etc)
  setlocal foldcolumn=0               " don't show a fold column at side
  setlocal foldlevel=99               " don't fold anything
  setlocal nospell                    " spell checking off
  setlocal nobuflisted                " don't show up in the buffer list
  setlocal textwidth=0                " don't hardwarp (break long lines)
  setlocal nocursorline               " highlight the line cursor is off
  setlocal nocursorcolumn             " disable cursor column
  setlocal noundofile                 " don't enable undo
  setlocal winfixheight
  if exists('+colorcolumn') | setlocal colorcolumn=0 | endif
  if exists('+relativenumber') | setlocal norelativenumber | endif
  setlocal signcolumn=yes             " for prompt
endfunction

function! quickpick#close() abort
  if exists('s:state')
    call s:notify('close', { 'bufnr': s:state['bufnr'] })

    augroup quickpick
      autocmd!
    augroup END

    mapclear <buffer>
    exe 'silent! bunload! ' . s:state['promptbufnr']

    mapclear <buffer>
    exe 'silent! bunload! ' . s:state['bufnr']

    let s:inputecharpre = 0

    unlet s:state
  endif
endfunction

function! quickpick#items(items) abort
  let s:state['items'] = a:items
  call s:win_execute(s:state['winid'], 'silent! %delete')
  call setbufline(s:state['bufnr'], 1, s:state['items'])
  call s:win_execute(s:state['winid'], printf('%d resize %d', s:state['bufnr'], min([len(s:state['items']), s:state['maxheight']])))
  call s:notify('items', {})
endfunction

function! s:on_accept() abort
  let l:original_winid = win_getid()
  if win_gotoid(s:state['winid'])
    let l:line = getline('.')
    call win_gotoid(l:original_winid)
    call s:notify('accept', { 'items': [l:line] })
  end
endfunction

function! s:on_cancel() abort
  call s:notify('cancel', {})
  call quickpick#close()
endfunction

function! s:on_move_next() abort
  call s:win_execute(s:state['winid'], 'normal! j')
  call s:notify('selection', {})
endfunction

function! s:on_move_previous() abort
  call s:win_execute(s:state['winid'], 'normal! k')
  call s:notify('selection', {})
endfunction

function! s:on_inputchanged() abort
  if s:inputecharpre
    let s:state['input'] = getbufline(s:state['promptbufnr'], 1)[0]
    call s:notify('change', { 'input': s:state['input'] })
  endif
endfunction

function! s:on_insertcharpre() abort
  let s:inputecharpre = 1
endfunction

function! s:on_insertenter() abort
  let s:inputecharpre = 0
endfunction

function! s:notify(name, data) abort
  if has_key(s:state, 'on_event') | call s:state['on_event'](a:data, a:name) | endif
  if has_key(s:state, 'on_' . a:name) | call s:state['on_' . a:name](a:data, a:name) | endif
endfunction

if exists('*win_execute')
  function! s:win_execute(win_id, cmd) abort
    call win_execute(a:win_id, a:cmd)
  endfunction
else
  function! s:win_execute(winid, cmd) abort
    let l:original_winid = win_getid()
    if l:original_winid == a:winid
      exec a:cmd
    else
      if win_gotoid(a:winid)
        exec a:cmd
        call win_gotoid(l:original_winid)
      end
    endif
  endfunction
endif
