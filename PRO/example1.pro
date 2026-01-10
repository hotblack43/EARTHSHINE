

PRO example1,observed_image,inside,outside,imin2
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
common circleSTUFF,circle,radius,moon_coords
;----------------------------------------------------------------------------------------------------------------------------------------------
; Example 1 - a real image as input, and a treatment of that real image is used as the hypotheitcal 'ideal image'.
;
; Read in a moon image
get_imin,imin,l
window,1,title='Original image'
im1=imin > 10
im1(where(im1 eq 10))=0.0
;----------------------------------------------------------
; Get the circle that describes Moon/Sky
radius=110.9d0
moon_coords=[176,260]
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
