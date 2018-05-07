if exists("g:jda_loaded")
  finish
endif
let g:jda_loaded = 1

function! s:FindOrGetJad() abort
  " reference: https://varaneckas.com/jad/
  if !executable("jad")
    if has("win64")
      execute("!wget https://varaneckas.com/jad/jad158g.win.zip -O /tmp/jad.zip")
    else
      if execute("!uname") == "Linux"
        execute("!wget https://varaneckas.com/jad/jad158e.linux.intel.zip -O /tmp/jad.zip")
      else
        execute("!wget https://varaneckas.com/jad/jad158g.mac.intel.zip -O /tmp/jad.zip")
      endif
      execute("!unzip /tmp/jad.zip -d /tmp/; mv /tmp/jad /usr/local/bin/")
    endif
  endif
endf

func! s:Decompile() abort
  call s:FindOrGetJad()

  let java_files_location = "~/.java-decompiler.cache"
  let current_dir         = execute("pwd")
  let filename            = expand("%")

  if finddir(java_files_location) == ""
    execute("!mkdir " . java_files_location)
  endif

  if filename =~ ".*.jar"
    "execute("!mv " . filename . " " . java_files_location . "; cd " . java_files_location)
    let command = "!jar -xf " . filename . " && find . -iname \"*.class\" | xargs echo"
    execute(command)
  elseif filename =~ ".*.class"
    let command = "!jad -r -s java " . filename . " -d " . java_files_location
    execute(command)
  endif

  setl ft=java
  setl syntax=java
  setl readonly
  setl nomodified
endf

command! Jad call <SID>Decompile()
