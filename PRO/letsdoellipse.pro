PRO letsdoellipse,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2,bestcorr,orgimage,imnum,imstart
common angles,angle_Grimaldi,angle_crisium

fit_moon2,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2
if (bestcorr gt 5) then begin
tvscl,orgimage
print,'CLICK ON LEFT EDGE OF MOON.'
cursor,aL,bL,/device
wait,0.5
print,'CLICK ON RIGHT EDGE OF MOON.'
cursor,aR,bR,/device
r=abs(aR-aL)/2.0
x00=aL+r
y00=(bL+bR)/2.
fit_moon2,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2
endif
x00=x0
y00=y0
radius1=r1
radius2=r2
fmt='(a,4(1x,f8.3))'
printf,55,format=fmt,'Centre and radii : ',x00,y00,r1,r2
save_fitted_pars_ellipse,file,x00,y00,radius1,radius2
save_lastfit_ellipse,file,x00,y00,radius1,radius2
;
; First look at Grimaldi
;
iregion='Grimaldi'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_Grimaldi
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_Grimaldi,file,iregion
;
; Then look at Crisium
;
iregion='Crisium'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_crisium
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_crisium,file,iregion
;
return
end
