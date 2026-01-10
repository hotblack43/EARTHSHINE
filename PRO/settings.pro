 ; Find the place in the image where the center of gravity lies
 ; and set up the 'force-fit patch' there.
 ;................
 im=readfits('presentinput.fits',header)
 openw,58,'BINfiles/header.txt'
 printf,58,header
 close,58
 data=get_data('coords.dat')
 x0=reform(data(0,*))
 y0=reform(data(1,*))
 radius=reform(data(2,*))
 ;...............
 l=size(im,/dimensions)
 ;meshgrid,l(0),l(1),x,y
 ;cg_x=total(x*im)/total(im)
 ;cg_y=total(y*im)/total(im)
 ; CG can be outside the BS ..., so back to brightest spot
 idx=where(smooth(im,7) eq max(smooth(im,7)))
 arrs=array_indices(im,idx) & cg_x=arrs(0) & cg_y=arrs(1)
 ;...............
 fittop=cg_x
 colwhere=cg_y
 ; determine if the BS is to the right or the left of the c.g.
 if (x0 lt cg_x) then begin 
 ; BS is to the right
 fitsky=x0-radius-25              ; middle of sky force-fit patch in x
 ;fitsky=(x0-radius)/2.
 wid_a=2	; half-width of the square on the BS
 wid_b=7	; half-width of the square on the DS
 endif
 if (x0 ge cg_x) then begin 
 ; BS is to the left
 fitsky=x0+radius+25              ; middle of sky force-fit patch in x
 ;fitsky=l(0)-(l(0)-x0-radius)/2.
 wid_a=10	; half-width of the square on the BS
 wid_b=7	; half-width of the square on the DS
 endif
 ;wid=2  ; width of patch to force image to fit in
 ;...............
 get_lun,uu
 openw,uu,'BINfiles/runoptions.txt'
 ;printf,uu,format='(4(a,i3))',' -a ',fix(fittop),' -b ',fix(fitsky),' -c ',fix(colwhere),' -w ',fix(wid)
 printf,uu,format='(6(a,i3))',' -a ',fix(fittop),' -b ',fix(fitsky),' -c ',fix(colwhere),' -w ',fix(wid_a),' -v ',fix(wid_b),' -s ',2
 print,format='(6(a,i3))',' -a ',fix(fittop),' -b ',fix(fitsky),' -c ',fix(colwhere),' -w ',fix(wid_a),' -v ',fix(wid_b),' -s ',2
 close,uu
 free_lun,uu
 end
