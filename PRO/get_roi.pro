PRO get_roi,reference,circle,maxval
  l=size(reference,/dimensions)
  window,3,xsize=500,ysize=500
  contour,reference,/isotropic
	print,'Click on three points on the circumference of the Moon'
	cursor,x1,y1
	wait,0.3
	print,x1,y1
	cursor,x2,y2
	wait,0.3
	print,x2,y2
	cursor,x3,y3
	wait,0.3
	print,x3,y3
fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
show=reference
get_circle,l,[x0,y0],circle,radius,maxval
return
end
