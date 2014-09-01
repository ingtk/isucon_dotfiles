if exists('s:save_cpo')| finish| endif
let s:save_cpo = &cpo| set cpo&vim
"=============================================================================
let s:CTRLP_BUILTINS = ctrlp#getvar('g:ctrlp_builtins')
"======================================
let s:ctrlp_yankround_var = {'lname': 'yankround', 'sname': 'ynkrd', 'typs': 'tabe', 'sort': 0, 'nolim': 1}
let s:ctrlp_yankround_var.init = 'ctrlp#yankround#init()'
let s:ctrlp_yankround_var.accept = 'ctrlp#yankround#accept'
let g:ctrlp_ext_vars = add(get(g:, 'ctrlp_ext_vars', []), s:ctrlp_yankround_var)
unlet s:ctrlp_yankround_var
let s:index_id = s:CTRLP_BUILTINS + len(g:ctrlp_ext_vars)
function! ctrlp#yankround#id() "{{{
  return s:index_id
endfunction
"}}}
function! ctrlp#yankround#init() "{{{
  return map(copy(g:_yankround_cache), 's:_cache_to_ctrlpline(v:val)')
endfunction
"}}}
function! ctrlp#yankround#accept(action, str) "{{{
  call ctrlp#exit()
  let str = a:str
  let strlist = map(copy(g:_yankround_cache), 's:_cache_to_ctrlpline(v:val)')
  let idx = index(strlist, str)
  if a:action=='t'
    let removed = remove(g:_yankround_cache, idx)
    let @" = @"==#substitute(removed, '^.\d*\t', '', '') ? '' : @"
    call ctrlp#init(ctrlp#yankround#id())
    return
  end
  let [str, regtype] = yankround#_get_cache_and_regtype(idx)
  call setreg('"', str, regtype)
  if a:action!='h'
    exe 'norm! ""'. (col('$')-col('.')<=1 ? 'p': 'P')
  end
endfunction
"}}}
unlet s:CTRLP_BUILTINS

"======================================
function! s:_cache_to_ctrlpline(str) "{{{
  let entry = matchlist(a:str, "^\\(.\\d*\\)\t\\(.*\\)")
  return s:_change_regmodechar(entry[1]). "\t". strtrans(entry[2])
endfunction
"}}}
function! s:_change_regmodechar(char) "{{{
  return a:char==#'v' ? 'c' : a:char==#'V' ? 'l' : a:char
endfunction
"}}}

"=============================================================================
"END "{{{1
let &cpo = s:save_cpo| unlet s:save_cpo
