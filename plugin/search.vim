let s:fullpath                   = split(expand("%:p"), "\/")
let s:config_patterns            = ["build.gradle", "pom.xml"]
let s:config_file                = ""
let s:gradle_dependency_keywords = ["compile", "runtime"]
let s:dependencies                 = []
if @% == ""
  finish
endif
cd %:h

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

function s:FindProjectRoot(currentpath)
  let filelist = split(glob(a:currentpath . "/*"), "\n")
  for file in filelist 
    if s:IsConfigFile(file)
      let s:config_file = file
      break
    endif
  endfor
  return s:config_file
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

let s:count = 0
while s:count < len(s:fullpath)
  let currentpath = "/" . join(s:fullpath, "/")
  call s:FindProjectRoot(currentpath)
  if s:config_file
    break
  endif
  call s:MoveUpDir()
  call remove(s:fullpath, -1)
endwhile

if s:config_file != ""
  for line in readfile(s:config_file)
    if s:IsDependencyKeyword(line)
      let s:dependency = matchstr(line, "\\(\".\\{\\-\\}\"\\)\\|\\('.\\{\\-\\}'\\)")[1:-2]
      if s:dependency != ""
        call add(s:dependencies, s:dependency)
      endif
    endif
  endfor
end
echo s:dependencies

"let target1 = "compile (\"org.jetbrains.kotlin:kotlin-stdlib-jre6\")"
"let target2 = "compile ('org.jetbrains.kotlin:kotlin-stdlib-jre7')"

"let both_regexp = "\(\"\|'\).*\{-}\(\"\|'\)"
"let both_regexp = "\(\"\|'\).*\(\"\|'\)"
"let both_regexp = "\(\"\|'\).*"
"let both_regexp = "\(\".*\"\)\|\('.*'\)"
"let both_regexp = "\\(\".*\"\\)\\|\\('.*'\\)"
"let both_regexp = "\\(\".\\{\\-\\}\"\\)\\|\\('.\\{\\-\\}'\\)"
"let both_matched = matchstr(target1, both_regexp)
"echo both_matched
"let both_matched = matchstr(target2, both_regexp)
"echo both_matched
