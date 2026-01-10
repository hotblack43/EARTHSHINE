PRO gofindradiusandcenter,im_in,x0,y0,radius
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 im=sobel(im)
 ;im=laplacian(im,/CENTER)
 ; im treshold and remove some single pixels
 idx=where(im gt max(im)/4.)
 jdx=where(im le max(im)/4.)
 im(idx)=1
 im(jdx)=0
 ; remove specks
 im=median(im,3)
 ; find good estimates of the circle radius and centre
 ntries=100
 idx=where(im ne 0)
 coords=array_indices(im,idx)
 nels=n_elements(idx)
 openw,49,'trash.dat'
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
     printf,49,x0,y0,radius
     endfor
 close,49
 data=get_data('trash.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 return
 end

PRO gofindDSBS,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS
; determine if BS is to the right or the left of the center
if (cg_x gt x0) then begin
; BS is to the right
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0-radius*2./3.-w:x0-radius*2./3.+w,y0-w:y0+w))
endif
if (cg_x lt x0) then begin
; BS is to the left
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0+radius*2./3.-w:x0+radius*2./3.+w,y0-w:y0+w))
endif
return
end

PRO cgfinder,im,cg_x,cg_y
; find c.g.
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)
 cg_y=total(y*im)/total(im)
return
end
