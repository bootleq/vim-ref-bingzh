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

  if empty(main)
    return s:try_suggestions(g:dom, a:query)
  endif

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


function! s:try_suggestions(dom, query)
  let sections = a:dom.findAll('div', {'class': 'dym_area'})
  if !empty(sections)
    let body = []
    let index = 0
    for sec in sections
      let title = sec.find('div', {'class': 'df_wb_a'})
      let title = substitute(wwwrenderer#render_dom(title), "\n", '', 'g')
      call add(body, s:format_title(title))

      let def_div = sec.find(
            \   'div',
            \   {'class': 'web_div' . (index == 0 ? '' : string(index)) }
            \ )
      if !empty(def_div)
        let items = def_div.findAll('div', {'class': 'df_wb_c'})
        if !empty(items)
          for item in items
            let dt = item.find('a')
            let dt = s:strip_newline(wwwrenderer#render_dom(dt))
            let dd = item.find('div', {'class': 'df_wb_text'})
            let dd = s:strip_newline(wwwrenderer#render_dom(dd))
            let text = dt . ' ~~ ' . dd
            call add(body, text) 
          endfor
        endif
      endif

      call add(body, '') 
      let index += 1
    endfor
    return join(body, "\n")
  else
    return 'Result not found (' . a:query . ')'
  endif
endfunction


" Format Functions:  {{{

" Header
function! s:format_function_header(key, title, dom, query)
  return s:strip_newline(wwwrenderer#render_dom(a:dom))
endfunction

" 發音
function! s:format_function_pronounce(key, title, dom, query)
  let text = wwwrenderer#render_dom(a:dom)
  let text = s:strip_newline(text)
  " show single item if 英／美 identical
  let variants = map(split(text, '\v\] *'), 'substitute(v:val, ".*\[", "", "")')
  if len(uniq(variants)) == 1
    let text = printf('[%s]', variants[0])
  endif
  return repeat(' ', 4) . text
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
  let items = split(content, repeat("\n", 4))
  let items = map(items, 's:strip_newline(v:val)')
  let items = map(items, 's:flatten_comma_list(v:val)')
  let items = map(items, 's:format_type_then_list(v:val)')
  let content = join(items, "\n\n")
  let text = title . "\n" . content . "\n"
  return text
endfunction

" 反義詞
function! s:format_function_antonym(key, title, dom, query)
  return s:format_function_synonym(a:key, a:title, a:dom, a:query)
endfunction

" 您找的是
function! s:format_function_suggest(key, title, dom, query)
  let title = s:format_title(a:title)
  let content = wwwrenderer#render_dom(a:dom)
  let content = s:squeeze_newline(content)
  let content = substitute(content, '\v([\n\r\t])', repeat(' ', 4), 'g')
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
  let text = substitute(text, '\v^\w+\.', '\=printf("%5s ", submatch(0))', '')
  return text
endfunction

function! s:flatten_comma_list(text)
  let text = a:text
  let text = substitute(text, ',\ze\w', repeat(' ', 4), 'g')
  return text
endfunction

function! s:strip_newline(text)
  return substitute(a:text, '\v([\n\r\t])', '', 'g')
endfunction

function! s:squeeze_newline(text)
  return substitute(a:text, '\v([\n\r\t]){2,}', '\n', 'g')
endfunction

" }}} Format Functions
