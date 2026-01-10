ADU=3.8	; e/count
bias=readfits('./FITS/superbias.fits')
openw,44,'all.dat'
files=file_search('/media/thejll/SAMSUNG/EARTHSHINE/MOONDROPBOX/JD2456105/2456105.*MOON*_V_*',count=nfiles)
for ifile=0,nfiles-1,1 do begin
openw,33,'data.dat'
print,files(ifile)
im=readfits(files(ifile))
l=size(im,/dimensions)
ic=0
for i=1,l(2)-1,1 do begin
frame=im(*,*,i)-bias
frame=frame/adu
if (max(frame gt 2000/adu) and max(frame) lt 55000/adu) then begin
tvscl,hist_equal(frame)
print,max(frame)
	printf,33,total(frame,/double)
	ic=ic+1
endif
endfor
close,33
if (ic gt 0) then begin
data=get_data('data.dat')
Z=abs((data-mean(data))/stddev(data))
idx=where(z lt 5)
if (idx(0) ne -1) then data=data(idx)
plot,data,xstyle=3,ystyle=3,psym=7
;print,'Mean, SD, sqrt(mean): ',mean(data,/double),stddev(data),sqrt(mean(data))
;print,'mean/SD= ',mean(data,/double)/stddev(data)
print,mean(data,/double),stddev(data)^2,mean(data,/double)/stddev(data)^2
printf,44,mean(data,/double),stddev(data)^2,mean(data,/double)/stddev(data)^2
endif
endfor
close,44
end
