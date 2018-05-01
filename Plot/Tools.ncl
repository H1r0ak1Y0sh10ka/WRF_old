; This file contains tools.
; Hiroaki Yoshioka(yoshioka@dpac.kyoto-u.ac.jp)
; History:
; 30/04/2018 - 1st released (makedir)
;
; contains: makedir
;
; makedir
; Usage: makedir(PATH)
; PATH (string): PATH of directory to want to make now.
; e.g. makedir("~/HOGE/HOGEHOGE/HOGEHOGE")
; ====================================================================================================

undef ( "makedir" )
procedure makedir (  \
  PATH[*]           : string \
  )
local ret
begin

ret = systemfunc("test -d " + PATH + "; echo $?")
if(ret .eq. 0) then
print("--> "+ PATH +": exists")                  ;-- do what you want to do
else if(ret .eq.1) then
print("--> "+ PATH +": doesn't exist: create")   ;-- create the desired directory
system("mkdir -p " + PATH)
end if
end if

end


