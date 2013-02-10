"***********************************************************
"let $LANG='ja'
" vim 設定
"   @see http://www15.ocn.ne.jp/~tusr/vim/vim_text2.html
"   @see http://d.hatena.ne.jp/yuroyoro/20101104/1288879591
"---------------------------------------

let mapleader = ","

"---------------------------------------
" 初期設定 {{{
"---------------------------------------
" 日本語設定(encode_japan.vim)
"   - iconv.dll配布サイト (日本語ドキュメント有り)
"       http://www.kaoriya.net/
"   - libiconv開発サイト(Bruno Haible氏)
"       http://sourceforge.net/cvs/?group_id=51585
"       http://ftp.gnu.org/pub/gnu/libiconv/
" 文字コードの自動認識
"   https://gist.github.com/1436273
" 2012/03/16
"   http://www.kawaz.jp/pukiwiki/?vim
set termencoding=utf-8
if &encoding !=# 'utf-8'
  set encoding=japan
  set fileencoding=japan
endif
if has('iconv')
  let s:enc_euc = 'euc-jp'
  let s:enc_jis = 'iso-2022-jp'
  " iconvがeucJP-msに対応しているかをチェック
  if iconv("\x87\x64\x87\x6a", 'cp932', 'eucjp-ms') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'eucjp-ms'
    let s:enc_jis = 'iso-2022-jp-3'
  " iconvがJISX0213に対応しているかをチェック
  elseif iconv("\x87\x64\x87\x6a", 'cp932', 'euc-jisx0213') ==# "\xad\xc5\xad\xcb"
    let s:enc_euc = 'euc-jisx0213'
    let s:enc_jis = 'iso-2022-jp-3'
  endif
  " fileencodingsを構築
  if &encoding ==# 'utf-8'
    let s:fileencodings_default = &fileencodings
    let &fileencodings = s:enc_jis .','. s:enc_euc .',cp932'
    let &fileencodings = &fileencodings .','. s:fileencodings_default
    unlet s:fileencodings_default
  else
    let &fileencodings = &fileencodings .','. s:enc_jis
    set fileencodings+=utf-8,ucs-2le,ucs-2
    if &encoding =~# '^\(euc-jp\|euc-jisx0213\|eucjp-ms\)$'
      set fileencodings+=cp932
      set fileencodings-=euc-jp
      set fileencodings-=euc-jisx0213
      set fileencodings-=eucjp-ms
      let &encoding = s:enc_euc
      let &fileencoding = s:enc_euc
    else
      let &fileencodings = &fileencodings .','. s:enc_euc
    endif
  endif
  " 定数を処分
  unlet s:enc_euc
  unlet s:enc_jis
endif
" 日本語を含まない場合は fileencoding に encoding を使うようにする
if has('autocmd')
  function! AU_ReCheck_FENC()
    if &fileencoding =~# 'iso-2022-jp' && search("[^\x01-\x7e]", 'n') == 0
      let &fileencoding=&encoding
    endif
  endfunction
  autocmd BufReadPost * call AU_ReCheck_FENC()
endif
" 改行コードの自動認識
set fileformats=unix,dos,mac
" □とか○の文字があってもカーソル位置がずれないようにする
if exists('&ambiwidth')
  set ambiwidth=double
endif

" ファイル名に大文字小文字の区別がないシステム用の設定:
"   (例: DOS/Windows/MacOS)
if filereadable($VIM . '/vimrc') && filereadable($VIM . '/ViMrC')
    " tagsファイルの重複防止
    set tags=./tags,tags
endif

" コンソールでのカラー表示のための設定(暫定的にUNIX専用)
" t_Coを指定しているとtmuxでは色が正しくでないのでコメントに
"   via. 時代はGNU screenからtmuxへ - Dマイナー志向
"     http://d.hatena.ne.jp/tmatsuu/20090709/1247150771
" set t_Co=256
"if has('unix') && !has('gui_running') && !has('gui_macvim')
if has('unix') && !has('gui_running')
    let uname = system('uname')
    if uname =~? "linux"
        " set term=builtin_linux
        set term=xterm-256color
    elseif uname =~? "freebsd"
        set term=builtin_cons25
    elseif uname =~? "Darwin"
        " for mac
        "set term=beos-ansi
        "set term=builtin_xterm
        set term=xterm-256color
    else
        set term=builtin_xterm
    endif
    unlet uname

  " via. http://d.hatena.ne.jp/thinca/20101215/1292340358
  " Use meta keys in console.
  function! s:use_meta_keys()  " {{{
    for i in map(
    \   range(char2nr('a'), char2nr('z'))
    \ + range(char2nr('A'), char2nr('Z'))
    \ + range(char2nr('0'), char2nr('9'))
    \ , 'nr2char(v:val)')
      " <ESC>O do not map because used by arrow keys.
      if i != 'O'
        execute 'nmap <ESC>' . i '<M-' . i . '>'
      endif
    endfor
  endfunction  " }}}

  call s:use_meta_keys()
  map <NUL> <C-Space>
  map! <NUL> <C-Space>
