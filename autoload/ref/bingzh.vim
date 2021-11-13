scriptencoding utf-8
let s:save_cpo = &cpo
set cpoptions&vim



let s:source = {'name': 'bingzh'}


function! s:source.get_body(query) "{{{
  let query = a:query

  " query，繁體需轉為簡體
  let opencc_config_file = get(g:, 'ref_bingzh_opencc_config')
  if executable('opencc') && !empty(opencc_config_file)
    let query = system(printf(
          \   "echo -n '%s' | opencc%s",
          \   webapi#http#encodeURI(query),
          \   ' --config ' . opencc_config_file
          \ ))
  endif

  let result = ref#bingzh#api#desktop#query(query)

  " 輸出時，簡體轉為繁體
  if executable('opencc')
    let cmd = printf("echo -En '%s' | opencc", substitute(result, "'", '''"''"''', 'g'))
    let result = system(cmd)
  endif

  let result = s:after_formatter(result)

  return result
endfunction "}}}


function! s:source.available() "{{{
  " return exists('*wwwrenderer#render_dom')
  return 1
endfunction "}}}


function! s:source.opened(query)
  setl syntax=ref-bingzh
endfunction


function! s:source.get_keyword() "{{{
  " <cword> CamelCase/under_scored 拆解
  let save_isk = &l:iskeyword
  let &l:iskeyword = '@'
  let word = expand('<cword>')
  let &l:iskeyword = save_isk
  if word =~ '\u\l'
    let pattern = printf('\v%%<%sc\u?\l*%%>%sc',
          \   col('.') + 1,
          \   col('.')
          \ )
    let camel = matchstr(getline('.'), pattern)
    if !empty(camel)
      let word = camel
    endif
  endif
  return word
endfunction "}}}


function! ref#bingzh#define() "{{{
  return copy(s:source)
endfunction "}}}


function! s:after_formatter(text) "{{{
  let text = a:text
  let text = substitute(text, '[^a-zA-Z0-9]\zs,', '，', 'g')
  let text = substitute(text, '[^a-zA-Z0-9]\zs;', '；', 'g')
  let text = substitute(text, '[^a-zA-Z0-9]\zs:', '：', 'g')
  let text = substitute(text, '\v\(((\k|[，；])+)\)', '（\1）', 'g')
  let text = substitute(text, '\v“((\k|[，；])+)\”', '「\1」', 'g')
  return text
endfunction "}}}


" Finish:  {{{

let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}} Finish


" modeline {{{
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
