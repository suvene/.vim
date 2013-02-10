"compiler ruby

" (via)Vimにソースコードの構文エラーを検出させたい（ただしRubyに限る） - idesaku blog
"       http://d.hatena.ne.jp/idesaku/20120104/1325636604
augroup rbsyntaxcheck
  autocmd! BufWritePost <buffer> silent make! -c "%" | redraw!
augroup END
