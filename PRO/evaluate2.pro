FUNCTION evaluate2,image,x0,y0,r1,r2
make_ellipse,x0,y0,r1,r2,x,y
image2=image
image3=image*0.0
image2(x,y)=max(image)
image3(x,y)=1.0
;corr=abs(1./correlate(image3,image,/double))
number=total(image3*image)
corr=abs(1d3/number)
tvscl,image+image3
return,corr
end
