x=fltarr(100)*0+999
y=fltarr(100)*0+999
i=0
for upper_limb=20.0,0.5,-0.5 do begin
lower_limb=upper_limb-0.5
scale=2.0*212./0.5		; pixels per degree
apparent_top_to_bootom=(CO_REFRACT(upper_limb,/to_observed)-CO_refract(lower_limb,/to_observed))*scale
apparent_side_to_side=0.5*scale
x(i)=(upper_limb+lower_limb)/2.
y(i)=apparent_side_to_side-apparent_top_to_bootom
i=i+1
endfor
idx=where(x ne 999)
plot,y(idx),x(idx),xtitle='Moon altitude (degrees)',ytitle='diameters diff. (pixels)'
end
