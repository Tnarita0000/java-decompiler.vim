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
  call mkdir(s:decompress_path)
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

function FindLibraryPath(dependency)
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
  call s:FindProjectRoot()

  if s:config_file != ""
    call s:ScanDependencies()
    let s:count = 0
    while s:count < len(s:dependencies)
      call FindLibraryPath(s:dependencies[s:count])
      let s:count += 1
    endwhile
  endif

  call s:DecompileJarFiles()
endfunction

call s:Main()
