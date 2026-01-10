path='/data/pth/DATA/ANDOR/EarthshineData/Data20100903/'
file=path+'Vega-40ms-100Frame.fits'
file=path+'Moon-CoAdd-9ms-100frame-R5.fits'
file=path+'Moon-LundMode-30s-10frame-R2.fits'
im=readfits(file)
l=size(im,/dimensions)
nims=l(2)
for i=0,nims-1,1 do begin
ime=reform(im(*,*,i))
writefits,strcompress(path+'/EXTRACTED/'+'Moon-LundMode-30s-10_R2_'+string(i)+'.fits',/remove_all),ime
endfor
end
