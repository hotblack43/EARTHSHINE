FUNCTION rangetrig, x
  b = x / 360.0
  a = 360.0 * (b - ipart(b))
  if (a LT 0.0) then begin
    a = a + 360.0
  endif
  return, a
END