endif

" コンソール版で環境変数$DISPLAYが設定されていると起動が遅くなる件へ対応
if !has('gui_running') && has('xterm_clipboard')
    set clipboard=exclude:cons\\\|linux\\\|cygwin\\\|rxvt\\\|screen
endif

" プラットホーム依存の特別な設定
" WinではPATHに$VIMが含まれていないときにexeを見つけ出せないので修正
if has('win32') && $PATH !~? '\(^\|;\)' . escape($VIM, '\\') . '\(;\|$\)'
    let $PATH = $VIM . ';' . $PATH
endif
if has('mac')
    " Macではデフォルトの'iskeyword'がcp932に対応しきれていないので修正
    set iskeyword=@,48-57,_,128-167,224-235
endif

"---------------------------------------
" vimrc_example.vim {{{
"---------------------------------------
" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.
set nocompatible
if has("vms")
    set nobackup      " do not keep a backup file, use versions instead
else
    set backup        " keep a backup file
endif
set history=100     " keep 100 lines of command line history
set ruler       " show the cursor position all the time
set incsearch       " do incremental searching

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

" Don't use Ex mode, use Q for formatting
map Q gq

" In many terminal emulators the mouse works just fine, thus enable it.
set mouse=a

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
    syntax on
    set hlsearch
endif

" Only do this part when compiled with support for autocommands.
if has("autocmd")

    " Enable file type detection.
    " Use the default filetype settings, so that mail gets 'tw' set to 72,
    " 'cindent' is on in C files, etc.
    " Also load indent files, to automatically do language-dependent indenting.
    filetype plugin indent on

    " Put these in an autocmd group, so that we can delete them easily.
    augroup vimrcEx
        au!

        " For all text files set 'textwidth' to 78 characters.
        autocmd FileType text setlocal textwidth=78

        " When editing a file, always jump to the last known cursor position.
        " Don't do it when the position is invalid or when inside an event handler
        " (happens when dropping a file on gvim).
        autocmd BufReadPost *
                    \ if line("'\"") > 0 && line("'\"") <= line("$") |
                    \   exe "normal! g`\"" |
                    \ endif

    augroup END

else

    set autoindent        " always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
command! DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
            \ | wincmd p | diffthis
" }}} /vimrc_example.vim

" }}} /初期設定
"---------------------------------------

"---------------------------------------
" 表示系 {{{
"---------------------------------------
" タイトルを表示
set title
" 行番号を表示
set number
" タブや改行を('listchars' の設定を利用して)表示
set nolist
set listchars=eol:$,trail:c
" 長い行を折り返して表示 (nowrap:折り返さない)
set wrap
" 常にステータス行を表示 (詳細は:he laststatus)
set laststatus=2
" ステータスバーのフォーマット
set statusline=%f%m%=%-25(%l/%L,%c(%P)%)[%{&fileencoding}][%{&fileformat}]%H%W%y
" hlserch の hilight を消す
noremap <Esc><Esc> :nohlsearch<CR><Esc>
" 行末スペースハイライト
" http://d.hatena.ne.jp/kasahi/20070902/1188744907
highlight WhitespaceEOL ctermbg=red guibg=red          
match WhitespaceEOL /\s\+$/
autocmd WinEnter * match WhitespaceEOL /\s\+$/

" from mac {
" カーソル行をハイライト
set cursorline
" カレントウィンドウにのみ罫線を引く
augroup cch
  autocmd! cch
  autocmd WinLeave * set nocursorline
  autocmd WinEnter,BufRead * set cursorline
augroup END
":hi clear CursorLine
":hi CursorLine gui=underline
"highlight CursorLine ctermbg=black guibg=black
" }
" <> をペアに
set matchpairs+=<:>
" }}} /表示系
"---------------------------------------

