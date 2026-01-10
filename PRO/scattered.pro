!P.MULTI=[0,2,2]
im_orig=readfits('~/Desktop/ASTRO/MOON/May27/obsrun1/IMG164.FIT')
l=size(im_orig,/dimensions)
im=double(im_orig)
im(750:l(0)-1,*)=im(750:l(0)-1,*)*1.0d0
im(0:749,*)=im(0:749,*)/10000.0d0
rescale=8*1
im=rebin(im,l(0)/rescale,l(1)/rescale)
l=size(im,/dimensions)
print,l
ncols=l(0)
nrows=l(1)
rayleigh=im*0
factor=0.6/float(l(1))*!dtor	; image scale - radians/pixel
for irow=0L,nrows-1,1 do begin
	print,irow
	for icol=0L,ncols-1,1 do begin
		thiscontribution=double(im*0.0d0)
		for j=0L,nrows-1,1 do begin
			for i=0L,ncols-1,1 do begin
				dist=sqrt((irow-j)^2+(icol-i)^2)
				angle=dist*factor
				thiscontribution(i,j)=im(icol,irow)*(1.+cos(angle)^2)
			endfor
		endfor
		rayleigh=rayleigh+thiscontribution/float(ncols*nrows)
		tvscl,rayleigh
	endfor
endfor
scattered_light_image=rebin(rayleigh,l(0)*rescale,l(1)*rescale)
scattered_light_image=scattered_light_image/max(scattered_light_image)*1.e3
writefits, 'SCATTERED.FIT', scattered_light_image
end
