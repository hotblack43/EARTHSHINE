
FUNCTION datan2, y, x
  if ((x EQ 0.0) AND (y EQ 0.0)) then begin
    return, 0
  endif else begin
    a = datan(y/x)
    if (x LT 0.0) then begin
      a = a + 180.0
    endif
    if (y LT 0.0 AND x GT 0.0) then begin
      a = a + 360.0
    endif
    return, a
  endelse
END
