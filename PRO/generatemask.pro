PRO gofindradiusandcenter,im_in,x0,y0,radius
common im,viz
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
 ntries=200
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
     if (viz eq 1) then oplot,[x1,x1],[y1,y1],psym=7
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

 ;Generates a disc mask from im - allows sky only
 common im,viz
 viz=0
 im=readfits('presentinput.fits')
 gofindradiusandcenter,im,x0,y0,radius
 openw,92,'coords.dat'
 printf,92,x0,y0,radius
 close,92
; add a bit to the radius
 radius=radius*1.05
 offset=25	; distance from rim to middle of sky-fit patch
 wid=7		; upper limit to width of sky-fit patch
 if (x0-(radius+offset+2*wid+1) ge 0 and x0+(radius+offset+2*wid+1) le 511) then begin
;if (x0 gt 0 and x0 le 511 and (x0-radius-30) gt 0 and (x0+radius+40) le 511) then begin
 openw,92,'testfile'
 printf,92,'1'
 close,92
 endif else begin
 openw,92,'testfile'
 printf,92,'0'
 close,92
	endelse
 l=size(im,/dimensions)
 N=l(0)
 x=indgen(N) # replicate(1,N)
 y=replicate(1,N) # indgen(N)
 radius_surface=sqrt((x-x0)^2+(y-y0)^2)
 mask=im*0.0+1.0
; mask out the disc itself
 idx=where(radius_surface le radius)
 mask(idx)=0
; also mask out high and low rows
 www=170
 mask(where(y le www or y gt 511-www))=0
; generate a mask that include the image - this makes the error a relative error in the RMSE sum
pedestal=100.0	; an offset to avoid dividing by small numbers
 mask=mask/smooth((im+pedestal)^2,5,/edge_truncate)
 idx=where(finite(mask) ne 1)
 if (idx(0) ne -1) then begin
	mask(idx)=0 
 	print,'Found some NaNs in the mask and set them to zero!'
 endif
 writefits,'mask.fits',mask
 end
