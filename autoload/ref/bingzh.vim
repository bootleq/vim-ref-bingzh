scriptencoding utf-8
let s:save_cpo = &cpo
set cpoptions&vim



let s:source = {'name': 'bingzh'}


function! s:source.get_body(query) "{{{
  let view = 'touch'
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

  let url = 'http://dict.bing.com.cn/?q='
        \ . query
        \ . (empty(view) ? '' : printf("&view=%s", view))
  let g:dom = webapi#html#parseURL(url)

  let sections = [
        \   {'proSymbols': '發音'},
        \   {'crossDef': '定義'},
        \   {'smtArea': '計算機翻譯'},
        \   {'senArea': '例句用法'},
        \   {'inflArea': '詞型變化'},
        \   {'thesArea': '同義詞'},
        \   {'dymArea': '您找的是'},
        \ ]

  let body = []
  for section in sections
    let key = get(keys(section), 0)
    let title = get(values(section), 0)
    let section_dom = g:dom.find(['div', {'id': key}])
    if !empty(section_dom)
      if exists('*s:format_function_' . key)
        let text = s:format_function_{key}(key, title, section_dom, a:query)
      else
        let text = s:format_title(title) . wwwrenderer#render_dom(section_dom)
      endif
      call add(body, text)
    endif
  endfor

  let result = join(body, "\n")

  " 輸出時，簡體轉為繁體
  if executable('opencc')
    let cmd = printf("echo -n '%s' | opencc", substitute(result, "'", "''", 'g'))
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


" Format Functions:  {{{

" 發音
function! s:format_function_proSymbols(key, title, dom, query)
  let text = a:query . "  "
  let text .= wwwrenderer#render_dom(a:dom)
  return text
endfunction

" 定義
function! s:format_function_crossDef(key, title, dom, query)
  let text = wwwrenderer#render_dom(a:dom)
  let text = substitute(text, '\v([\n\r\t]){2,}', '\n', 'g')
  let text = join(map(split(text, "\n"), "s:format_function_crossDef_to_list(v:val)"), "\n")
  return text . "\n\n"
endfunction

" 例句用法
function! s:format_function_senArea(key, title, dom, query)
  let title = s:format_title(a:title)
  let content = wwwrenderer#render_dom(a:dom)
  let content = substitute(content, '\v\nhttp://.+(\.\.\.)\n', '\n', 'g')
  let content = substitute(content, '\v\n\ze.', '\n  ', 'g')
  return title . content . "\n"
endfunction

" 詞型變化
function! s:format_function_inflArea(key, title, dom, query)
  let title = s:format_title(a:title)
  let content = wwwrenderer#render_dom(a:dom)
  let content = substitute(content, '\v([\n\r\t]){2,}', '\n', 'g')
  let content = substitute(content, '\v\n\ze', '\n  ', 'g')
  return title . content . "\n"
endfunction

" 同義詞
function! s:format_function_thesArea(key, title, dom, query)
  let title = s:format_title(a:title)
  let content = wwwrenderer#render_dom(a:dom)
  let content = s:words_inline(content)
  let content = substitute(content, '\v\n\ze', '\n  ', 'g')
  let text = title . content . "\n\n"
  return text
endfunction

" 您找的是
function! s:format_function_dymArea(key, title, dom, query)
  let title = s:format_title(a:title)
  let content = wwwrenderer#render_dom(a:dom)
  let content = s:words_inline(content)
  let content = substitute(content, '\v^\ze', '  ', 'g')
  return title . "\n" . content
endfunction

function! s:format_title(text)
  return printf("%s ##\n", a:text)
endfunction

function! s:format_function_crossDef_to_list(text)
  let text = a:text
  if text =~ '\v\w+\.'
    let text = printf("\n%s", text)
  else
    let text = printf("- %s", text)
  endif
  return text
endfunction

function! s:words_inline(text)
  let text = a:text
  let text = join(map(split(text), "s:outline_item(v:val)"), '  ')
  return text
endfunction

function! s:outline_item(text)
  let text = a:text
  if text =~ '\v\w+\.'
    let text = printf("\n%s", text)
  endif
  return text
endfunction


function! s:after_formatter(text) "{{{
  let text = a:text
  let text = substitute(text, '[^a-zA-Z0-9]\zs,', '，', 'g')
  let text = substitute(text, '[^a-zA-Z0-9]\zs;', '；', 'g')
  let text = substitute(text, '[^a-zA-Z0-9]\zs:', '：', 'g')
  let text = substitute(text, '\v\(((\k|[，；])+)\)', '（\1）', 'g')
  let text = substitute(text, '\v“((\k|[，；])+)\”', '「\1」', 'g')
  return text
endfunction "}}}

" }}} Format Functions


" Finish:  {{{

let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}} Finish


" modeline {{{
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
