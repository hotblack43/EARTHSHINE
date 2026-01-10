PRO get_observed_image,observed_image
common moonres,im1,im2,im3
im1=readfits('ideal_starting_image.fit')
observed_image=readfits('Simulated_observed_image_CIEIDEALIZED.fit')
l=size(observed_image,/dimensions)
contour,alog(im1),/isotropic
cursor,x1,y1
wait,0.2
cursor,x2,y2
wait,0.2
cursor,x3,y3
wait,0.2
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
moon_coords=[x0,y0]
get_circle,l,moon_coords,circle,radius,max(im1)
;----------------------------------------------------------
; Build a composite image of Moon and circle
imin2=im1+circle
tvscl,alog(imin2)
;stop
;----------------------------------------------------------
; find the inside and the outside of the circle around the Moon
find_circle_inside_outside,radius,moon_coords,inside,outside,l,idx_inside,idx_outside
im3=outside     ; the skymask
im2=observed_image

return
end
