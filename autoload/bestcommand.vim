let g:bestcommand#max_height = 5
let g:bestcommand#max_width = 30

let s:messages = []
let g:bestcommand#messages = []
let g:bestcommand#rules = [
\       's:rule_no_l',
\       's:rule_no_h',
\       's:rule_no_arrow',
\       's:rule_prefer_A',
\       's:rule_prefer_C_w',
\]

func! bestcommand#start() abort
    augroup bestcommand
        au!
        au User KeyPress call s:handle_keypress()
    augroup END

endfunc

func! s:create_popup() abort
    if exists('s:popup')
            call popup_close(s:popup)
    endif

    if len(s:messages) == 0
        return
    endif

    let s:popup = popup_create(s:messages, {
    \   'line': 'cursor+1',
    \   'col': winwidth(0) - g:bestcommand#max_width,
    \   'maxheight': g:bestcommand#max_height,
    \   'maxwidth': g:bestcommand#max_width,
    \   'padding': [0, 1, 0, 1],
    \})
endfunc

func! s:handle_keypress() abort
    let s:messages = []
    for rule in g:bestcommand#rules
        call function(rule)()
    endfor

    call s:create_popup()
endfunc


func! s:rule_no_l() abort
    if mode() != "n"
        return
    endif

    if len(g:keypress#history) < 3
        return
    endif

    if g:keypress#history[-3:] ==# ['l', 'l', 'l']
        call bestcommand#add_message('lの代わりにf{char}を使えます')
    endif
endfunc

func! s:rule_no_h() abort
    if mode() != "n"
        return
    endif

    if len(g:keypress#history) < 3
        return
    endif

    if g:keypress#history[-3:] ==# ['h', 'h', 'h']
        call bestcommand#add_message('hの代わりにF{char}を使えます')
    endif
endfunc

func! s:rule_no_arrow() abort
    if mode() != "n"
        return
    endif

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
        if keypress#current() ==# k
            call bestcommand#add_message('矢印の代わりに`'.keymap[k].'`を使えます')
        endif
    endfor
endfunc

func! bestcommand#add_message(msg) abort
    let n = len(s:messages) + 1
    let g:bestcommand#messages = [n.'. '.a:msg] + g:bestcommand#messages
    let s:messages = [a:msg] + s:messages
endfunc

func! s:rule_prefer_A() abort
    if mode() != "n"
        return
    endif

    if len(g:keypress#history) < 2
        return
    endif

    if keypress#current() !=# 'a'
        return
    endif

    if g:keypress#history[-2] !=# 'e' && g:keypress#history[-2] !=# 'l'
        return
    endif

    if col(".") ==# col("$") - 1
        call bestcommand#add_message('行末Insertに`A`を使えます')
    endif
endfunc

func! s:rule_prefer_C_w() abort
    if mode() != "i"
        return
    endif

    if len(g:keypress#history) < 3
        return
    endif

    if g:keypress#history[-3:] ==# ["\<BS>", "\<BS>", "\<BS>"]
        call bestcommand#add_message('単語削除に`<C-w>`を使えます')
    endif
endfunc
