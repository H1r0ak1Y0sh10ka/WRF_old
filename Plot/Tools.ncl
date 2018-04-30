; This file contains tools.
; Hiroaki Yoshioka(yoshioka@dpac.kyoto-u.ac.jp)
; History:
; 30/04/2018 - 1st released (makedir)
;
; contains: makedir
;
; makedir
; Usage: makedir(path)
; path (string): path of directory to want to make now.
; e.g. makedir("~/HOGE/HOGEHOGE/HOGEHOGE")
; ====================================================================================================

undef ( "makedir" )
procedure makedir (  \
  path[*]           : string \
  )
local ret
begin

ret = systemfunc("test -d " + path + "; echo $?")
if(ret .eq. 0) then
print("--> "+ path +": exists")                  ;-- do what you want to do
else if(ret .eq.1) then
print("--> "+ path +": doesn't exist: create")   ;-- create the desired directory
system("mkdir -p " + path)
end if
end if

end


