@stuff104
PRO make_circle,x0,y0,radius,circle
circle=dblarr(512,512)*0.0
angstep=asin(1.0d0/radius)/3./!dtor
angstep=(angstep)(0)
for iangle=0.0,360.0d0,angstep do begin
x=x0+radius*cos(iangle*!dtor)
y=y0+radius*sin(iangle*!dtor)
circle(x,y)=1.0d0
endfor
return
end


im=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_4/2455945.1776847MOON_V_AIR_DCR.fits',h)
getcoordsfromheader,h,x0,y0,radius,discra
im=readfits('2455945.1776847MOON_V_AIR.fits.gz')
im=avg(im,2)
im=im/smooth(im,3)-1.0d0
tvscl,hist_equal(im)
make_circle,x0,y0,radius,circle
whitecircle=circle
make_circle,x0,y0,radius+1,circle
darkcircle=circle*(-1)
whitesum=total(whitecircle*im)
darksum=total(darkcircle*im)
print,whitesum,darksum
bestsum=-1e22
best_dx=0
best_dy=0
step=0.098767654d0
for dx=-2.0,2.0,step do begin
for dy=-2.0,2.0,step do begin
shiftedwhitecircle=shift_sub(whitecircle,dx,dy)
shiftedblackcircle=shift_sub(darkcircle,dx,dy)
whitesum=total(shiftedwhitecircle*im)
darksum=total(shiftedblackcircle*im)
print,dx,dy,whitesum,darksum,whitesum+darksum,best_dx,best_dy,bestsum
if (whitesum+darksum gt bestsum) then begin
	bestsum=whitesum+darksum
	best_dx=dx
	best_dy=dy
idx=where(shiftedwhitecircle gt 0)
jdx=where(shiftedblackcircle lt 0)
imsho=im
imsho(jdx)=max(im)/3
imsho(idx)=min(im)/3
tvscl,imsho
endif
endfor
endfor
end

