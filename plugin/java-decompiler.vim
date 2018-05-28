if exists("g:jda_loaded")
  finish
endif
let g:jda_loaded = 1

if @% == ""
  finish
endif
cd %:h

if !exists('s:fullpath')
  let s:fullpath                   = split(expand("%:p:h"), "\/")
endif

let s:config_patterns            = ["build.gradle", "pom.xml"]
let s:gradle_dependency_keywords = ["compile", "runtime"]
let s:dependencies                 = []
let s:dependencies_managed_path  = ["~/.gradle", "~/.m2"]

let s:config_file                = ""
let s:target_lib_manager         = ""
let s:dependency_files           = []
let s:decompress_path            = ""

function s:IsConfigFile(file)
  let result = 0
  for config in s:config_patterns
    if a:file =~ config
      let result = 1
      break
    endif
  endfor
  return result
endfunction

function s:IsDependencyKeyword(line)
  let result = 0
  for keyword in s:gradle_dependency_keywords
    if a:line =~ keyword
      let result = 1
    endif
  endfor
  return result
endfunction

function s:MoveUpDir()
  execute "lcd ../" 
endfunction

function SetConfiguration(file, dir)
  let s:config_file = a:file
  let s:decompress_path = a:dir . '/.extensions'
  if !isdirectory(s:decompress_path)
    mkdir(s:decompress_path)
  endif
endfunction

function s:FindProjectRoot()
  let s:count = 0
  while s:count < len(s:fullpath)
    let s:currentdir = execute("pwd")[1:]
    let filelist = split(glob(s:currentdir . "/*"), "\n")

    for file in filelist 
      if s:IsConfigFile(file)
        call SetConfiguration(file, execute("pwd")[1:])
        break
      endif
    endfor

    if s:config_file != "" | break | endif
    call s:MoveUpDir()
    let s:count += 1
  endwhile
endfunction

function s:FindLibraryPath(dependency)
  let s:targetPath = join(split(a:dependency, ':'), '/')
  let s:filelist = split(glob("~/.gradle/**/*.jar"), "\n")
  for file in s:filelist
    if file =~ s:targetPath
      call add(s:dependency_files, file)
    endif
  endfor
endfunction

function s:DecompileJarFiles()
  if !len(s:dependency_files) | return | endif
  for file in s:dependency_files
  endfor
endfunction

function s:ResolveDependencyLibralies()
  if s:config_file != ""
    let s:count = 0
    while s:count < len(s:dependencies)
      call s:FindLibraryPath(s:dependencies[s:count])
      let s:count += 1
    endwhile
  endif
  call s:DecompileJarFiles()
endfunction

function s:ScanDependencies()
  for line in readfile(s:config_file)
    if s:IsDependencyKeyword(line)
      let s:string_regexp_in_literal = "\\('\\)\\@<=.*\\('\\)\\@=\\|\\(\"\\)\\@<=.*\\(\"\\)\\@="
      let s:dependency = matchstr(line, s:string_regexp_in_literal)
      if s:dependency != ""
        call add(s:dependencies, s:dependency)
      endif
    endif
  endfor
endfunction


function! s:Search()
  let s:count = 0
  while s:count < len(s:fullpath)
    let currentpath = "/" . join(s:fullpath, "/")
    call s:FindProjectRoot()
    if s:config_file
      break
    endif
    call s:MoveUpDir()
    call remove(s:fullpath, -1)
  endwhile

  if s:config_file != ""
    call s:ScanDependencies()
    call s:ResolveDependencyLibralies()
  else
    cd %:h
  end
endfunction

let s:java_files_location = "~/.java-decompiler.cache"
let s:jad_location        = s:java_files_location . "/bin/jad"
let s:current_dir         = execute("pwd")
let s:filename            = expand("%:t")

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
  if s:filename =~ ".*.jar"
    execute("!cp " . expand("%:p") . " " . s:java_files_location)
    execute("cd " . s:java_files_location)
    let command = "!jar -xf " . s:filename
          \. " && find . -iname \"*.class\" -print0 | xargs -0 "
          \. s:jad_location . " -r"
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

command! Jad call s:Decompile()
command! FindOrGetJad call s:FindOrGetJad()
command! SearchDependencies call s:Search()
