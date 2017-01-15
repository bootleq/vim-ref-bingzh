scriptencoding utf-8
let s:save_cpo = &cpo
set cpoptions&vim

if exists('b:current_syntax')
  finish
endif

syntax match RefBingZhH1 /\v%1l/
syntax match RefBingZhPronounce /\v  .*\[.+$/ contained containedin=RefBingZhH1
syntax match RefBingZhError /\vResult not found.+/ contained containedin=RefBingZhH1

syntax match RefBingZhH2 /\v^\k+\s##$/ contains=RefBingZhH2C
syntax match RefBingZhH2C /\v\s##/ conceal contained

syntax region RefBingZhVariants start=_\v^詞型變化 ##_ end=_\n^\S_me=e-1 contains=RefBingZhH2
syntax match RefBingZhVariantType /\v[^a-zA-Z0-9]+：/ contained containedin=RefBingZhVariants

syntax match RefBingZhGrammarType /\v^\s*(n|na|v|v\.aux|vt|vi|adj|adv|advt|abb|conj|prep|pre|pro|web)\./
syntax match RefBingZhRegionType /\v〈\k{1,2}〉/

highlight link RefBingZhPronounce Comment
highlight link RefBingZhH2 Statement
highlight link RefBingZhVariantType Special
highlight link RefBingZhGrammarType Type
highlight link RefBingZhRegionType Comment
highlight link RefBingZhError WarningMsg

let b:current_syntax = 'ref-bingzh'

" Finish:  {{{

let &cpoptions = s:save_cpo
unlet s:save_cpo

" }}} Finish

" modeline {{{
" vim: expandtab softtabstop=2 shiftwidth=2 foldmethod=marker
