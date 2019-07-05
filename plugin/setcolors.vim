" Change the color scheme from a list of color scheme names.
" Version 2019 fork
" Press key:
"   F8                next scheme
"   Shift-F8          previous scheme
"   Alt-F8            random scheme
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

" Set next/previous/random (how = 1/-1/0) color from our list of colors.
" The 'random' index is actually set from the current time in seconds.
" Global (no 's:') so can easily call from command line.
function! NextColor(how)
  call s:NextColor(a:how, 1)
endfunction

function! s:LoadColors()
  let paths = split(globpath(&runtimepath, 'colors/*.vim'), "\n")
  let s:mycolors = map(paths, 'fnamemodify(v:val, ":t:r")')
endfunction

" Helper function for NextColor(), allows echoing of the color name to be
" disabled.
function! s:NextColor(how, echo_color)
  if len(s:mycolors) == 0
    call s:SetColors('all')
  endif
  let missing = []
  let s:current += a:how

  if !(0 <= s:current && s:current < len(s:mycolors))
    let s:current = (a:how>0 ? 0 : len(s:mycolors)-1)
  endif

  try
    execute 'colorscheme '.s:mycolors[s:current]
  catch /E185:/
    call add(missing, s:mycolors[s:current])
  endtry

  redraw

  if len(missing) > 0
    echo 'Error: colorscheme not found:' join(missing)
  endif

  if (a:echo_color)
    echo g:colors_name
  endif
endfunction

nnoremap <F8> :call NextColor(1)<CR>
nnoremap <F7> :call NextColor(-1)<CR>


