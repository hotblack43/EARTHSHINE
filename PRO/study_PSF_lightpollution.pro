 PRO get_monphase,header,monphase
 idx=where(strpos(header, 'MPHASE') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 monphase=float(strmid(str,13,13))
 return
 end

;--------------------------------------------------------------------------------
listname='list_MkIII_CUBES_totestpollution.txt'
get_lun,jjhgrt
get_lun,kjjkhgfgcre
openw,kjjkhgfgcre,'pcterrorfromPSF.dat'
openr,jjhgrt,listname
while not eof(jjhgrt) do begin
name=''
readf,jjhgrt,name
im=readfits(name,header)
ideal=reform(im(*,*,4))
lon=reform(im(*,*,5))
lat=reform(im(*,*,6))
; getthe ideal image out
idx=where(lon ge 75 and lon le 80 and lat ge 0 and lat le 10)
correct1=mean(ideal(idx))
jdx=where(lon le -75 and lon ge -80 and lat ge 0 and lat le 10)
correct2=mean(ideal(jdx))
if (correct1 lt correct2) then begin
correct=correct1
idx=idx
endif
if (correct1 gt correct2) then begin
correct=correct2
idx=jdx
endif
toshow=ideal
toshow(idx)=max(toshow)
tvscl,toshow
; get its phase
get_monphase,header,phase
; loop over alfas
for alfa=1.5,1.8,0.01 do begin
writefits,'jhgjhgcjhg.fits',ideal
spawn,'./justconvolve jhgjhgcjhg.fits ikhgjhc.fits '+string(alfa)
smudgy=readfits('ikhgjhc.fits')
;study brightness
smudged=mean(smudgy(idx))
pctchange=(smudged-correct)/correct*100.0
print,phase,alfa,pctchange
printf,kjjkhgfgcre,phase,alfa,pctchange
endfor
endwhile
close,jjhgrt
free_lun,jjhgrt
close,kjjkhgfgcre
end
