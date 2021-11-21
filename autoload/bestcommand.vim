let g:bestcommend#height = 5
let g:bestcommend#width = 20

let s:messages = []
let g:bestcommend#rules = [
\       's:rule_no_l',
\       's:rule_no_h',
\       's:rule_no_arrow',
\]

func! bestcommend#start() abort
    augroup bestcommend
        au!
        au User KeyPress call s:handle_keypress()
    augroup END

    call s:create_popup()
endfunc

func! s:create_popup() abort
    if exists('s:popup')
            call popup_close(s:popup)
    endif

    let s:popup = popup_create(s:messages, {
    \   'line': winheight(0) - g:bestcommend#height,
    \   'col': winwidth(0) - g:bestcommend#width,
    \   'minwidth': g:bestcommend#width,
    \   'minheight': g:bestcommend#height,
    \   'padding': [0, 1, 0, 1],
    \})
endfunc

func! s:handle_keypress() abort
    if len(g:keypress#history) <= 2
        return
    endif

    for rule in g:bestcommend#rules
        call function(rule)()
    endfor

    call s:create_popup()
endfunc


func! s:rule_no_l() abort
    if g:keypress#history[-2] ==# 'l' && g:keypress#history[-1] ==# 'l'
        let s:messages = [] + s:messages
        call bestcommend#add_message('ll => f{char}')
    endif
endfunc

func! s:rule_no_h() abort
    if g:keypress#history[-2] ==# 'h' && g:keypress#history[-1] ==# 'h'
        call bestcommend#add_message('hh => F{char}')
    endif
endfunc

func! s:rule_no_arrow() abort
    let keymap = {
    \   "\<Up>": 'k',
    \   "\<Right>": 'h',
    \   "\<Down>": 'j',
    \   "\<Left>": 'l',
    \}
    let symbols = {
    \   "\<Up>": '↑',
    \   "\<Right>": '→',
    \   "\<Down>": '↓',
    \   "\<Left>": '←',
    \}
    for k in keys(keymap)
        if g:keypress#history[-2] ==# k && g:keypress#history[-1] ==# k
            call bestcommend#add_message(symbols[k].' => '.keymap[k])
        endif
    endfor
endfunc

func! bestcommend#add_message(msg) abort
    let n = len(s:messages) + 1
    let s:messages = [n.'. '.a:msg] + s:messages
endfunc
