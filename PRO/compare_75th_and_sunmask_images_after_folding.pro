PRO gogetjulianday,header,jd
idx=strpos(header,'JULIAN')
str=header(where(idx ne -1))
jd=double(strmid(str,15,15))
return
end

PRO gofindradiusandcenter,im_in,x0,y0,radius
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 im=sobel(im)
 ;im=laplacian(im,/CENTER)
 ; im treshold and remove some single pixels
 idx=where(im gt max(im)/4.)
 jdx=where(im le max(im)/4.)
 im(idx)=1
 im(jdx)=0
 ; remove specks
 im=median(im,3)
 ; find good estimates of the circle radius and centre
 ntries=100
 idx=where(im ne 0)
 coords=array_indices(im,idx)
 nels=n_elements(idx)
 openw,49,'trash.dat'
 for i=0,ntries-1,1 do begin 
     irnd=randomu(seed)*nels
     x1=reform(coords(0,irnd))
     y1=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x2=reform(coords(0,irnd))
     y2=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x3=reform(coords(0,irnd))
     y3=reform(coords(1,irnd))
     ;oplot,[x1,x1],[y1,y1],psym=7
     fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
     printf,49,x0,y0,radius
     endfor
 close,49
 data=get_data('trash.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 return
 end

PRO gofindDSBS,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS
; determine if BS is to the right or the left of the center
factor=3./4.;	2./3.	; where toputthe patch
if (cg_x gt x0) then begin
; BS is to the right
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0-radius*factor-w:x0-radius*factor+w,y0-w:y0+w))
plots,[x0-radius*factor,x0-radius*factor],[y0,y0],psym=7
xyouts,x0-radius*factor,y0,'Patch',orientation=45
endif
if (cg_x lt x0) then begin
; BS is to the left
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0+radius*factor-w:x0+radius*factor+w,y0-w:y0+w))
plots,[x0+radius*factor,x0+radius*factor],[y0,y0],psym=7
xyouts,x0+radius*factor,y0,'Patch',orientation=45
endif
return
end

PRO cgfinder,im,cg_x,cg_y
; find c.g.
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)
 cg_y=total(y*im)/total(im)
return
end


PRO normthem,im1,im2
top1=im1(where(im1 eq max(im1)))
im2=im2/max(im2)*top1(0)
return
end
FUNCTION go_pad_image,imin
l=size(imin,/dimensions)
pad=dblarr(l(0),l(1))*0
row1=[pad,pad,pad]
row2=[pad,imin,pad]
row3=[pad,pad,pad]
out=[[row1],[row2],[row3]]
return,out
end



;....................................................
openw,33,'patchpctdiff.dat'
for alfa=1.6,3.0/1.602,0.05 do begin
files=file_search('OUTPUT/Lunar*.fit',count=n)
files2=file_search('OUTPUT/SunMask_*.fit',count=m)
PSF=readfits('TTAURI/PSF_fromHalo_1536.fits')
psf=psf^alfa
FFTpsf=fft(psf,-1,/double)
if (n ne m) then stop

for i=0,n-1,1 do begin
nam1=files(i)
nam2=files2(i)
im1=readfits(nam1,/silent,header)
gogetjulianday,header,jd
mphase,jd,k
im2=readfits(nam2,/silent)
; get rid of pixels notbright enough in image 1
idx=where(im1 lt max(im1)/75.) & im1(idx)=0.0
im1=go_pad_image(im1)
im2=go_pad_image(im2)
im1smeared=fft(fftpsf*fft(im1,-1,/double),1,/double)& im1smeared=double(im1smeared)
im2smeared=fft(fftpsf*fft(im2,-1,/double),1,/double)& im2smeared=double(im2smeared)
im1smeared=im1smeared(512:2*512-1,512:2*512-1)
im2smeared=im2smeared(512:2*512-1,512:2*512-1)
normthem,im1smeared,im2smeared
diff=(im1smeared-im2smeared)/(0.5*(im2smeared+im1smeared))*100.0
kdx=where(diff eq (max(diff)))
coo=array_indices(diff,kdx)
contour,im1smeared,/isotropic,xstyle=3,ystyle=3,/cell_fill
plots,[coo(0),coo(0)],[coo(1),coo(1)],psym=7
;
w=9
cgfinder,im1smeared,cg_x,cg_y
plots,[cg_x,cg_x],[cg_y,cg_y],psym=2
xyouts,cg_x,cg_y,'C.G.',orientation=45
gofindradiusandcenter,im1smeared,x0,y0,radius
plots,[x0,x0],[y0,y0],psym=1
xyouts,x0,y0,'Center',orientation=45
gofindDSBS,im1smeared,im1smeared,x0,y0,radius,cg_x,cg_y,w,BS,DS1
gofindDSBS,im2smeared,im2smeared,x0,y0,radius,cg_x,cg_y,w,BS,DS2
printf,33,format='(f8.4,1x,f15.6,(1x,f8.2),1x,g9.3,2(1x,g11.4))',alfa*1.602,jd,k,ds1,(ds1-ds2)/(0.5*(ds1+ds2))*100.0,max(diff)
print,format='(f8.4,1x,f15.6,(1x,f8.2),1x,g9.3,2(1x,g11.4))',alfa*1.602,jd,k,ds1,(ds1-ds2)/(0.5*(ds1+ds2))*100.0,max(diff)
endfor 
endfor
close,33
end