"---------------------------------------
" 編集系 {{{
"---------------------------------------
set tabstop=2
set shiftwidth=2
" タブをスペースに展開する
set expandtab
" バックスペースでインデントや改行を削除できるようにする
set backspace=2 " indent,eol,start
" テキスト挿入中の自動折り返しを日本語に対応させる
set formatoptions+=mM
" 括弧入力時に対応する括弧を表示 (noshowmatch:表示しない)
set showmatch
" 日本語整形スクリプト(by. 西岡拓洋さん)用の設定
let format_allow_over_tw = 1 " ぶら下り可能幅
" C-a で8進数の計算をしない
set nrformats-=octal
" foldする種類(manual, indent, expr, marker, syntax, diff)
set foldmethod=marker
" Don't write backup file if vim is being called by "crontab -e"
au BufWrite /var/tmp/crontab.* set nowritebackup
" Don't write backup file if vim is being called by "chpass"
au BufWrite /etc/pw.* set nowritebackup

"---------------------------------------------------------------------------
" 日本語入力に関する設定: from mac {
if has('multi_byte_ime') || has('xim') || has('gui_macvim')
  " IME ON時のカーソルの色を設定(設定例:紫)
  hi Cursor guifg=bg guibg=Green gui=NONE
  hi CursorIM guifg=NONE guibg=Purple gui=NONE
  "highlight CursorIM guibg=Purple guifg=NONE
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

""""""""""""""""""""""""""""""
" 挿入モード時、ステータスラインの色を変更
" http://sites.google.com/site/fudist/Home/vim-nihongo-ban/vim-color#color-ime
""""""""""""""""""""""""""""""
let g:hi_insert ='highlight StatusLine guifg=white guibg=blue gui=none ctermfg=black ctermbg=blue cterm=none'
if has('syntax')
  augroup InsertHook
    autocmd!
    autocmd InsertEnter * call s:StatusLine('Enter')
    autocmd InsertLeave * call s:StatusLine('Leave')
  augroup END
endif
let s:slhlcmd =''
function! s:StatusLine(mode)
  if a:mode=='Enter'
    silent! let s:slhlcmd ='highlight '. s:GetHighlight('StatusLine')
    silent exec g:hi_insert
  else
    highlight clear StatusLine
    silent exec s:slhlcmd
  endif
endfunction
function! s:GetHighlight(hi)
  redir=> hl
  exec'highlight '.a:hi
  redir END
  let hl = substitute(hl, '[\r\n]', '', 'g')
  let hl = substitute(hl, 'xxx', '', '')
  return hl
endfunction

"if has('unix') && !has('gui_running')
"  " ESC後にすぐ反映されない対策
"  inoremap <silent> <ESC> <ESC>
"endif
" }
" }}} /編集系
"---------------------------------------

"---------------------------------------
" 検索系 {{{
"---------------------------------------
" 検索時に大文字小文字を無視 (noignorecase:無視しない)
set ignorecase

" 大文字小文字の両方が含まれている場合は大文字小文字を区別
set smartcase

" 検索時にファイルの最後まで行ったら最初に戻る (nowrapscan:戻らない)
set wrapscan

" from mac {
" Ctrl-h でヘルプ " window の移動とバッティングするのでマップ変更
nnoremap <Leader>h :<C-u>help<Space> 
" カーソル下のキーワードをヘルプでひく
 nnoremap <Leader>hh :<C-u>help<Space><C-r><C-w><Enter>
" }
" }}} /検索系
"---------------------------------------

"---------------------------------------
" 動作系 {{{
"---------------------------------------
set visualbell
" 選択した文字をクリップボードに入れる
set clipboard=unnamed
" 保存していなくても別のファイルを表示できるようにする
set hidden
" コマンドライン補完するときに('wildchar'で指定されたものを利用して)強化されたものを使う(参照 :help wildmenu)
set wildmenu
" backupを1箇所に
set backupdir=$HOME/backup/vim
" swap
let &directory = &backupdir
" ファイル名だけで開けるようにするパス
"let &path += "/etc,/var/log,/var/log/httpd"

" Exploler設定
" パラメータ無しで開くディレクトリ
"set browsedir=last    " 前回にファイルブラウザを使ったディレクト
set browsedir=buffer " バッファで開いているファイルのディレクトリ
"set browsedir=current   " カレントディレクトリ
"set browsedir={&path}   " {path} で指定されたディレクトリ
" 開いているファイルをカレントディレクトリにする
" 編集中のファイルに移動するには :cd %:h
if has("autcmd")
  au BufEnter * execute ":lcd " . expand("%:p:h")
