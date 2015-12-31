vim-ref-bingzh
==============

Bing dictionary (English/Chinese) source for [vim-ref][].

必应词典 智能手机版：
http://dict.bing.com.cn/?view=touch


Requirements
============

- [vim-ref][] by [thinca][]
- `curl` OR `wget`
- [webapi-vim][] by [mattn][]
- [wwwrenderer-vim][] by [mattn][]
- [OpenCC][] (optional, for 簡繁轉換 only) by [BYVoid][]


Usage Example
=============

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



[thinca]: http://d.hatena.ne.jp/thinca/
[mattn]: http://mattn.kaoriya.net/
[vim-ref]: https://github.com/thinca/vim-ref
[webapi-vim]: https://github.com/mattn/webapi-vim
[wwwrenderer-vim]: https://github.com/mattn/wwwrenderer-vim
[OpenCC]: https://github.com/BYVoid/OpenCC
[BYVoid]: http://www.byvoid.com/
