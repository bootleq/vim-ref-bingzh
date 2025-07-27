vim-ref-bingzh
==============

Bing dictionary (English/Chinese) source for [vim-ref][].

必应字典
https://cn.bing.com/dict/


Requirements
------------

- [vim-ref][] by [thinca][]
- `curl` OR `wget`
- [webapi-vim][] by [mattn][]
- [wwwrenderer-vim][] by [mattn][]
- [OpenCC][] (optional, for 簡繁轉換 only) by [BYVoid][]


Screenshot
----------

![screenshot][]

Show suggestions: (**No longer work, the service has been dropped**)
![snap-suggestion][]


Usage Example
-------------

- Mapping `<Leader>K` to translate current word:

  ```vim
  nnoremap <silent> <Leader>K :call ref#jump('normal', 'bingzh')<CR>
  xnoremap <silent> <Leader>K :call ref#jump('visual', 'bingzh')<CR>
  ```

- *Tranditional Chinese* words must be converted into *Simplified Chinese*
  before feeding to bing dictionary. This requires a setting to tell where the
  [OpenCC][] `t2s.json` config file is:

  ```vim
  let g:ref_bingzh_opencc_config = '/usr/share/opencc/t2s.json'
  ```

- If you installed opencc in default location, just tell which config should
  be enough:

  ```vim
  let g:ref_bingzh_opencc_config = 't2s.json'
  ```



[thinca]: https://d.hatena.ne.jp/thinca/
[mattn]: https://mattn.kaoriya.net/
[vim-ref]: https://github.com/thinca/vim-ref
[webapi-vim]: https://github.com/mattn/webapi-vim
[wwwrenderer-vim]: https://github.com/mattn/wwwrenderer-vim
[OpenCC]: https://github.com/BYVoid/OpenCC
[BYVoid]: https://www.byvoid.com/
[screenshot]: https://raw.githubusercontent.com/bootleq/screenshots/master/vim-ref-bingzh/vim-ref-bingzh.png
[snap-suggestion]: https://raw.githubusercontent.com/bootleq/screenshots/master/vim-ref-bingzh/suggestion.png
