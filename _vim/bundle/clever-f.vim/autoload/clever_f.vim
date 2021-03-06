" keys are mode string returned from mode()
function! clever_f#reset()
    let s:previous_map = {}
    let s:previous_char = {}
    let s:previous_pos = {}
    let s:first_move = {}
    let s:migemo_dicts = {}

    return ""
endfunction

function! clever_f#find_with(map)
    if a:map !~# '^[fFtT]$'
        echoerr 'invalid mapping: ' . a:map
        return
    endif

    let current_pos = getpos('.')[1 : 2]
    let back = 0

    let mode = mode(1)
    if current_pos != get(s:previous_pos, mode, [0, 0])
        if g:clever_f_mark_cursor
            let cursor_marker = matchadd('CleverFCursor', '\%#', 999)
            redraw
        endif
        if g:clever_f_hide_cursor_on_cmdline
            let guicursor_save = &guicursor
            set guicursor=n:block-NONE
            let t_ve_save = &t_ve
            set t_ve=
        endif
        try
            if g:clever_f_show_prompt | echon "clever-f: " | endif
            let s:previous_char[mode] = getchar()
            let s:previous_map[mode] = a:map
            let s:first_move[mode] = 1

            if g:clever_f_show_prompt | redraw! | endif
        finally
            if g:clever_f_mark_cursor | call matchdelete(cursor_marker) | endif
            if g:clever_f_hide_cursor_on_cmdline
                set guicursor&
                let &guicursor = guicursor_save
                let &t_ve = t_ve_save
            endif
        endtry
    else
        " when repeated
        let back = a:map =~# '\u'
    endif

    return clever_f#repeat(back)
endfunction

function! clever_f#repeat(back)
    let mode = mode(1)
    let pmap = get(s:previous_map, mode, "")
    let pchar = get(s:previous_char, mode, 0)

    if pmap ==# ''
        return ''
    endif

    " ignore special characters like \<Left>
    if type(pchar) == type("") && char2nr(pchar) == 128
        return ''
    endif

    if g:clever_f_fix_key_direction ? (! s:first_move[mode] && (pmap =~# '\u' ? !a:back : a:back)) : a:back
        let pmap = s:swapcase(pmap)
    endif

    if mode ==? 'v' || mode ==# "\<C-v>"
        let cmd = s:move_cmd_for_visualmode(pmap, pchar)
    else
        let inclusive = mode ==# 'no' && pmap =~# '\l'
        let cmd = printf("%s:\<C-u>call clever_f#find(%s, %s)\<CR>",
                    \    inclusive ? 'v' : '',
                    \    string(pmap), pchar)
    endif

    return cmd
endfunction

function! clever_f#find(map, char)
    let next_pos = s:next_pos(a:map, a:char, v:count1)
    if next_pos != [0, 0]
        let mode = mode(1)
        let s:previous_pos[mode] = next_pos
        call cursor(next_pos[0], next_pos[1])
    endif
endfunction

function! s:move_cmd_for_visualmode(map, char)
    let next_pos = s:next_pos(a:map, a:char, v:count1)
    if next_pos == [0, 0]
        return ''
    endif

    call setpos("''", [0] + next_pos + [0])
    let mode = mode(1)
    let s:previous_pos[mode] = next_pos

    return "``"
endfunction

function! s:search(pat, flag)
    if g:clever_f_across_no_line
        return search(a:pat, a:flag, line('.'))
    else
        return search(a:pat, a:flag)
    endif
endfunction

function! s:should_use_migemo(char)
    if ! g:clever_f_use_migemo || a:char !~# '^\a$'
        return 0
    endif

    if ! g:clever_f_across_no_line
        return 1
    endif

    return clever_f#helper#include_multibyte_char(getline('.'))
endfunction

function! s:load_migemo_dict()
    let enc = &l:encoding
    if enc ==# 'utf-8'
        return clever_f#migemo#utf8#load_dict()
    elseif enc ==# 'cp932'
        return clever_f#migemo#cp932#load_dict()
    elseif enc ==# 'euc-jp'
        return clever_f#migemo#eucjp#load_dict()
    else
        let g:clever_f_use_migemo = 0
        throw "Error: ".enc." is not supported. Migemo is made disabled."
    endif
endfunction

function! s:generate_pattern(map, char)
    let char = type(a:char) == type(0) ? nr2char(a:char) : a:char
    let regex = char

    let should_use_migemo = s:should_use_migemo(char)
    if should_use_migemo
        if ! has_key(s:migemo_dicts, &l:encoding)
            let s:migemo_dicts[&l:encoding] = s:load_migemo_dict()
        endif
        let regex = s:migemo_dicts[&l:encoding][regex]
    elseif stridx(g:clever_f_chars_match_any_signs, char) != -1
        let regex = '\[!"#$%&''()=~|\-^\\@`[\]{};:+*<>,.?_/]'
    endif

    if a:map ==# 't'
        let regex = '\_.\ze' . regex
    elseif a:map ==# 'T'
        let regex = regex . '\@<=\_.'
    endif

    if ! should_use_migemo
        let regex = '\V'.regex
    endif

    return ((g:clever_f_smart_case && char =~# '\l') || g:clever_f_ignore_case ? '\c' : '\C') . regex
endfunction

function! s:next_pos(map, char, count)
    let mode = mode(1)
    let search_flag = a:map =~# '\l' ? 'W' : 'bW'
    let cnt = a:count
    let s:first_move[mode] = 0
    let pattern = s:generate_pattern(a:map, a:char)

    if get(s:first_move, mode, 1)
        if a:map ==? 't'
            if !s:search(pattern, search_flag . 'c')
                return [0, 0]
            endif
            let cnt -= 1
        endif
    endif

    while 0 < cnt
        if !s:search(pattern, search_flag)
            return [0, 0]
        endif
        let cnt -= 1
    endwhile

    return getpos('.')[1 : 2]
endfunction

function! s:swapcase(char)
    return a:char =~# '\u' ? tolower(a:char) : toupper(a:char)
endfunction

call clever_f#reset()
