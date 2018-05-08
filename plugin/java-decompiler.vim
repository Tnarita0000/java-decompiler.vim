if exists("g:jda_loaded")
  finish
endif
let g:jda_loaded = 1

let s:java_files_location = "~/.java-decompiler.cache"
let s:jad_location        = s:java_files_location . "/bin/jad"
let s:current_dir         = execute("pwd")
let s:filename            = expand("%")

function! s:FindOrGetJad() abort
  if finddir(s:java_files_location) == ""
    execute("!mkdir -p " . s:java_files_location . "/bin")
  endif

  if findfile(s:jad_location) == ""
    if has("win64")
      execute("!wget https://varaneckas.com/jad/jad158g.win.zip -O /tmp/jad.zip")
    elseif has("osx")
      execute("!wget https://varaneckas.com/jad/jad158g.mac.intel.zip -O /tmp/jad.zip")
    elseif has("unix")
      execute("!wget https://varaneckas.com/jad/jad158e.linux.static.zip -O /tmp/jad.zip")
    endif
    execute("!unzip /tmp/jad.zip -d /tmp/; mv /tmp/jad " . s:jad_location)
  endif
endf

function! s:Decompile() abort
  call s:FindOrGetJad()

  if s:filename =~ ".*.jar"
    execute("!cp " . expand("%:p") . " " . s:java_files_location)
    execute("cd " . s:java_files_location)
    let command = "!jar -xf " . expand("%:t") . " && find . -iname \"*.class\" -print0 | xargs -0 " . s:jad_location . " -r"
    execute(command)
    echo command
  elseif s:filename =~ ".*.class"
    let command = "!jad -r -s java " . s:filename . " -d " . s:java_files_location
    execute(command)
  endif

  setlocal ft=java
  setlocal syntax=java
  setlocal readonly
  setlocal nomodified
endf

command! Jad call <SID>Decompile()
