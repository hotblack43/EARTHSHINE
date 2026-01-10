dark=float(readfits('../CCD/median_dark_fram.fit'))
;im=float(readfits('/home/pth/Pinhole_500s_nobaffle.fit'))-dark
im=float(readfits('/home/pth/Pinhole_500s_nobaffle.fit'))
im=median(im,3)
l=size(im,/dimensions)
idx=where(im eq max(im))
place=long(idx(0))
x0=368.67871     
y0=134.11412
step=0.97433
filler=median(im)
for angle=0.0,360-step,step do begin
	rotated=rot(im,angle,1.0,x0,y0,/interp,missing=filler)
	if angle eq 0 then sum=rotated
	if angle ne 0 then sum=sum+rotated
;	tvscl,alog(sum)
endfor
; clip
l=size(sum,/dimensions)
plot_io,total(sum(*,l(1)/2.-20:l(1)/2.+20),2),title='No baffle',yrange=[1e7,1e9],ystyle=1
keep1=total(sum(*,l(1)/2.-20:l(1)/2.+20),2)
im=float(readfits('/home/pth/Pinhole_500s_baffle1.fit'))
;im=float(readfits('/home/pth/Pinhole_500s_baffle1.fit'))-dark
im=median(im,3)
l=size(im,/dimensions)
idx=where(im eq max(im))
place=long(idx(0))
x0=288.96341
y0=132.34941
step=0.97433
filler=median(im)
for angle=0.0,360-step,step do begin
	rotated=rot(im,angle,1.0,x0,y0,/interp,missing=filler)
	if angle eq 0 then sum=rotated
	if angle ne 0 then sum=sum+rotated
;	tvscl,alog(sum)
endfor
; clip
l=size(sum,/dimensions)
keep2=total(sum(*,l(1)/2.-20:l(1)/2.+20),2)
factor=mean(keep1(0:200))/mean(keep2(0:200))
oplot,factor*total(sum(*,l(1)/2.-20:l(1)/2.+20),2),linestyle=2
plot,keep1-factor*total(sum(*,l(1)/2.-20:l(1)/2.+20),2)
;plot_io,total(sum(*,l(1)/2.-20:l(1)/2.+20),2),title='Baffle',yrange=[1e5,1e9],ystyle=1
end
