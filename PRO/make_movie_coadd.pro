window,1,xsize=2*512,YSIZE=512
loadct,13
file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455749/2455749.7544531TEST_MOON_V_AIR_NOTCENTER.fits'
;file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455749/2455749.7563016TEST_MOON_VE2_AIR_NOTCENTER.fits'
im=readfits(file)
writefits,'summed_V.fits',avg(im,2)
;writefits,'summed_VE2.fits',avg(im,2)
l=size(im,/dimensions)
n=l(2)
for i=1,n-1,1 do begin
print,i
output_image = HistoMatch(reform(im(*,*,i)), findgen(256)*0+1)
help,im(*,*,0:i)
summed_image = HistoMatch(avg(im(*,*,0:i),2), findgen(256)*0+1)
together=[output_image,summed_image]
tv, together
if (i le 9) then numstr='0'+string(i)
if (i gt 9) then numstr=string(i)
write_gif,strcompress('frame_'+numstr+'.gif'),tvrd()
endfor
end
