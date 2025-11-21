
" === Basics === 

set nocompatible
set number
set relativenumber
set termguicolors
set background=dark
colorscheme zaibatsu
syntax on

filetype plugin indent on

set tabstop=4
set shiftwidth=4
set softtabstop=4
set expandtab

set path+=**

" trigger eater
func! Eatchar(pat)
   let c = nr2char(getchar(0))
   return (c =~ a:pat) ? '' : c
endfunc

" === Cover Filetype ===

augroup MyFiletypeSettings
    autocmd!
   
    " C
    autocmd FileType c,h setlocal tabstop=8 shiftwidth=8 softtabstop=8 noexpandtab

    " Makefile
    autocmd FileType make setlocal tabstop=4 shiftwidth=4 softtabstop=4 noexpandtab

augroup END

" === Format ===

command! Format execute 'silent keepjumps keepmarks %!clang-format -assume-filename=' . expand('%:p')

" === Commenting Standards === 

" 1. comment header 1: module header
command! -nargs=+ Ch1 call append(line('.'), [
    \ '/*',
    \ ' * ==========================================================================',
    \ ' * ' . <q-args>,
    \ ' * ==========================================================================',
    \ ' */'
    \ ]) | execute 'normal! 5jo'

" 2. comment header 2: section header
command! -nargs=+ Ch2 call append(line('.'), [
    \ '/*',
    \ ' * --------------------------------------------------------------------------',
    \ ' * ' . <q-args>,
    \ ' * --------------------------------------------------------------------------',
    \ ' */'
    \ ]) | execute 'normal! 5jo'

" 3. comment split 1 (/// === Title ===)
command! -nargs=+ Cs1 call append(line('.'), '/// === ' . <q-args> . ' ===') | execute 'normal! jo'

" 4. comment split 2 (/// --- Title ---)
command! -nargs=+ Cs2 call append(line('.'), '/// --- ' . <q-args> . ' ---') | execute 'normal! jo'

" 5. split line 
command! Cline call append(line('.'), '/* ------------------------------------------------------------------------- */') | execute 'normal! jo'

" high light
autocmd Syntax c syntax match cCustomTitle "/// ===.*" containedin=cComment,cCppComment
autocmd Syntax c highlight link cCustomTitle todo

" === ClipBoard ===

" copy to clipboard
command! -range=% Xc <line1>,<line2>w !xclip -selection clipboard

" copy to primary
command! -range=% Xp <line1>,<line2>w !xclip -selection primary

" === Project Mental Map System ===

function! GenerateProjectTree()
    let l:visual_cmd = "tree -n --dirsfirst --gitignore --noreport"
    
    " B. 给机器读的 (.treefile):
    " -f: 必须全路径 (为了跳转)
    " -i: 拍扁结构
    " 参数必须包含上面的排序参数 (--dirsfirst) 以保证行号对齐
    let l:index_cmd  = "tree -f -n -i --dirsfirst --gitignore --noreport"
    
    " 执行生成
    call system(l:visual_cmd . " > .tree")
    call system(l:index_cmd . " > .treefile")
    
    " 打开并配置
    edit .tree
endfunction

" 2. 核心跳转逻辑 (逻辑不变，依然稳健)
function! JumpWithShadowIndex()
    let l:line_num = line('.')
    let l:shadow_file = '.treefile'

    if !filereadable(l:shadow_file)
        echoerr "Index error. Please run `:Gtree`"
        return
    endif

    let l:target_list = readfile(l:shadow_file)
    if l:line_num > len(l:target_list)
        return
    endif

    let l:filepath = l:target_list[l:line_num - 1]
    execute 'edit ' . l:filepath

endfunction

" 4. 命令绑定
command! Gt call GenerateProjectTree()
autocmd BufRead,BufNewFile .tree nnoremap <buffer> <CR> :call JumpWithShadowIndex()<CR>
