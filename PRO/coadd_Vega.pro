file='Vega-40ms-100Frame.fits'
im_all=readfits(file)
for i=0,99,1 do begin
im=reform(im_all(*,*,i))
writefits,strcompress('/home/pth/Desktop/ASTRO/ANDOR/Vega_ANDOR_'+string(i)+'.fits',/remove_all),im
endfor
end
