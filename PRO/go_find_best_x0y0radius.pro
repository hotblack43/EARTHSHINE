PRO go_find_best_x0y0radius,x0_out,y0_out,radius_out
 common stuff,FFTideal,observed,ideal,maxerr,n,llim,rrlim,dlim,ulim,tstr,x0,y0,radius,mask,r,header
a='q'
while (a ne 'q') do begin
	im=observed
	make_circle,x0,y0,radius,x,y
	im(x,y)=3.*max(observed)
	contour,im,/isotropic
	a=get_kbrd(1)
	if (a eq 'b') then radius=radius*1.004
	if (a eq 's') then radius=radius/1.004
	if (a eq 'r') then x0=x0+0.73
	if (a eq 'l') then x0=x0-0.73
	if (a eq 'u') then y0=y0+0.73
	if (a eq 'd') then y0=y0-0.73
endwhile
x0_out=x0
y0_out=y0
radius_out=radius
return
end
