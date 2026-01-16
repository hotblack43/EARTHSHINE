
;=============================
; Leap year detecting function.
;=============================

FUNCTION isleap, yr
  a = 0
  if ((yr MOD 4) EQ 0) then a = 1
  if ((yr MOD 100) EQ 0) then a = 0
  if ((yr MOD 400) EQ 0) then a = 1
  return, a
END
