 PRO getcoordsfromheader,header,x0,y0,radius
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'DISCX0 not in header. Assigning dummy value'
 x0=256.
 endif else begin
 x0=float(strmid(header(jdx),15,9))
 endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'DISCY0 not in header. Assigning dummy value'
 y0=256.
 endif else begin
 y0=float(strmid(header(jdx),15,9))
 endelse
 idx=strpos(header,'DISCRA')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
 print,'DISCRA not in header. Assigning dummy value'
 radius=134.327880000
 endif else begin
 radius=float(strmid(header(jdx),15,9))
 endelse
 return
 end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 exptime=exptime(0)
 return
 end


im1=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_5/2455856.1305427MOON_B_AIR.fits.gz',h1)
im2=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_5/2455857.1554326MOON_B_AIR.fits.gz',h2)
get_EXPOSURE,h1,exptime1
im1=im1/exptime1
factor=50000./max(im1)
im1=im1*factor
get_EXPOSURE,h2,exptime2
im2=im2/exptime2
im2=im2*factor
getcoordsfromheader,h1,x0,y0,radius
im1=shift(im1,256-x0,256-y0)
getcoordsfromheader,h2,x0,y0,radius
im2=shift(im2,256-x0,256-y0)
tvscl,[im1,im2]
plot,avg(im1(*,246:266),1),yrange=[6,20]
oplot,avg(im2(*,246:266),1)+4.5,color=fsc_color('red')
end

