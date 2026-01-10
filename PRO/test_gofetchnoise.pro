 ;-------------------------------------------------------------------------------------
 ; Version 2. Code estimates noise along 'slice' given the JD.
 ; Assumes several files with that JD has been assembled in PEN/
 ;-------------------------------------------------------------------------------------
;common stuff56,x0,y0,radius
 common noises,rad,linestack,noisestack
 get_lun,y15
 openr,y15,'JDs.simex_trials'
 while not eof(y15) do begin
     str=''
     readf,y15,str
     bits=strsplit(str,' ',/extract)
     JDstr=bits(0)
	gofetchnoise,JDstr,rad,linestack,noisestack
        writefits,'noisestack.fits',noisestack
     endwhile
 close,y15
 free_lun,y15
 end

; common noises,rad,linestack,noisestack
; gofetchnoise,JDstr,rad,linestack,noisestack
