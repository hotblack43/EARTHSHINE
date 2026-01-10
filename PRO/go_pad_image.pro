FUNCTION go_pad_image,imin
; find the average mean along the sidesof the input frame
l=size(imin,/dimensions)
av1=median(imin(0,*))
av2=median(imin(*,0))
av3=median(imin(*,l(1)-1))
av4=median(imin(l(1)-1,*))
;av=median([av1,av2,av3,av4])
av=min([av1,av2,av3,av4])
print,'Found this edge value:',av
pad=dblarr(l(0),l(1))*0.0+av
row1=[pad,pad,pad]
row2=[pad,imin,pad]
row3=[pad,pad,pad]
out=[[row1],[row2],[row3]]
return,out
end
