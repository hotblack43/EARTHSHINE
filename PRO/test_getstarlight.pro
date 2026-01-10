 PRO getstarlight,jd,starlight
 ; return the brightness due to stars next to the Moon at time JD 
 ; in units of S10 (i.e. # of 10th mag stars per square degree)
 MOONPOS,jd,ra,dec
 GLACTC, ra, dec, 2000, gl, gb, 1,  /DEGREE
 ; formula from Table 1 of Benn and Ellison, 1999, "La Palma night-sky brightness"
 ; which is from Roach&Gordon 1973.
 count=25+250.*exp(-abs(gb)/20)
 ; so that is in S10 - now go for counts on our CCD
 SLdeg=10.0-2.5*alog10(count)	; mags/sq deg
 SLasec2=SLdeg+2.5*alog10(3600.0d0^2)	; mags/sq asec
 SL=SLasec2-2.5*alog10(6.67^2)	; mags/pixel on our CCD
 starlight=10.0^((15.1-SL)/2.5)	; counts per second per pixel for our Andor camera
 return
 end
 
 for jd=systime(/julian),systime(/julian)+30,1 do begin
     getstarlight,jd,counts 	; cts/second on our CCD'
     print,jd,counts
     endfor
 end
