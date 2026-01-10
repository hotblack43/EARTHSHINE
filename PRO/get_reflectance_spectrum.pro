 PRO get_reflectance_spectrum,wave,reflectance
 file='terrestrial_reflectance.dat'
 openr,11,file
 j=0
 while not eof(11) do  begin
     readf,11,lamda,reflect
     if (j eq 0) then table=[lamda,reflect]
     if (j gt 0) then table=[[table],[lamda,reflect]]
     j=j+1
     endwhile
 close,11
 ; now convert to table that cover the range of 'wave'
 oldx=reform(table(0,*))
 oldy=reform(table(1,*))
 for k=0,n_elements(wave)-1,1 do begin
     interpolated_reflect=INTERPOL(oldy,oldx,wave(k))
     if (wave(k) lt min(oldx) or wave(k) gt max(oldx)) then interpolated_reflect=0.0
     if (k eq 0) then reflectance=[wave(k),interpolated_reflect]
     if (k gt 0) then reflectance=[[reflectance],[wave(k),interpolated_reflect]]
     endfor
 reflectance=reform(reflectance(1,*))
 return
 end
