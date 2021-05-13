if exists('g:loaded_blockdown_nvim') || &compatible || v:version < 700
    finish
endif
let g:loaded_blockdown_nvim = 1

command! -nargs=0 BlockRun :lua require'blockdown'.run()<cr>

if exists('g:blockdown_nvim_enter_run')
    autocmd! Filetype markdown nmap <silent> <buffer> <Return> :BlockRun<cr>
endif
