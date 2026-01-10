dark1=readfits('/media/thejll/OLDHD/MOONDROPBOX/JD2456073/2456073.7971926DARK_DARK.fits.gz')
dark2=readfits('/media/thejll/OLDHD/MOONDROPBOX/JD2456073/2456073.7987285DARK_DARK.fits.gz')
;---------------------
im=readfits('/media/thejll/OLDHD/MOONDROPBOX/JD2456073/2456073.7983881MOON_V_AIR.fits.gz')
dummy=readfits('2456073.7983881MOON_V_AIR_DCR.fits',h)
bias=readfits('superbias.fits')
; ok, just use bias - no scaling
nadd=[100,50,25,12,6,3]
for i=0,n_elements(nadd)-1,1 do begin
	ntimes=fix(100./nadd(i))
        for itime=0,ntimes-1,1 do begin
        i1=itime*nadd(i)
        i2=(itime+1)*nadd(i)-1
	name=strcompress('2456073.7983881MOON_V_AIR_sum_of_'+string(nadd(i))+'_#'+string(itime)+'_frames.fits',/remove_all)
	print,name
        imout=avg(im(*,*,i1:i2),2)-bias
	writefits,name,imout,h
        endfor

endfor
end

