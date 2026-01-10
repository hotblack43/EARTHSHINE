PRO produce_VOM,original_in,SD,MN,VOM
original=original_in
bias=readfits('ASTRO/EARTHSHINE/superbias.fits'); ADU
;bias=0.0        ; it has already been subtrcated
ADU=3.8 ; electrons/ADU according to ANDOR manual
RON=8.3 ; electrons. ANDOR and our analysis
l=size(original,/dimensions)
; subtract vias (in ADU) and convert to electrons
for k=0,l(2)-1,1 do original(*,*,k)=(original(*,*,k)-bias(*,*))*ADU    ; convert counts to electrons
SD=fltarr(512,512)
MN=fltarr(512,512)
VOM=fltarr(512,512)
; calculate SD, mean and variance-over-mean images
for i=0,511,1 do begin
for j=0,511,1 do begin
SD(i,j)=stddev(original(i,j,*))-RON
; the RON is subtracted in units of electrons
MN(i,j)=mean(original(i,j,*),/double)
VOM(i,j)=SD(i,j)^2/MN(i,j)
endfor
endfor
return
end

original=readfits('/media/bf458fbd-da4b-4083-b564-16d3aceb4c3e/MOONDROPBOX/JD2456004/2456004.1639861MOON_V_AIR.fits.gz')

end
