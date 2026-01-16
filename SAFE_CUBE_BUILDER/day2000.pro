
;======================================
; Fractional number of days since J2000
;======================================

FUNCTION day2000, yr, mon, day, hr
   if (mon EQ 1) OR (mon EQ 2) then begin
     yr = yr - 1
     mon = mon + 12
   endif
   a = floor(yr/100.0)
   b = 2.0 - a  + floor(a/4.0)
   c = floor(365.25 * yr)
   d1 = floor(30.6001 * (mon + 1))
   return, (b + c + d1 - 730550.5 + day + hr/24.0)
END
