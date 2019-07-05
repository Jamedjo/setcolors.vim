" Change the color scheme from a list of color scheme names.
" Version 2019 fork
" Press key:
"   F8          next scheme
"   F7          previous scheme
"   F9     random scheme
" Set the list of color schemes used by the above (default is 'all'):
"   :SetColors all              (all $VIMRUNTIME/colors/*.vim)
"   :SetColors blue slate ron   (these schemes)
"   :SetColors                  (display current scheme names)
if v:version < 700 || exists('loaded_setcolors') || &cp
  finish
endif

let loaded_setcolors = 1
let s:mycolors = []
let s:current = -1

" Set list of color scheme names that we will use, except
" argument 'now' actually changes the current color scheme.
function! s:SetColors(args)
  if len(a:args) == 0
    echo 'Current color scheme names:'
    let i = 0
    while i < len(s:mycolors)
      echo '  '.join(map(s:mycolors[i : i+4], 'printf("%-14s", v:val)'))
      let i += 5
    endwhile
  elseif a:args == 'all'
    call s:LoadColors()
    echo 'List of colors set from all installed color schemes'
  else
    let s:mycolors = split(a:args)
    echo 'List of colors set from argument (space-separated names)'
  endif
endfunction

command! -nargs=* SetColors call s:SetColors('<args>')

" Global (no 's:') so can easily call from command line.
function! NextColor()
  call s:CycleColor(1, 1)
endfunction
function! PrevColor()
  call s:CycleColor(-1, 1)
endfunction
function! RandomColor()
  call s:RandomColor(1)
endfunction

function! s:LoadColors()
  let paths = split(globpath(&runtimepath, 'colors/*.vim'), "\n")
  let s:mycolors = map(paths, 'fnamemodify(v:val, ":t:r")')
endfunction

function! s:InitializeColors()
  if len(s:mycolors) == 0
    call s:LoadColors()
  endif
endfunction

function! s:CycleColor(how, echo_color)
  call s:InitializeColors()

  let s:current += a:how

  if !(0 <= s:current && s:current < len(s:mycolors))
    let s:current = (a:how>0 ? 0 : len(s:mycolors)-1)
  endif

  call s:ActivateColor(s:mycolors[s:current], a:echo_color)
endfunction

function! s:RandomColor(echo_color)
  call s:InitializeColors()

  let s:current = s:Random(len(s:mycolors)-1)
  call s:ActivateColor(s:mycolors[s:current], a:echo_color)
endfunction

function! s:Random(max) abort
  return str2nr(matchstr(reltimestr(reltime()), '\v\.@<=\d+')[1:]) % a:max
endfunction

function! s:ActivateColor(colorscheme, echo_color)
  try
    execute 'colorscheme '. a:colorscheme
  catch /E185:/
    echo 'Error: colorscheme not found:' a:colorscheme
  endtry

  redraw

  if (a:echo_color)
    echo g:colors_name
  endif
endfunction

nnoremap <F7> :call PrevColor()<CR>
nnoremap <F8> :call NextColor()<CR>
nnoremap <F9> :call RandomColor()<CR>
