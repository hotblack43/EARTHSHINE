FUNCTION evaluate,image,x0,y0,r
make_circle,x0,y0,r,x,y
image2=image
image3=image*0.0
image2(x,y)=max(image)
image3(x,y)=1.0
corr=abs(1./correlate(image3,image,/double))
tvscl,image+image3
return,corr
end
