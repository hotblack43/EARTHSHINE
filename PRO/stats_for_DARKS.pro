im=readfits('/media/thejll/SAMSUNG/EARTHSHINE/MOONDROPBOX/JD2456045/2456045.8662788DARK_DARK.fits.gz',h)
surface,im
print,'SD of bias:',stddev(im)
print,'SD_m of bias:',stddev(im)/sqrt(n_elements(im)-1)
print,'SD_m of bias for 1/200th:',stddev(im)/sqrt(n_elements(im)/200.-1)
;
nMC=1000
openw,33,'MC.dat'
for iMC=0,nMC-1,1 do begin
idx=randomu(seed,512.*512.)*512.*512.
printf,33,mean(im)/mean(im(idx))
endfor
close,33
data=get_data('MC.dat')
print,'SD of factor from MC:',stddev(data)
end