endif
" from mac {
" set filetype
autocmd FileType yaml set expandtab ts=2 sw=2 enc=utf-8 fenc=utf-8
autocmd FileType ruby set expandtab ts=2 sw=2 enc=utf-8 fenc=utf-8
autocmd FileType erb set expandtab ts=2 sw=2 enc=utf-8 fenc=utf-8
autocmd BufNewFile,BufRead svk-commit*.tmp set enc=utf-8 fenc=utf-8 ft=svk
autocmd BufNewFile,BufRead COMMIT_EDITMSG set enc=utf-8 fenc=utf-8 ft=gitcommit
" }
" }}} /動作系
"---------------------------------------

"---------------------------------------
" keymaps {{{
"---------------------------------------
" ; ; 入れ替え {
noremap ; :
noremap : ;
" }

" @see http://www15.ocn.ne.jp/~tusr/vim/vim_text2.html#mozTocId672287
" マーク位置へのジャンプを行だけでなく桁位置も復元できるようにする
map ' `
" Ctrl+Nで次のバッファを表示
noremap <silent> <C-N> :bnext<CR>
" Ctrl+Pで前のバッファを表示
noremap <silent> <C-P> :bprevious<CR>
" from mac {
" Ctrl+Shift+Jで上に表示しているウィンドウをスクロールさせる
"nnoremap <C-S-J> <C-W>k<C-E><C-W><C-W>
"nnoremap <C-S-K> <C-W>k<C-Y><C-W><C-W>
"
" j/k
nmap j gj
nmap k gk

" J/K で半画面移動
nmap J <C-d>
nmap K <C-u>
" }
" 挿入モードでCtrl+kを押すとクリップボードの内容を貼り付けられるようにする
imap <C-K> <ESC>"*pa
" Rubyのオムニ補完を設定(ft-ruby-omni)"
imap <C-Space> <C-x><C-o>
let g:rubycomplete_buffer_loading = 1
let g:rubycomplete_classes_in_global = 1
let g:rubycomplete_rails = 1

" Ctrl+Shift+Jで上に表示しているウィンドウをスクロールさせる
nnoremap <C-S-J> <C-W>k<C-E><C-W><C-W>

" command line
cnoremap <C-b> <Left>
cnoremap <C-f> <Right>
cnoremap <C-p> <Up>
cnoremap <C-n> <Down>
cnoremap <C-a> <Home>
cnoremap <C-e> <End>
cnoremap <C-d> <Del>
cnoremap <C-M-b> <S-Left>
cnoremap <C-M-f> <S-Right>

