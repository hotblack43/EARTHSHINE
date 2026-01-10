FUNCTION evaluate1,image,x0,y0,r
; 
;	Evaluate correlation between image and circle
;
make_circle,x0,y0,r,x,y
image2=image
image2(x,y)=max(image)
image3=image*0.0
image3(x,y)=1.0
;corr=abs(1./correlate(image3,image,/double))
corr=abs(1d3/total(image3*image))
tvscl,image+image3
return,corr
end
