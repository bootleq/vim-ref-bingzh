" Constants: {{{

let s:SECTIONS = [
      \   {'header':    [['h1']]},
      \   {'pronounce': [['div', {'class': 'hd_p1_1'}], {'inline': 1}]},
      \   {'define':    [['ul']]},
      \   {'variant':   [['div', {'class': 'hd_div1'}]]},
      \   {'synonym':   [['div', {'id': 'synoid'}]]},
      \   {'antonym':   [['div', {'id': 'antoid'}]]},
      \   {'suggest':   [['ul',  {'class': 'dm_ul'}], {'root': 'root'}]}
      \ ]

let s:SECTION_NAMES = {
      \   'variant': '詞型變化',
      \   'synonym': '同義詞',
      \   'antonym': '反義詞',
      \   'suggest': '您找的是'
      \ }

" }}} Constants


function! ref#bingzh#api#desktop#query(query) "{{{
  " Example request: curl "http://cn.bing.com/dict/search?q=demo" -H "Cookie: _EDGE_S=mkt=zh-cn"
  let url     = 'http://cn.bing.com/dict/search?q=' . a:query
  let headers = {'Cookie': '_EDGE_S=mkt=zh-cn'}
  let g:dom   = webapi#html#parse(webapi#http#get(url, {}, headers).content)
  let main    = g:dom.find('div', {'class': 'qdef'})

  let body = []
	for section in s:SECTIONS
    let key    = get(keys(section), 0)
    let title  = get(s:SECTION_NAMES, key, '')
    let val    = get(values(section), 0)
    let finder = get(val, 0, [])
    let option = get(val, 1, {})
    let root   = get(option, 'root', '') == 'root' ? g:dom : main

    let sub_dom = call(g:dom.find, finder, root)

    if !empty(sub_dom)
      if exists('*s:format_function_' . key)
        let text = s:format_function_{key}(key, title, sub_dom, a:query)
      else
        let text = s:format_title(title) . wwwrenderer#render_dom(sub_dom)
      endif

      if !empty(text)
        if get(option, 'inline', 0)
          let body[-1] = body[-1] . text
        else
          call add(body, text) 
        endif
      endif
    endif
  endfor

  return join(body, "\n")
endfunction "}}}



" Format Functions:  {{{

" Header
function! s:format_function_header(key, title, dom, query)
  return s:strip_newline(wwwrenderer#render_dom(a:dom))
endfunction

" 發音
function! s:format_function_pronounce(key, title, dom, query)
  let text = wwwrenderer#render_dom(a:dom)
  let text = s:strip_newline(text)
  " 英 [same] 美 [same]  →  [same]
  let variants = map(split(text, '\V]'), 'substitute(v:val, ".*\[", "", "")')
  if len(uniq(variants)) == 1
    text = variants[0]
  endif
  return '    ' . text
endfunction

" 定義
function! s:format_function_define(key, title, dom, query)
  let text = wwwrenderer#render_dom(a:dom)
  let text = join(map(split(text, "\n"), "s:format_type_then_list(v:val)"), "\n")
  return "\n" . text . "\n\n"
endfunction

" 詞型變化
function! s:format_function_variant(key, title, dom, query)
  let title = s:format_title(a:title)
  let content = wwwrenderer#render_dom(a:dom)
  let content = s:strip_newline(content)
  return title . "\n  " . content . "\n"
endfunction

" 同義詞
function! s:format_function_synonym(key, title, dom, query)
  let title = s:format_title(a:title)
  let content = wwwrenderer#render_dom(a:dom)
  let content = s:strip_newline(content)
  let content = s:flatten_comma_list(content)
  let content = join(map(split(content, "\n"), "s:format_type_then_list(v:val)"), "\n")
  let text = title . "\n" . content . "\n"
  return text
endfunction

" 反義詞
function! s:format_function_antonym(key, title, dom, query)
  let title = s:format_title(a:title)
  let content = wwwrenderer#render_dom(a:dom)
  let content = s:strip_newline(content)
  let content = s:flatten_comma_list(content)
  let content = join(map(split(content, "\n"), "s:format_type_then_list(v:val)"), "\n")
  let text = title . "\n" . content . "\n\n"
  return text
endfunction

" 您找的是
function! s:format_function_suggest(key, title, dom, query)
  let title = s:format_title(a:title)
  let content = wwwrenderer#render_dom(a:dom)
  let content = s:squeeze_newline(content)
  let content = substitute(content, '\v([\n\r\t])', '  ', 'g')
  return title . "\n" . content
endfunction

function! s:format_title(text)
  if empty(a:text)
    return ''
  else
    return printf("%s ##\n", a:text)
  endif
endfunction

function! s:format_type_then_list(text)
  let text = a:text
  let text = substitute(text, '^网络', 'web.', '')
  let text = substitute(text, '\v^\w+\.', '\=printf("%4s ", submatch(0))', '')
  return text
endfunction

function! s:flatten_comma_list(text)
  let text = a:text
  let text = substitute(text, ',\ze\w', '  ', 'g')
  return text
endfunction

function! s:strip_newline(text)
  return substitute(a:text, '\v([\n\r\t])', '', 'g')
endfunction

function! s:squeeze_newline(text)
  return substitute(a:text, '\v([\n\r\t]){2,}', '\n', 'g')
endfunction

" }}} Format Functions
