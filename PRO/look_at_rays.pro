PRO get_circle,l,coords,circle,radius,maxval
circle=fltarr(l)*0.0
astep=0.1d0
x0=coords(0)
y0=coords(1)
for angle=0.0d0,360.0d0-astep,astep do begin
	x=x0+radius*cos(angle*!dtor)
	y=y0+radius*sin(angle*!dtor)
	circle(x,y)=maxval
endfor
return
end
;==================== MAIN PROGRAMME ===============
file='sydney_2x2.fit'
im=readfits(file)
l=size(im,/dimensions)
;----------------------------------------------------------
; Get the circle that describes Moon/Sky
radius=59.5
moon_coords=[76,86]
get_circle,l,moon_coords,circle,radius,max(im)
!P.MULTI=[0,1,1]
loadct,2
contour,alog(im+circle),/isotropic,/cell_fill,nlevels=101,xstyle=1,ystyle=1
;----------------------------------------------------------
; Make rays
!P.MULTI=[0,4,4]
x0=moon_coords(0)
y0=moon_coords(1)
astep=22.0
openw,12,'data.dat'
for iangle=0,360-astep,astep do begin
	contour,(im),/isotropic,/cell_fill,xstyle=1,ystyle=1
	for r=radius,1000,1 do begin
		x=x0+r*cos(iangle*!dtor)
		y=y0+r*sin(iangle*!dtor)
		if ((x ge 0 and x le l(0)-1) and (y ge 0 and y le l(1)-1)) then begin
			printf,12,r,total(im(x+indgen(5)-1,y+indgen(5)-1)),iangle
			printf,12,r,im(x,y),iangle

			plots,x,y,psym=3
		endif
	endfor
;	stop
endfor
close,12
;-----------------------------------
; plot the rays
data=get_data('data.dat')
r=reform(data(0,*))
y=reform(data(1,*))
angle=reform(data(2,*))
uniqangles=angle(uniq(angle(sort(angle))))
nangles=n_elements(uniqangles)
for iangle=0,nangles-1,1 do begin
	idx=where(angle eq uniqangles(iangle))
	plot,r(idx),y(idx),psym=-7,title='Angle='+string(uniqangles(iangle)),ystyle=1, $,xstyle=1
		xtitle='Distance from Moon center',ytitle='Sky pixel value'
endfor
end