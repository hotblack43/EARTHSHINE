PRO getMOONinfo,JD,alt,illumfrac
mphase,jd,illumfrac
obsname='mlo'
         moonpos, JD, RAmoon, DECmoon
         eq2hor, ramoon, decmoon, jd, alt, az, ha,  OBSNAME=obsname

return
end


; code to tell us if the Moon was in the sky - and what 
; its phase was - given a list of JDs.
openw,44,'WASTHEMOONUP.txt'
file='listofJDswewishtoknowabout.txt'
openr,1,file
while not eof(1) do begin
jd=0.0d0
readf,1,jd
getMOONinfo,JD,alt,illumfrac
print,format='(f15.7,1x,f6.2,1x,f9.4)',JD,alt,illumfrac
printf,44,format='(f15.7,1x,f6.2,1x,f9.4)',JD,alt,illumfrac
endwhile
close,1
close,44
end

