let s:id = 0
let s:pickers = {}
let s:current = -1
let s:bufnr = -1
let s:input = ''
let s:pos = 0

function! quickpick#create(...) abort
    let s:id = s:id + 1
    let s:pickers[s:id] = extend({
        \ 	'prompt': '> ',
        \   'items': [],
        \ },
        \ (len(a:000) == 0 ? {} : a:1))
    return s:id
endfunction

function! quickpick#show(id) abort
    if a:id < 1
        call s:show_error('invalid id ' . a:id)
        return -1
    endif
    if s:current != -1
        " todo hide existing picker
        call s:show_error('not implemented. hide existing picker first')
		return -1
    endif

    let s:current = a:id
    call s:render()
endfunction

function! quickpick#hide(id) abort
	if s:current == a:id
		silent quit
		exe 'silent! bunload! ' . s:bufnr
		let s:bufnr = -1
		let s:current = -1
		redraw
		echo
		mapclear <buffer>
	endif
endfunction

function! quickpick#close(id) abort
	call quickpick#hide(a:id)
	if has_key(s:pickers, a:id)
		call remove(s:pickers, a:id)
	endif
endfunction

function! quickpick#set_items(id, items) abort
    let s:pickers[a:id]['items'] = a:items
    call s:redraw_items(a:id)
endfunction

function! s:render() abort
    call s:create_buffer_if_not_exists()
	let s:input = ''
	let s:pos = 0
	call s:render_prompt()
    call s:redraw_items(s:current)
	call s:map_keys()
endfunction

function! s:redraw_items(id) abort
    if s:current > 0 && s:current == a:id
        let picker = s:pickers[s:current]
        let items = picker['items']
        silent! %delete
        call setline(1, items)
        let maxheight = 15
        exe printf('resize %d', min([len(items), maxheight]))
    endif
endfunction

function! s:create_buffer_if_not_exists() abort
    if s:bufnr == -1
        let picker = s:pickers[s:id]
        exe printf('keepalt botright 1split %s', 'QuickPick')
        let s:bufnr = bufnr('%')
        call s:set_buffer_options()
    else
        exe printf('botright sbuffer %d', s:bufnr)
        resize 1
    endif
endfunction

function! s:split_input()
    let left = s:pos == 0 ? '' : s:input[: s:pos-1]
    let cursor = s:input[s:pos]
    let right = s:input[s:pos+1 :]
    return [left, cursor, right]
endfunction

function! s:render_prompt() abort
	redraw
	let [left, cursor, right] = s:split_input()
	let picker = s:pickers[s:current]
	echohl Comment
    echon picker['prompt']
    echohl None
    echon left
	echohl Underlined
    echon cursor == '' ? ' ' : cursor
    echohl None
    echon right
endfunction

function! s:show_error(msg) abort
    echom a:msg
endfunction

function! s:set_buffer_options() abort
    setlocal filetype=quickpick
    setlocal bufhidden=unload " unload buf when no longer displayed
    setlocal buftype=nofile   " buffer is not related to any file<Paste>
    setlocal noswapfile       " don't create a swapfile
    setlocal nowrap           " don't soft-wrap
    setlocal nonumber         " don't show line numbers
    setlocal nolist           " don't use List mode (visible tabs etc)
    setlocal foldcolumn=0     " don't show a fold column at side
    setlocal foldlevel=99     " don't fold anything
    setlocal nocursorline     " don't highlight line cursor is on
    setlocal nospell          " spell-checking off
    setlocal nobuflisted      " don't show up in the buffer list
    setlocal textwidth=0      " don't hard-wrap (break long lines)
    if exists('+colorcolumn')
        setlocal colorcolumn=0
    endif
    if exists('+relativenumber')
        setlocal norelativenumber
    endif
endfunction

function! s:buf_leave() abort
	if s:bufnr > 0
		let picker = s:pickers[s:current]
        call quickpick#hide(s:current)
	endif
endfunction

function! s:map_keys() abort
	" Basic keys that aren't customizable.
    let lowercase = 'abcdefghijklmnopqrstuvwxyz'
    let uppercase = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ'
    let numbers = '0123456789'
    let punctuation = "<>`@#~!\"$%&/()=+*-_.,;:?\\\'{}[] " " and space
    for str in [lowercase, uppercase, numbers, punctuation]
        for key in split(str, '\zs')
			call s:map_key(printf('<Char-%d>', char2nr(key)), '<SID>handle_key', key)
        endfor
    endfor

    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<CR>', '<SID>on_accept', s:current)
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<BS>', '<SID>on_backspace', s:current)
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<Del>', '<SID>on_delete', s:current)
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<C-d>', '<SID>on_delete', s:current)
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<C-c>', '<SID>on_cancel', s:current)
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<Esc>', '<SID>on_cancel', s:current)
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<C-n>', '<SID>on_move_next', s:current)
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<C-j>', '<SID>on_move_next', s:current)
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<C-p>', '<SID>on_move_previous', s:current)
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<C-k>', '<SID>on_move_previous', s:current)
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", '<C-z>', '<SID>on_mark_toggle', s:current)
endfunction

function! s:map_key(key, func_name, ...) abort
    let args = empty(a:000) ? '' : string(join(a:000, ", "))
    exec printf("noremap <silent> <buffer> %s :call %s(%s)<cr>", a:key, a:func_name, args)
endfunction

function! s:handle_key(key) abort
	let [left, cursor, right] = s:split_input()
    let s:input = left . a:key . cursor . right
    let s:pos += 1
	call s:render_prompt()
	call s:change_hook()
endfunction

function! s:change_hook() abort
	let picker = s:pickers[s:current]
	if has_key(picker, 'on_change')
		call picker['on_change'](s:current, 'change', s:input)
	endif
endfunction

function! s:handle_event(hook) abort
	let picker = s:pickers[s:current]
    exec printf('call <SID>%s()', a:hook)
    if has_key(picker, a:hook)
        call picker[a:hook](s:current)
    endif
endfunction

function! s:on_backspace(id) abort
    if s:pos > 1
        let s:input = s:input[: s:pos-2] . s:input[s:pos :]
    else
        let s:input = s:input[s:pos :]
    endif
    let s:pos = s:pos == 0 ? 0 : s:pos-1
    call s:render_prompt()
    call s:change_hook()
endfunction

function! s:on_delete(id) abort
    if s:pos < len(s:input)
        let s:input = s:input[: s:pos-1] . s:input[s:pos+1 :]
        cal s:render_prompt()
        cal s:change_hook()
    endif
endfunction

function! s:on_accept(id) abort
	let picker = s:pickers[a:id]
	let items = [getline('.')]
	call picker['on_accept'](a:id, 'accept', {'items': items})
endfunction

function! s:on_move_next(id) abort
    normal! j
endfunction

function! s:on_move_previous(id) abort
    normal! k
endfunction

function! s:on_cancel(id) abort
    call quickpick#close(a:id)
endfunction

augroup QuickPick
	autocmd!
    autocmd BufLeave QuickPick  silent! call s:buf_leave()
augroup end
