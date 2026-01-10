im=readfits('target_for_noise_tests.fits')
print,total(im,/double),' ','target_for_noise_tests.fits'
org=total(im,/double)
files=file_search('out1*.fits',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i))
print,total(im,/double),' ',(total(im,/double)-org)/org*100.0,' % ',files(i)
endfor
end
