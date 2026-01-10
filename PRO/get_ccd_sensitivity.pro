 PRO get_CCD_sensitivity,wave,CCD_sensitivity
 openr,1,'sensitivity_CCD.dat'
 ;openr,1,'sensitivity_coated_CCD.dat'
 readf,1,nfilters
 for i=0,nfilters-1,1 do begin
     readf,1,npoints
     for j=0,npoints-1,1 do begin
         readf,1,lamda,trans
         if (j eq 0) then table=[lamda,trans/100.]
         if (j gt 0) then table=[[table],[lamda,trans/100.]]
         endfor
     endfor
 close,1
 ; now convert to table that cover the range of 'wave'
 oldx=reform(table(0,*))
 oldy=reform(table(1,*))
 for k=0,n_elements(wave)-1,1 do begin
     interpolated_sensi=INTERPOL(oldy,oldx,wave(k))
     if (wave(k) lt min(oldx) or wave(k) gt max(oldx)) then interpolated_sensi=0.0
     if (k eq 0) then newtable=[wave(k),interpolated_sensi]
     if (k gt 0) then newtable=[[newtable],[wave(k),interpolated_sensi]]
     endfor
 CCD_sensitivity=reform(newtable(1,*))
 return
 end
