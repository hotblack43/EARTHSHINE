FUNCTION petersfunc1,a
;
;	A circle is fitted
;
 peakval=a(0)
 widthfactor=a(1)
get_kernel,PSF,peakval,widthfactor
ratio=FFT(observed,-1,/double)/FFT(PSF,-1,/ideal)
result=FFT(ratio,1,/double)
negs=n_elements(where(result lt 0.0))
return,negs
end


PRO fit_moon1,orgimage,x0_in,y0_in,r_in,x0,y0,r
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
;tot1=total(image)
;despeckle,image
;tot2=total(image)
;print,'despeckling removed ',tot1-tot2
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

	POWELL,a,xi,ftol,fmin,'petersfunc1'

;
return
end

PRO letsdocircle,image,x00,y00,radius,x0,y0,r
common facts,probableradius,probablex00,probabley00

fit_moon1,image,x00,y00,radius,x0,y0,r

print,'Centre and radius: ',x0,y0,r

return
end

FUNCTION evaluate1,image,x0,y0,r
;
;	Evaluate correlation between image and circle
;
make_circle,x0,y0,r,x,y
image3=image*0.0
image3(x,y)=max(image)
image2=sobel(image)
;despeckle,image2
corr=abs(1d3/total(image3*image2))
tvscl,image+image3

return,corr
end





PRO make_circle,x0,y0,r,x,y
angle=findgen(1000)/1000.*360.0
ran=randomu(seed)
angle1=angle*!dtor+ran
angle2=angle*!dtor-ran
idx=where(angle lt 90 or angle gt 270)
angle=angle(idx)
idx=where(angle1 lt !pi/2. or angle1 gt !pi*1.5)
angle1=angle1(idx)
idx=where(angle2 lt !pi/2. or angle2 gt !pi*1.5)
angle2=angle2(idx)

x=fix(x0+r*cos(angle*!dtor))
y=fix(y0+r*sin(angle*!dtor))

; make another layer outside first

x=[x,fix(x0+(r+1)*cos(angle1))]
y=[y,fix(y0+(r+1)*sin(angle1))]
; make another layer inside other two
x=[x,fix(x0+(r-1)*cos(angle2))]
y=[y,fix(y0+(r-1)*sin(angle2))]

return
end


PRO scaleANDshift,im_in,factor,dx,dy
; scale im_in UP by factor, then shift, the scale DOWN again
l=size(im_in,/dimensions)
im_in=congrid(im_in,l(0)*factor,l(1)*factor,/INTERP)
im_in=shift(im_in,dx*factor,dy*factor)
im_in=congrid(im_in,l(0),l(1),/INTERP)
return
end

;========================================
;
;   Code to divide images by one another, after centering
;
;========================================
common keep,bestcorr
common info,JD,imnum
common facts,probableradius,probablex00,probabley00
common results,corrected_im
;..........................................
loadct,6
device,decomposed=0
bestcorr=-9e10
openw,55,'divide_images.out'
kept_bestXshift=0.0
kept_bestYshift=0.0
;path='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\DATA'
path='/home/pth/moon/ANDREW/DATA/
files=file_search(path,'*.FIT',count=nfiles)
dark=readfits(path+'\sydneydark.fit')
im0_in=readfits(files(0))-dark
l=size(im0_in,/dimensions)
factor=5
; find center and radius by POWELL's method
x00=170.103
y00=260.215
radius=112.077
window,0,xsize=l(0),ysize=l(1)
letsdocircle,im0_in,x00,y00,radius,x0,y0,r
im0_xshift=x0
im0_yshift=y0

for ifile=1,nfiles-1,1 do begin
bestcorr=-9e10
    im_in=readfits(files(ifile))-dark
	letsdocircle,im_in,x0,y0,r,xoffset_optimum,yoffset_optimum,r

	scaleANDshift,im_in,factor,im0_xshift-xoffset_optimum,im0_yshift-yoffset_optimum
print,moment(im_in)
print,moment(im0_in)
   z=im_in/im0_in
window,2
loadct,0
tvscl,alog(z)
window,0
loadct,6
print,ifile,moment(z)
endfor
close,55
end
