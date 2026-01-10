; will build a spatial PSF from the radial table digitized from Tom Stone's graph.
 ;
 file='VEGA_PSF.dat'
 data=get_data(file)
 r=reform(data(0,*))
 PSF=reform(data(1,*))
n=n_elements(PSF)
r=r(0:n-6)
PSF=PSF(0:n-6)
 PSF=10^PSF
 plot,r,PSF,/xlog,/ylog,title='Vega profile',psym=-7
; get dimensions of relevant images from another image
 PSF2=readfits('HAPKE_PSF.fit')
 l=size(PSF2,/dimensions)
 l(0)=512
 l(1)=512
 platefactor=1800*1.5/512.		; unit is arcsec/pixel
 print,'Platefactor :',platefactor,' asec/pixel'
 PSF3=dblarr(l(0),l(1))
 for i=0,l(0)-1,1 do begin
     for j=0,l(1)-1,1 do begin
         radius=sqrt((i-l(0)/2.)^2+(j-l(1)/2.)^2) ; unit is pixels
         radius=radius*platefactor	; unit is in arcseconds
         PSF3(i,j)=  INTERPOL( PSF, r, radius ) 
         endfor
     endfor
; Note that the linear interpolation used above continues along the slope
; of the last two points when an interpolant outside the given range is used.
 PSF3=PSF3-min(PSF3)
 PSF3=PSF3/total(PSF3,/double)
 PSF3=shift(PSF3,l(0)/2.,l(1)/2.)
 !P.MULTI=[0,1,1]
 surface,PSF3,title='From Vega osbervations',/zlog
 while (min(psf3) eq 0) do begin
 print,min(psf3)
 idx=where(psf3 eq 0)
 psf3(idx)=max(psf3)/1e3
 endwhile
 writefits,'Vega_PSF.fit',PSF3
 surface,PSF3,title='From Vega osbervations'
 end
