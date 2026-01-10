PRO fit_moon1,file,orgimage,x0_in,y0_in,r_in,x0,y0,r
; PURPOSE   - to find the center and radius of the Moon in the image orgimage
; INPUTS    - file,x0_in,y0_in,r_in: filename and initial guesses of center and radius
; OUTPUTS   - x0,y0,r
;----------------------------------------------------
;	Note - fits a circle
;----------------------------------------------------
common moon,image
x0=x0_in
y0=y0_in
r=r_in
image=orgimage
tot1=total(image)
despeckle,image
tot2=total(image)
print,'despeckling removed ',tot1-tot2
;
a=[x0,y0,r]
xi=[[1,0,0],[0,1,0],[0,0,1]]
ftol=1.e-8
POWELL,a,xi,ftol,fmin,'petersfunc1'
;
x0=a(0)
y0=a(1)
r=a(2)
;
if (r gt 220 or r lt 200) then begin
	r=212
	POWELL,a,xi,ftol,fmin,'petersfunc1'
endif
;
return
end
