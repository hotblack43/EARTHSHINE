
FUNCTION ipart, x
  if (x GT 0.0) then begin
    a = floor(x)
  endif else begin
    a = ceil(x)
  endelse
  return, a
END
