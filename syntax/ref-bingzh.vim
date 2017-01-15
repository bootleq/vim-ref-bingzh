scriptencoding utf-8
let s:save_cpo = &cpo
set cpoptions&vim

if exists('b:current_syntax')
  finish
endif

syntax match RefBingZhH2 /\v^\k+\s##$/ contains=RefBingZhH2C
syntax match RefBingZhH2C /\v\s##/ conceal contained
syntax match RefBingZhH3 /\v^[^a-zA-Z0-9]+：/
syntax match RefBingZhH3 /\v反義詞：/

syntax match RefBingZhGrammarType /\v^\s*(n|na|v|v\.aux|vt|vi|adj|adv|advt|abb|conj|prep|pre|pro|web)\./
syntax match RefBingZhRegionType /\v〈\k{1,2}〉/

highlight link RefBingZhH2 Statement
highlight link RefBingZhH3 Special
highlight link RefBingZhGrammarType Type
highlight link RefBingZhRegionType Comment

let b:current_syntax = 'ref-bingzh'

" Finish:  {{{

let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}} Finish

" modeline {{{
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
