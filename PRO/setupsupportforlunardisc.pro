PRO setupsupportforlunardisc,c_image,mask
l=size(c_image,/dimensions)
if (file_test('moon_circle_data.dat') ne 1) then begin
contour,c_image
cursor,x1,y1
wait,0.2
cursor,x2,y2
wait,0.2
cursor,x3,y3
wait,0.2
openw,45,'moon_circle_data.dat'
printf,45,x1,y1
printf,45,x2,y2
printf,45,x3,y3
close,45
endif else begin
openr,45,'moon_circle_data.dat'
readf,45,x1,y1
readf,45,x2,y2
readf,45,x3,y3
close,45
endelse
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
maxval=max(c_image)
get_circle,l,[x0,y0],circle,radius,maxval
get_mask,x0,y0,radius,mask
return
end
