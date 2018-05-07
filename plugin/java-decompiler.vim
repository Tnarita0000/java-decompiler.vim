if exists("g:jda_loaded")
  finish
endif
let g:jda_loaded = 1

function! s:FindOrGetJDA() abort
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
  call s:FindOrGetJDA()

  let filename = expand("%")
  echo filename
  if filename =~ ".*.jar"
    execute("!jar -xf " . filename . " && find . -iname \"*.class\" | xargs jad -r -s java")
  elseif filename =~ ".*.class"
    execute("!jad -r -s java " . filename)
    echo "======================="
  endif

  setl ft=java
  setl syntax=java
  setl readonly
  setl nomodified
endf

com! DejavaThis call <SID>Decompile()
