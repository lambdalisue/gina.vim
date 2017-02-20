let s:preferences = {}

function! gina#custom#mapping#preference(scheme, ...) abort
  let readonly = a:0 ? a:1 : 1
  let s:preferences[a:scheme] = get(s:preferences, a:scheme, {})
  let preference = extend(s:preferences[a:scheme], {
        \ 'mappings': [],
        \}, 'keep'
        \)
  return readonly ? deepcopy(preference) : preference
endfunction

function! gina#custom#mapping#map(scheme, lhs, rhs, ...) abort
  let options = get(a:000, 0, {})
  let preference = gina#custom#mapping#preference(a:scheme, 0)
  call add(preference.mappings, [a:lhs, a:rhs, options])
endfunction

function! gina#custom#mapping#nmap(scheme, lhs, rhs, ...) abort
  let options = get(a:000, 0, {})
  let options.mode = 'n'
  call gina#custom#mapping#map(a:scheme, a:lhs, a:rhs, options)
endfunction

function! gina#custom#mapping#vmap(scheme, lhs, rhs, ...) abort
  let options = get(a:000, 0, {})
  let options.mode = 'v'
  call gina#custom#mapping#map(a:scheme, a:lhs, a:rhs, options)
endfunction

function! gina#custom#mapping#imap(scheme, lhs, rhs, ...) abort
  let options = get(a:000, 0, {})
  let options.mode = 'i'
  call gina#custom#mapping#map(a:scheme, a:lhs, a:rhs, options)
endfunction


" Private --------------------------------------------------------------------
function! s:FileType() abort
  let scheme = gina#core#buffer#param('%', 'scheme')
  if empty(scheme)
    return
  endif
  let preference = gina#custom#mapping#preference(scheme)
  for [lhs, rhs, options] in preference.mappings
    call s:map(lhs, rhs, options)
  endfor
endfunction

function! s:map(lhs, rhs, options) abort
  let options = extend({
        \ 'mode': '',
        \ 'noremap': 1,
        \ 'buffer': 1,
        \ 'nowait': 0,
        \ 'silent': 0,
        \ 'special': 0,
        \ 'script': 0,
        \ 'unique': 0,
        \ 'expr': 0,
        \}, a:options
        \)
  let command = join([
        \ options.mode . (options.noremap ? 'noremap' : 'map'),
        \ options.buffer ? '<buffer>' : '',
        \ options.nowait ? '<nowait>' : '',
        \ options.silent ? '<silent>' : '',
        \ options.special ? '<special>' : '',
        \ options.script ? '<script>' : '',
        \ options.unique ? '<unique>' : '',
        \ options.expr ? '<expr>' : '',
        \ a:lhs, a:rhs
        \])
  execute command
endfunction


" Autocmd --------------------------------------------------------------------
augroup gina_custom_mapping_internal
  autocmd! *
  autocmd FileType gina-* call s:FileType()
augroup END