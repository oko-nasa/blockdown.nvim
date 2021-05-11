if exists('g:loaded_blockdown_nvim') || &compatible || v:version < 700
  finish
endif
let g:loaded_blockdown_nvim = 1

fun! ReloadBlockdownPlugin()
    lua for k in pairs(package.loaded) do if k:match("^blockdown$") then package.loaded[k] = nil end end
endfun

command! -nargs=0 BlockRun :lua require'blockdown'.run()<cr>

" nnoremap <leader>R :call ReloadBlockdownPlugin()<cr>
" nnoremap <leader>r :BlockRun<cr>
