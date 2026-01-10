
PRO example2,observed_image,inside,outside,imin2
common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
common circleSTUFF,circle,radius,moon_coords
common paths,path
common problem,if_generate_problem
;----------------------------------------------------------------------------------------------------------------------------------------------
; Example 2 - uses a synthetic image and treats itto make a pretend observed image
;
; Read in a moon image
get_imin2,imin,l
window,1,title='Original image'
;----------------------------------------------------------
; Get the right PDF in order to convolve the ideal image and get your fake oberveed image
example_power=2.0	; for King profile
trial_sigma=(50.0d0)^2	; for Gaussian profile
scale=150.0d0		; for exp(-abs(scale*radius)) profile
if (STRUPCASE(typeflag) eq "KING") then get_pdf_King,l,pdf,example_power
if (STRUPCASE(typeflag) eq "GAUSSIAN") then get_pdf_Gaussian,l,pdf,trial_sigma
if (STRUPCASE(typeflag) eq "CIE") then get_pdf_CIE,l,pdf,scale
;----------------------------------------------------------
; Now convolve the image with the PDF
problem=imin*0.0
if (if_generate_problem eq 1) then generate_interesting_problem,problem
fold_image_with_pdf,imin+problem,l,folded_image,pdf
weight=0.03
;combined_image=imin/mean(imin)+weight*folded_image/mean(folded_image)
combined_image=imin/mean(imin)*(1.0-weight)+weight*folded_image/mean(folded_image)
observed_image=combined_image/mean(combined_image)*mean(imin)
writefits,path+'Constructed_observed_image_ex2.fit',(observed_image)
writefits,path+'Constructed_observed_image_ex2_LONG.fit',long(observed_image)
;----------------------------------------------------------
; Get the circle that describes Moon/Sky
;radius=107.
;moon_coords=[200.,200.5]
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
im2=observed_image

return
end
