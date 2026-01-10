 PRO gofindradiusandcenter_fromheader,header,x0,y0,radius
 ; Will take a header and read out DISCX0, DISCY0 and RADIUS
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'DISCX0 not in header. Assigning dummy value'
 x0=256.
 endif else begin
 x0=float(strmid(header(jdx),15,9))
 endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'DISCY0 not in header. Assigning dummy value'
 y0=256.
 endif else begin
 y0=float(strmid(header(jdx),15,9))
 endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'RADIUS not in header. Assigning dummy value'
 radius=134.327880000
 endif else begin
 radius=float(strmid(header(jdx),15,9))
 endelse
 return
 end
