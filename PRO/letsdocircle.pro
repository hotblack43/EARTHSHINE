PRO letsdocircle,file,image,x00,y00,radius,x0,y0,r,bestcorr,orgimage,imnum,imstart
common angles,angle_Grimaldi,angle_crisium
common facts,probableradius,probablex00,probabley00

fit_moon1,file,image,x00,y00,radius,x0,y0,r
if (bestcorr gt 10) then begin
	tvscl,orgimage
;	print,'CLICK ON LEFT EDGE OF MOON.'
;	cursor,aL,bL,/device
;	wait,0.5
;	print,'CLICK ON RIGHT EDGE OF MOON.'
;	cursor,aR,bR,/device
;	r=abs(aR-aL)/2.0
;	x00=aL+r
;	y00=(bL+bR)/2.
;make_row_sum_plot,orgimage,x00,y00,radius
;stop
radius=probableradius
x00=probablex00
y00=probabley00
	fit_moon1,file,image,x00,y00,radius,x0,y0,r
endif
x00=x0
y00=y0
radius=r
fmt='(a,3(1x,f8.3))'
printf,55,format=fmt,'Centre and radius: ',x00,y00,radius
save_fitted_pars_circle,file,x00,y00,radius
save_lastfit_circle,file,x00,y00,radius
;
; First look at Grimaldi
;
iregion='Grimaldi'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,r,angle_Grimaldi
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,r,angle_Grimaldi,file,iregion
;
; Then look at Crisium
;
iregion='Crisium'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,r,angle_crisium
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,r,angle_crisium,file,iregion
;
return
end
