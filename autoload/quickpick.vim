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
    
  " create result buffer
  exe printf('keepalt botright 1new %s', s:state['filetype'])
  let s:state['bufnr'] = bufnr('%')
  call s:set_buffer_options()
  call setline(1, s:state['items'])
  exe printf('resize %d', min([len(s:state['items']), s:state['maxheight']]))
  setlocal cursorline
  exec printf('setlocal filetype=' . s:state['filetype'])

  exe printf('keepalt botright 1new %s', s:state['promptfiletype'])
  let s:state['promptbufnr'] = bufnr('%')
  call s:set_buffer_options()
  call setline(1, s:state['input'])
  resize 1
  exec printf('setlocal filetype=' . s:state['promptfiletype'])

  " map keys
  inoremap <buffer><silent> <Plug>(quickpick-accept) <ESC>:<C-u>call <SID>on_accept()<CR>
  nnoremap <buffer><silent> <Plug>(quickpick-accept) :<C-u>call <SID>on_accept()<CR>

  inoremap <buffer><silent> <Plug>(quickpick-cancel) <ESC>:<C-u>call <SID>on_cancel()<CR>
  nnoremap <buffer><silent> <Plug>(quickpick-cancel) :<C-u>call <SID>on_cancel()<CR>

  inoremap <buffer><silent><expr> <Plug>(quickpick-backspace) col('.') == 1 ? "a\<BS>" : "\<BS>"


  if !hasmapto('<Plug>(quickpick-accept)')
    imap <buffer><cr> <Plug>(quickpick-accept)
  endif

  if !hasmapto('<Plug>(quickpick-cancel)')
    imap <silent> <buffer> <C-c> <Plug>(quickpick-cancel)
    map <silent> <buffer> <C-c> <Plug>(quickpick-cancel)
    imap <silent> <buffer> <Esc> <Plug>(quickpick-cancel)
    map <silent> <buffer> <Esc> <Plug>(quickpick-cancel)
  endif

  imap <buffer> <BS> <Plug>(quickpick-backspace)
  imap <buffer> <C-h> <Plug>(quickpick-backspace)

  call cursor(line('$'), 0)
  startinsert!

  " " map keys
  " let l:lowercase = 'abcdefghijklmnopqrstuvwxyz'
  " let l:uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
  " let l:numbers = '0123456789'
  " let l:punctuation = "<>`@#~!\"$%&/()=+*-_.,;:?\\\'{}[] " " and space
  " for l:str in [l:lowercase, l:uppercase, l:numbers, l:punctuation]
  "   for l:key in split(l:str, '\zs')
  "     exec printf('noremap <silent> <buffer> <nowait> <char-%d> :call <SID>handle_key("%s")<cr>', char2nr(l:key), l:key)
  "   endfor
  " endfor

  " " ex: <plug>(quickpick-accept)
  " let l:mappings = {
  "   \ 'accept': '<SID>on_accept',
  "   \ 'backspace': '<SID>on_backspace',
  "   \ 'delete': '<SID>on_delete',
  "   \ 'cancel': '<SID>on_cancel',
  "   \ 'move-next': '<SID>on_move_next',
  "   \ 'move-previous': '<SID>on_move_previous',
  "   \ }
  " for l:key in keys(l:mappings)
  "   exec printf('noremap <silent> <buffer> <plug>(%s%s) :call %s()<cr>', s:state['plug'], l:key, l:mappings[l:key])
  " endfor

  " call s:notify('open', { 'bufnr': s:state['bufnr'] })

  " call s:render_prompt(s:state)
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

    mapclear <buffer>
    exe 'silent! bunload! ' . s:state['promptbufnr']

    mapclear <buffer>
    exe 'silent! bunload! ' . s:state['bufnr']

    unlet s:state
  endif
endfunction

function! quickpick#items(items) abort
  exec '1,$d'
  let s:state['items'] = a:items
  call setline(1, s:state['items'])
  exe printf('resize %d', min([len(s:state['items']), s:state['maxheight']]))
  call s:render_prompt(s:state)
endfunction

function! s:on_accept() abort
  call s:notify('accept', { 'items': [line('.')] })
endfunction

function! s:on_delete() abort
  call s:render_prompt(s:state)
endfunction

function! s:on_cancel() abort
  call s:notify('cancel', {})
  call quickpick#close()
endfunction

function! s:on_move_next() abort
  normal! j
  call s:notify('change', {})
  call s:render_prompt(s:state)
endfunction

function! s:on_move_previous() abort
  normal! k
  call s:notify('change', {})
  call s:render_prompt(s:state)
endfunction

function! s:handle_key(key) abort
    call s:prompt_insert(s:state, a:key)
    call s:render_prompt(s:state)
endfunction

function! s:notify(name, data) abort
  if has_key(s:state, 'on_event') | call s:state['on_event'](a:data, a:name) | endif
  if has_key(s:state, 'on_' . a:name) | call s:state['on_' . a:name](a:data, a:name) | endif
endfunction

" ---- BEGIN PROMPT LOGIC -----

" multi-byte character support substr
function! s:substr(src, s, e) abort
  let chars = split(a:src, '\zs')
  return join(chars[a:s : a:e], '')
endfunction

function! s:cursor_ltext(state) abort
  return a:state['cursor'] == 0 ? '' : s:substr(a:state['input'], 0, a:state['cursor'] - 1)
endfunction

function! s:cursor_ctext(state) abort
  return s:substr(a:state['input'], a:state['cursor'], a:state['cursor'])
endfunction

function! s:cursor_rtext(state) abort
  return s:substr(a:state['input'], a:state['cursor'] + 1, - 1)
endfunction

function! s:cursor_lshift(state, n) abort
  let a:state['cursor'] -= a:n
  let a:state['cursor'] = a:state['cursor'] <= 0 ? 0 : a:state['cursor']
endfunction

function! s:cursor_rshift(state, n) abort
  let l:threshold = strchars(a:state['input'])
  let a:state['cursor'] += a:n
  let a:state['cursor'] = a:state['cursor'] >= l:threshold ? l:threshold : a:state['cursor']
endfunction

function! s:prompt_home(state) abort
  let a:state['cursor'] = 0
endfunction

function! s:prompt_end(state) abort
  let a:state['cursor'] = strchars(a:state['input'])
endfunction

function! s:prompt_insert(state, newtext) abort
  let l:lhs = s:cursor_ltext(a:state)
  let l:rhs = s:cursor_ctext(a:state) . s:cursor_rtext(a:state)
  let a:state['input'] = l:lhs . a:newtext . l:rhs
  call s:cursor_rshift(a:state, strchars(a:newtext))
endfunction

function! s:prompt_ldelete(state) abort
  let l:lhs = s:cursor_ltext(a:state)
  if empty(l:lhs) | return | endif
  let l:lhs = s:substr(l:lhs, 0, -2)
  let l:rhs = s:cursor_ctext(a:state) . s:cursor_rtext(a:state)
  let a:state['input'] = l:lhs . l:rhs
  call s:cursor_lshift(a:state, 1)
endfunction

function! s:prompt_replace(state, text) abort
  let a:state['input'] = a:text
  let a:state['cursor'] = strchars(a:text)
endfunction

function! s:render_prompt(state) abort " state contains { 'cursor', 'input', 'prompt' }
  redraw
  echohl Question | echon a:state['prompt']
  echohl None     | echon s:cursor_ltext(a:state)
  echohl Cursor   | echon s:cursor_ctext(a:state) . ' '
  echohl None     | echon s:cursor_rtext(a:state)
endfunction

" ---- END PROMPT LOGIC -----
