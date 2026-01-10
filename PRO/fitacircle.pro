 PRO gofindradiusandcenter,im_in,x0,y0,radius
 common rememberthis,firstguess
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 im=SOBEL(im)
 ; im treshold and remove some single pixels
 idx=where(im gt max(im)/4.)
 jdx=where(im le max(im)/4.)
 im(idx)=1
 im(jdx)=0
 imuselater=im
 ; remove specks
 im=median(im,3)
 writefits,'inputimageforsicle.fits',im_in
 writefits,'sicle.fits',im
 ; find good estimates of the circle radius and centre
 ntries=100
 idx=where(im ne 0)
 coords=array_indices(im,idx)
 nels=n_elements(idx)
 get_lun,rew
 openw,rew,'trash2.dat'
 for i=0,ntries-1,1 do begin 
     irnd=randomu(seed)*nels
     x1=reform(coords(0,irnd))
     y1=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x2=reform(coords(0,irnd))
     y2=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x3=reform(coords(0,irnd))
     y3=reform(coords(1,irnd))
     ;oplot,[x1,x1],[y1,y1],psym=7
     fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
     printf,rew,x0,y0,radius
     endfor
 close,rew
 free_lun,rew
 spawn,'grep -v NaN trash2.dat > aha2.dat'
 spawn,'mv aha2.dat trash2.dat'
 data=get_data('trash2.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 get_lun,iuy & openw,iuy,'circle.dat' & printf,iuy,x0,y0,radius & close,iuy & free_lun,iuy
 firstguess=[x0,y0,radius]
 ; So, that was a robust first guess - but not good enough! Using the first guess we go on and (hopefully) improve
print,'First guess x0,y0,r0:',firstguess
startguess=[x0,y0,radius,7,2]
godoitbetter,startguess,imuselater,x0,y0,radius
print,'Best x0,y0,r0:',x0,y0,radius
get_lun,iuy & openw,iuy,'circle.dat' & printf,iuy,x0,y0,radius & close,iuy & free_lun,iuy
if (n_elements(x0) gt 1 or n_elements(y0) gt 1 or n_elements(radius) gt 1) then stop
 return
 end
