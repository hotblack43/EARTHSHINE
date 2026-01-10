bias=readfits('FITS/DAVE_BIAS.fits')
files=file_search('/media/thejll/OLDHD/MOONDROPBOX/JD2455769/*JUPITER*.fits*',count=n)
openw,3,'jupiter_stats.dat'
for i=0,n-1,1 do begin
im=double(readfits(files(i)))
if (i eq 0 and mean(im-bias) gt 2) then stack=im-bias
if (i gt 0 and mean(im-bias) gt 2) then stack=[[[stack]],[[im-bias]]]
printf,3,format='(4(1x,f12.3),1x,a)',moment(im-bias),files(i)
print,format='(4(1x,f12.3),1x,a)',moment(im-bias),files(i)
idx=where_2d(im eq max(im))
print,'max at: ',idx(0,*),idx(1,*)
endfor
close,3
im=avg(stack,2)
writefits,'jupiter.fits',float(im)
end
