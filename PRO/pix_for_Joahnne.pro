im=readfits('moon.fits')
plot,im(*,301),xstyle=3,ystyle=3
openw,1,'snit.dk'
subarr=im(*,301-10:301+10)
line=avg(subarr,1)
for k=0,512-1,1 do begin
printf,1,k,line(k)
endfor
close,1
end
