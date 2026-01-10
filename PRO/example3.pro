
PRO example3,observed_image,inside,outside,imin2
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
common circleSTUFF,circle,radius,moon_coords
;----------------------------------------------------------------------------------------------------------------------------------------------
; Example 3 - reads in a real image - to be used only with the ølinear' method
;
; Read in a moon image
get_imin3,imin,l
window,1,title='Original image'
;----------------------------------------------------------
; Get the circle that describes Moon/Sky
contour,alog(imin),/isotropic
cursor,x1,y1
wait,0.2
cursor,x2,y2
wait,0.2
cursor,x3,y3
wait,0.2
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
moon_coords=[x0,y0]
get_circle,l,moon_coords,circle,radius,max(imin)
;----------------------------------------------------------
; Build a composite image of Moon and circle
imin2=imin+circle
tvscl,alog(imin2)
;stop
;----------------------------------------------------------
; find the inside and the outside of the circle around the Moon
find_circle_inside_outside,radius,moon_coords,inside,outside,l,idx_inside,idx_outside
im1=imin	; ie the known case without sky
im3=outside	; the skymask
;----------------------------------------------------------
observed_image=imin	; for now
im2=observed_image
return
end
