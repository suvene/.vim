"***********************************************************
" gvim 設定
"---------------------------------------
"---------------------------------------
"  初期設定 {{{
"---------------------------------------
" マウスの移動でフォーカスを自動的に切替えない (mousefocus:切替る)
set nomousefocus
" 入力時にマウスポインタを隠す (nomousehide:隠さない)
set mousehide
" ビジュアル選択(D&D他)を自動的にクリップボードへ (:help guioptions_a)
"set guioptions+=a
" メニュー設定
if &guioptions =~# 'M'
    let &guioptions = substitute(&guioptions, '[mT]', '', 'g')
endif
" 印刷用フォント
if has('printer')
    if has('win32')
        set printfont=MS_Mincho:h09:cSHIFTJIS
        "set printfont=MS_Gothic:h12:cSHIFTJIS
    endif
endif

"---------------------------------------
" gvimrc_example.vim  
"---------------------------------------
set ch=2 " Make command line two lines high

set mousehide " Hide the mouse when typing text

" Make shift-insert work like in Xterm
map <S-Insert> <MiddleMouse>
map! <S-Insert> <MiddleMouse>

" Only do this for Vim version 5.0 and later.
if version >= 500

    " I like highlighting strings inside C comments
    let c_comment_strings=1

    " Switch on syntax highlighting if it wasn't on yet.
    if !exists("syntax_on")
        syntax on
    endif

    " Switch on search pattern highlighting.
    set hlsearch

    " For Win32 version, have "K" lookup the keyword in a help file
    "if has("win32")
    "  let winhelpfile='windows.hlp'
    "  map K :execute "!start winhlp32 -k <cword> " . winhelpfile <CR>
    "endif

    " Set nice colors
    " background for normal text is light grey
    " Text below the last line is darker grey
    " Cursor is green, Cyan when ":lmap" mappings are active
    " Constants are not underlined but have a slightly lighter background
    highlight Normal guibg=grey90
    highlight Cursor guibg=Green guifg=NONE
    highlight lCursor guibg=Cyan guifg=NONE
    highlight NonText guibg=grey80
    highlight Constant gui=NONE guibg=grey95
    highlight Special gui=NONE guibg=grey95

endif
"  /gvimrc_example.vim
"---------------------------------------
" }}} /初期設定
"---------------------------------------

"---------------------------------------
" 表示系 {{{
"---------------------------------------
" window幅
set columns=120
set lines=55
set cmdheight=2
" egmrLtT, grL
set guioptions=igrL
" カラースキーマ
colorscheme desert
" フォント設定
if has('win32')
    " Windows用
    set guifont=MS_Gothic:h10:cSHIFTJIS
    " 行間隔の設定
    set linespace=1
    " 一部のUCS文字の幅を自動計測して決める
    if has('kaoriya')
        set ambiwidth=auto
    endif
elseif has('mac')
    set guifont=Osaka－等幅:h14
elseif has('xfontset')
    " UNIX用 (xfontsetを使用)
    set guifontset=a14,r14,k14
endif
" }}} /表示系
"---------------------------------------


"---------------------------------------
" 編集系 {{{
"---------------------------------------
" 日本語入力に関する設定:
if has('multi_byte_ime') || has('xim')
    " IME ON時のカーソルの色を設定(設定例:紫)
    highlight CursorIM guibg=Purple guifg=NONE
    " 挿入モード・検索モードでのデフォルトのIME状態設定
    set iminsert=0 imsearch=0
    if has('xim') && has('GUI_GTK')
        " XIMの入力開始キーを設定:
        " 下記の s-space はShift+Spaceの意味でkinput2+canna用設定
        "set imactivatekey=s-space
    endif
    " 挿入モードでのIME状態を記憶させない場合、次行のコメントを解除
    "inoremap <silent> <ESC> <ESC>:set iminsert=0<CR>
endif

" }}} /編集系
"---------------------------------------

"---------------------------------------
" 動作系 {{{
"---------------------------------------

" }}} /動作系
"---------------------------------------

" vim:set ts=4 sts=4 sw=4 tw=0:

