read_jpeg,'sky.jpg',im
im=total(im,1)
l=size(im,/dimensions)
print,'Click on the centre'
contour,im
cursor,a,b
print,a,b
wait,1
print,'Click on the circumference'
cursor,a1,b1
print,a1,b1
radius=sqrt((a-a1)^2+(b-b1)^2)
mask=im*1
meshgrid,l(0),l(1),x,y
r=sqrt((x-a)^2+(y-b)^2) ; unit is pixels
idx=where(r gt radius)
mask(idx)=0
array=im*mask
tvscl,array
; 
read_jpeg,'sky2.jpg',im2
im2=total(im2,1)
tvscl,im-im2
end
