PRO fit_moon2,file,orgimage,x0_in,y0_in,r1_in,r2_in,x0,y0,r1,r2
; PURPOSE   - to find the center and radii of the Moon in the image orgimage
; INPUTS    - file,x0_in,y0_in,r1_in,r2_in: filename and initial guesses of center and radii
; OUTPUTS   - x0,y0,r1,r2
;----------------------------------------------------
; 	Note - fits an ellipse
;----------------------------------------------------
common moon,image
x0=x0_in
y0=y0_in
r1=r1_in
r2=r2_in
image=orgimage
;
a=[x0,y0,r1,r2]
xi=[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
ftol=1.e-6
POWELL,a,xi,ftol,fmin,'petersfunc2'
;print,xi
;
x0=a(0)
y0=a(1)
r1=a(2)
r2=a(3)
;
return
end