" text-objects
" vbで{}の選択
nnoremap vb ?{<CR>%v%0

" .vimrc を最速で！
nnoremap <silent> <Space>ev  :<C-u>edit $MYVIMRC<CR>
nnoremap <silent> <Space>eg  :<C-u>edit $MYGVIMRC<CR>
" Load .gvimrc after .vimrc edited at GVim.
nnoremap <Space>rv :<C-u>source $MYVIMRC \| if has('gui_running') \| source $MYGVIMRC \| endif <CR>
nnoremap <Space>rg :<C-u>source $MYGVIMRC<CR>
" Set augroup.
augroup MyAutoCmd
    autocmd!
augroup END
if !has('gui_running') && !(has('win32') || has('win64'))
    " .vimrcの再読込時にも色が変化するようにする
    autocmd MyAutoCmd BufWritePost $MYVIMRC nested source $MYVIMRC
else
    " .vimrcの再読込時にも色が変化するようにする
    autocmd MyAutoCmd BufWritePost $MYVIMRC source $MYVIMRC |
                \if has('gui_running') | source $MYGVIMRC
    autocmd MyAutoCmd BufWritePost $MYGVIMRC if has('gui_running') | source $MYGVIMRC
endif

nnoremap <Space>gn :<C-u>w<CR>:Git now<CR>
nnoremap <Space>gN :<C-u>w<CR>:Git now --all<CR>

" for quickfix
" via. Vim: quickfix用key mappings - while ("im automaton"); http://whileimautomaton.net/2007/02/16165600
nnoremap Q q

nnoremap qj  :cnext<Return>
nnoremap qk  :cprevious<Return>
nnoremap qr  :crewind<Return>
nnoremap qK  :cfirst<Return>
nnoremap qJ  :clast<Return>
nnoremap qf  :cnfile<Return>
nnoremap qF  :cpfile<Return>
nnoremap ql  :clist<Return>
nnoremap qq  :cc<Return>
nnoremap qo  :copen<Return>
nnoremap qc  :cclose<Return>
nnoremap qw  :cwindow<Return>
nnoremap qp  :colder<Return>
nnoremap qn  :cnewer<Return>
nnoremap qm  :make<Return>
nnoremap qM  :make<Space>
nnoremap qg  :grep<Space>
nnoremap qr  :cexpr ""<Return>
nnoremap q   <Nop>
" keymaps }}}
"--------------------------------------

" from mac {
"---------------------------------------
" for plugins {{{
"---------------------------------------
" NeoBundle {{{
" https://github.com/gmarik/vundle/
" http://vim-users.jp/2011/10/hack238/
"   https://github.com/Shougo/neobundle.vim
set nocompatible               " be iMproved
filetype plugin indent off     " required!

if has('vim_starting')
  if !exists("loaded") | set runtimepath+=~/.vim/bundle/neobundle.vim/ | endif
  call neobundle#rc(expand('~/.vim/bundle'))
endif
" let NeoBundle manage NeoBundle
" required!
NeoBundle 'Shougo/neobundle.vim'
" recommended to install
NeoBundle 'Shougo/vimproc'
" after install, turn shell ~/.vim/bundle/vimproc, (n,g)make -f your_machines_makefile
NeoBundle 'Shougo/vimshell'
NeoBundle 'Shougo/unite.vim'
" BundleSearch 用に
NeoBundle 'gmarik/vundle'
if !exists("loaded") | set runtimepath+=~/.vim/bundle/vundle.git/ | endif
call vundle#rc()

" My Bundles here:
"
"" original repos on github
" NeoBundle 'tpope/vim-fugitive'
" NeoBundle 'Lokaltog/vim-easymotion'
" NeoBundle 'rstacruz/sparkup', {'rtp': 'vim/'}
"" vim-scripts repos
" NeoBundle 'L9'
" NeoBundle 'FuzzyFinder'
"" non github repos
" NeoBundle 'git://git.wincent.com/command-t.git'
"" non git repos
" NeoBundle 'http://svn.macports.org/repository/macports/contrib/mpvim/'
" NeoBundle 'https://bitbucket.org/ns9tks/vim-fuzzyfinder'

"" doc !
NeoBundle 'vim-jp/vimdoc-ja'
NeoBundle 'thinca/vim-ref'

"" helper
NeoBundle 'thinca/vim-quickrun'

"" window, buf, file
NeoBundle 'fholgado/minibufexpl.vim'
NeoBundle 'scrooloose/nerdtree'
" NeoBundle 'ornicar/vim-mru' uniteあるからいらない
NeoBundle 'BufOnly.vim'

"" view
" 画面がうるさいのでコメントアウト
" NeoBundle 'vim-scripts/Changed'

"" search
NeoBundle 'grep.vim'
NeoBundle 'othree/eregex.vim'
NeoBundle 'matchit.zip'

"" Edit
NeoBundle 'Shougo/neocomplcache'
NeoBundle 'kana/vim-surround'
NeoBundle 'mattn/zencoding-vim'
NeoBundle 'scrooloose/nerdcommenter.git'
NeoBundle 'autodate.vim'
NeoBundle 'YankRing.vim'

"" Git/Gist
NeoBundle 'mattn/gist-vim'
NeoBundle 'motemen/git-vim'

"" ruby, rails
NeoBundle 'ruby.vim'
NeoBundle 'vim-ruby/vim-ruby'
NeoBundle 'tpope/vim-rails' " rails.vim

"" misc
NeoBundle 'vim-scripts/VimRepress'
NeoBundle 'sudo.vim'
NeoBundle 'mattn/webapi-vim'

filetype plugin indent on     " required!
" }}}

" pathogen.vim http://d.hatena.ne.jp/yuroyoro/20101104/1288879591 {{{
"  http://www.vim.org/scripts/script.php?script_id=2332
"  https://github.com/tpope/vim-pathogen
" pathogenでftdetectなどをloadさせるために一度ファイルタイプ判定をoff
"filetype off
" pathogen.vimによってbundle配下のpluginをpathに加える
"call pathogen#runtime_append_all_bundles()
"call pathogen#helptags()
"set helpfile=$VIMRUNTIME/doc/help.txt
" ファイルタイプ判定をon
"filetype on
"}}}

" autodate.vim"{{{
 let g:autodate_format = '%Y/%m/%d %H:%M:%S'
"}}}

" minibufexpl.vim"{{{
"   http://www.vim.org/scripts/script.php?script_id=159
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1
let g:miniBufExplMapCTabSwitchBuffs = 1
noremap [minibuf] <Nop>
nmap <C-W> [minibuf]
nnoremap [minibuf]<Space> :MBEbn<CR>
nnoremap [minibuf]n       :MBEbn<CR>
nnoremap [minibuf]<C-n>   :MBEbn<CR>
nnoremap [minibuf]p       :MBEbp<CR>
nnoremap [minibuf]<C-p>   :MBEbp<CR>
nnoremap [minibuf]c       :new<CR>
nnoremap [minibuf]<C-c>   :new<CR>
nnoremap [minibuf]k       :bd<CR>
nnoremap [minibuf]<C-k>   :bd<CR>
nnoremap [minibuf]s       :IncBufSwitch<CR>
nnoremap [minibuf]<C-s>   :IncBufSwitch<CR>
nnoremap [minibuf]<Tab>   :wincmd w<CR>
nnoremap [minibuf]o       :only<CR>
nnoremap [minibuf]w       :ls<CR>
nnoremap [minibuf]<C-w>   :ls<CR>
nnoremap [minibuf]a       :e #<CR>
nnoremap [minibuf]<C-a>   :e #<CR>
nnoremap [minibuf]"       :BufExp<CR>
nnoremap [minibuf]1   :e #1<CR>
nnoremap [minibuf]2   :e #2<CR>
nnoremap [minibuf]3   :e #3<CR>
nnoremap [minibuf]4   :e #4<CR>
nnoremap [minibuf]5   :e #5<CR>
nnoremap [minibuf]6   :e #6<CR>
nnoremap [minibuf]7   :e #7<CR>
nnoremap [minibuf]8   :e #8<CR>
nnoremap [minibuf]9   :e #9<CR>
"}}}

" surround.vim via. http://d.hatena.ne.jp/secondlife/20061225/1167032528"{{{
"   http://www.vim.org/scripts/script.php?script_id=1697
" via. http://webtech-walker.com/archive/2009/02/08031540.html
" [key map]
" 1 : <h1>|</h1>
" 2 : <h2>|</h2>
" 3 : <h3>|</h3>
" 4 : <h4>|</h4>
" 5 : <h5>|</h5>
" 6 : <h6>|</h6>
"
" p : <p>|</p>
" u : <ul>|</ul>
" o : <ol>|</ol>
" l : <li>|</li>
" a : <a href="">|</a>
" A : <a href="|"></a>
" i : <img src="|" alt="" />
" I : <img src="" alt"|" />
" d : <div>|</div>
" D : <div class="section">|</div>

"autocmd FileType html let b:surround_49  = "<h1>\r</h1>"
" autocmd FileType html call SurroundRegister('g', 'b', "<b>\r</b>")
" autocmd FileType html call SurroundRegister('g', '4', "<h4>\r</h4>")
" autocmd FileType html call SurroundRegister('g', '3', "<h3>\r</h3>")

" http://vim-users.jp/2009/11/hack105/
autocmd BufNewFile,BufRead * call SurroundRegister('g', '4', "<h4>\r</h4>")
autocmd BufNewFile,BufRead * call SurroundRegister('g', '3', "<h3>\r</h3>")
autocmd BufNewFile,BufRead * call SurroundRegister('g', 'jk', "「\r」")
autocmd BufNewFile,BufRead * call SurroundRegister('g', 'jK', "『\r』")
autocmd BufNewFile,BufRead * call SurroundRegister('g', 'js', "【\r】")
"}}}

" keisen.vim"{{{
"   http://www.vector.co.jp/soft/unix/writing/se266948.html
" 半角/全角の罫線を描く Vim スクリプトです。
" :Keisen で起動すれば、半角文字(+,－,|)です( 設定変更可 )。
" :Keisen -z で起動すれば全角文字です。
" :Keisen -Z で起動すれば太字です。
" hjkl キーで、罫線が描けるようになります。
" <Space> キーを押すと消去モードになります。
" <ESC> でキーマップが標準に戻ります。
" 詳しくは、:Keisen --help してください。
"}}}

" commentout.vim http://nanasi.jp/articles/vim/commentout_source.html"{{{
"}}}

" eregex.vim via. http://d.hatena.ne.jp/secondlife/20060203/1138978661"{{{
"   http://www.vector.co.jp/soft/unix/writing/se265654.html
"   http://www.vim.org/scripts/script.php?script_id=3282
"   http://github.com/othree/eregex.vim
if (has('gui_running'))
noremap / :M/
noremap ,/ /
else
noremap / :M/
noremap ,/ :/
endif
"}}}

" grep.vim via. http://d.hatena.ne.jp/secondlife/20060203/1138978661"{{{
"   http://blog.blueblack.net/item_199
"   http://www.vim.org/scripts/script.php?script_id=311
" let Grep_Path = 'C:\GnuWin32\bin\grep.exe'
" let Fgrep_Path = 'C:\GnuWin32\bin\grep.exe -F'
" let Egrep_Path = 'C:\GnuWin32\bin\grep.exe -E'
" let Grep_Find_Path = 'C:\GnuWin32\bin\find.exe'
" let Grep_Xargs_Path = 'C:\GnuWin32\bin\xargs.exe'
" let Grep_Shell_Quote_Char = '"'
let Grep_Shell_Quote_Char = '"'
let Grep_Skip_Dirs = '.svn .git'
let Grep_Skip_Files = '*.bak *~'

" http://d.hatena.ne.jp/yuroyoro/20101104/1288879591#c
" :Gb <args> でGrepBufferする
command! -nargs=1 Gb :GrepBuffer <args>
" " カーソル下の単語をGrepBufferする
nnoremap <C-g><C-b> :<C-u>GrepBuffer<Space><C-r><C-w><Enter>
"}}}

" mru.vim via. http://d.hatena.ne.jp/secondlife/20060203/1138978661"{{{
"   http://nanasi.jp/articles/vim/mru_vim.html
"   http://www.vim.org/scripts/script.php?script_id=521
"   https://github.com/ornicar/vim-mru
"let g:MRU_Max_Entries=50 " default 10
"let g:MRU_Exclude_Files="^/tmp/.*\|^/var/tmp/.*"
"let g:MRU_Window_Height=15 " default 8
"let g:MRU_Use_Current_Window=0
"let g:MRU_Auto_Close=1
"noremap <C-@> :MRU<CR>
"}}}

" blockdiff.vim http://nanasi.jp/articles/vim/blockdiff_vim.html"{{{
"   http://www.vim.org/scripts/script.php?script_id=2048
"}}}

" vimshell"{{{
"   https://github.com/Shougo/vimshell
" vimproc
"   https://github.com/Shougo/vimproc
"}}}

" migemo {{{
if has('migemo')
set migemodict=$VIMRUNTIME/dict/migemo-dict
set migemo
endif
"}}}

" Unite {{{
let g:unite_enable_start_insert = 1
let g:unite_source_file_mru_limit=100
let g:unite_source_file_mru_time_format = ''
let g:unite_source_file_mru_ignore_pattern='.*\/$\|.*Application\ Data.*'
noremap [unite] <Nop>
nmap <space> [unite]
nnoremap <silent> [unite]f :<C-u>UniteWithBufferDir -buffer-name=file file<CR>
nnoremap <silent> [unite]b :<C-u>Unite -buffer-name=file buffer<CR>
nnoremap <silent> [unite]m :<C-u>Unite -buffer-name=file file_mru bookmark file buffer<CR>
nnoremap <silent> [unite]r :<C-u>Unite -buffer-name=register register<CR>
nnoremap <silent> [unite]c :<C-u>Unite -buffer-name=bookmark bookmark<CR>
nnoremap <silent> [unite]a :<C-u>UniteBookmarkAdd<CR>

au FileType unite imap <buffer> jj <Plug>(unite_insert_leave)
" ウィンドウを分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-h> unite#do_action('split')
au FileType unite inoremap <silent> <buffer> <expr> <C-h> unite#do_action('split')
" ウィンドウを縦に分割して開く
au FileType unite nnoremap <silent> <buffer> <expr> <C-v> unite#do_action('vsplit')
au FileType unite inoremap <silent> <buffer> <expr> <C-v> unite#do_action('vsplit')
" ESCキーを2回押すと終了する
au FileType unite nnoremap <silent> <buffer> <ESC><ESC> :q<CR>
au FileType unite inoremap <silent> <buffer> <ESC><ESC> <ESC>:q<CR>
" c-g でも終了
au FileType unite nnoremap <silent> <buffer> <C-g> :q<CR>
au FileType unite inoremap <silent> <buffer> <C-g> <ESC>:q<CR>
" via. http://d.hatena.ne.jp/thinca/20101027/1288190498
call unite#set_substitute_pattern('file', '\$\w\+', '\=eval(submatch(0))', 200)

call unite#set_substitute_pattern('file', '[^~.]\zs/', '*/*', 20)
call unite#set_substitute_pattern('file', '/\ze[^*]', '/*', 10)

call unite#set_substitute_pattern('file', '^@@', '\=fnamemodify(expand("#"), ":p:h")."/*"', 2)
call unite#set_substitute_pattern('file', '^@', '\=getcwd()."/*"', 1)
call unite#set_substitute_pattern('file', '^\\', '~/*')

call unite#set_substitute_pattern('file', '^;v', '~/.vim/*')
call unite#set_substitute_pattern('file', '^;r', '\=$VIMRUNTIME."/*"')
if has('win32') || has('win64')
  call unite#set_substitute_pattern('file', '^;p', 'C:/Program Files/*')
endif

call unite#set_substitute_pattern('file', '\*\*\+', '*', -1)
call unite#set_substitute_pattern('file', '^\~', escape($HOME, '\'), -2)
call unite#set_substitute_pattern('file', '\\\@<! ', '\\ ', -20)
call unite#set_substitute_pattern('file', '\\ \@!', '/', -30)
" }}}

" VimRepress {{{
let VIMPRESS = [{'username' : 'suVene', 'blog_url' : 'http://d.zeromemory.info/xmlrpc.php' }]
" }}}

" NERTTreeToggle {{{
nnoremap <Leader>n :NERDTreeToggle<CR>
" }}}

" neocomplcache {{{
let g:neocomplcache_enable_at_startup = 1
let g:neocomplcache_enable_smart_case = 1
let g:neocomplcache_enable_underbar_completion = 1
let g:neocomplcache_min_syntax_length = 3
let g:neocomplcache_lock_buffer_name_pattern = '*ku*'
" let g:neocomplcache_enable_auto_select = 1 " 1番目の候補を自動選択
" Define dictionary.
let g:neocomplcache_dictionary_filetype_lists = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
    \ }
if !exists('g:neocomplcache_omni_patterns')
  let g:neocomplcache_omni_patterns = {}
endif
let g:neocomplcache_omni_patterns.cpp = '\h\w*\%(\.\|->\)\h\w*\|\h\w*::'
let g:neocomplcache_omni_patterns.ruby = '[^. *\t]\.\h\w*\|\h\w*::'
" Define keyword.
if !exists('g:neocomplcache_keyword_patterns')
  let g:neocomplcache_keyword_patterns = {}
endif
let g:neocomplcache_keyword_patterns['default'] = '\h\w*'
nnoremap  <Space>d. :<C-u>NeoComplCacheCachingDictionary<Enter> " 辞書読み込み
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>" " <TAB> completion.
inoremap <expr><C-j> &filetype == 'vim' ? "\<C-x>\<C-v>\<C-p>" : "\<C-x>\<C-o>\<C-p>" " C-jでオムニ補完
inoremap <expr><C-n>  pumvisible() ? "\<C-n>" : "\<C-x>\<C-u>\<C-p>" " C-nでneocomplcache補完
inoremap <expr><C-p> pumvisible() ? "\<C-p>" : "\<C-p>\<C-n>" " C-pでkeyword補完
" 補完候補が表示されている場合は確定。そうでない場合は改行
inoremap <expr><CR>  pumvisible() ? neocomplcache#close_popup() : "<CR>"
inoremap <expr><C-e>  neocomplcache#cancel_popup()
inoremap <expr><C-g>  neocomplcache#close_popup()
" }}}

" ref.vim {{{
let g:ref_use_vimproc = 1 "
nnorema <Leader>hr :<C-u>Ref refe<Space><C-r><C-w><Enter>
" }}}

" rails.vim {{{
let g:rails_level=4
" }}}

" YankRing {{{
set viminfo+=!
if has('mac')
  let g:yankring_replace_n_pkey='<M-p>'
  let g:yankring_replace_n_nkey='<M-n>'
else
  let g:yankring_replace_n_pkey='<A-p>'
  let g:yankring_replace_n_nkey='<A-n>'
endif
" }}}
" for plugins }}}
"---------------------------------------
" }

"---------------------------------------
" autocmd {{{
"---------------------------------------
augroup quickfixopen
  autocmd!
  autocmd QuickfixCmdPost make,grep,vimgrep,grepadd cw
augroup END
" autocmd }}}
"--------------------------------------


let loaded=1
" vim:set ts=4 sts=4 sw=4 tw=0 et:

