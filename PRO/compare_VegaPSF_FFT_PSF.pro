; will build a spatial PSF from the radial table digitized from Tom Stone's graph.
;
file='VEGA_PSF.dat'
data=get_data(file)
r=reform(data(0,*))
PSF=reform(data(1,*))
PSF=10^PSF
plot,r,PSF,/xlog,/ylog,title='Vega profile', $
xrange=[1.,100],xstyle=1,xtitle='Radius (arc seconds)',ytitle='PSF'
;
str='LAMBERT'
str='HAPKE'
PSF_FFT=readfits(strcompress(str+'_PSF.fit',/remove_all))
l=size(PSF_FFT,/dimensions)
; setthe image scale as arc seconds per pixel
psfscale=.1/1e-6
imagescale=3.0	; arc seconds per pixel
; shift it to the center
PSF_FFT=shift(PSF_FFT,l(0)/2.-1,l(1)/2.-1)
openw,3,'table_vega_psf.dat'
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
r2=sqrt((i-l(0)/2.)^2+(j-l(1)/2.)^2)
;print,r2,PSF_FFT(i,j)
printf,3,r2,PSF_FFT(i,j)
endfor
endfor
close,3
data=get_data('table_vega_psf.dat')
x=reform(data(0,*))
y=reform(data(1,*))
oplot,x*imagescale,y*psfscale,psym=4
end
