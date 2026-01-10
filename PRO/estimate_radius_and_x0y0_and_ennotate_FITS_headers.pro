PRO gettheqlag1,h,qflag1
qflag1=314
 ipos=where(strpos(h,'Q_FLAG_1') ne -1)
if (ipos(0) ne -1) then begin
 str=strmid(h(ipos),12,19)
 qflag1=fix(str)
endif
return
end

 PRO godotherequirederotation,im,x0,y0
; will apply a 7 degree clockwise rotation of the input image
im=ROT(im,7.0,1.0,x0,y0,/pivot)
 return
 end

PRO goupdatetheJDheader,x0,y0,radius,header
         sxaddpar, header, 'RADIUS', radius(0), 'Radius estimated from JD '
return
end

FUNCTION MOONradius,jd
common datas,jd_table,t_table
a=-2.4284301d0
b=3.0414863d0
traveltime=INTERPOL(t_table,jd_table,jd)
radius = a + b/traveltime
return,radius
end

PRO goupdatethehedaer,x0,y0,radius,header
         sxaddpar, header, 'DISCX0', x0(0), 'Estimated centre column coordinate'
         sxaddpar, header, 'DISCY0', y0(0), 'Estimated centre row coordinate'
         sxaddpar, header, 'DISCRA', radius(0), 'Disc radius estimated from image'
return
end

 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end

PRO godoitbetter,startguess_in,im,x0,y0,r0
findbettercircle,im,startguess_in,x0,y0,r0
startguess=[x0,y0,r0,2.,1.]
findbettercircle,im,startguess,x0,y0,r0 
startguess=[x0,y0,r0,1.,.33]
findbettercircle,im,startguess,x0,y0,r0 
startguess=[x0,y0,r0,.4,.13]
findbettercircle,im,startguess,x0,y0,r0 
startguess=[x0,y0,r0,.2,.07]
findbettercircle,im,startguess,x0,y0,r0 
return
end

pro findbettercircle,sicle,startguess,x0,y0,r0
; will find a better fitting circle, giving a starting guess
get_lun,poi
openw,poi,'trash13.dat'
w=startguess(3)
stepsize=startguess(4)
idx=where(sicle eq 1)
coords=array_indices(sicle,idx)
x=coords(0,*)
y=coords(1,*)
n=n_elements(idx)
ic=0
for ix=startguess(0)-w,startguess(0)+w,stepsize do begin
for iy=startguess(1)-w,startguess(1)+w,stepsize do begin
for rad=startguess(2)-w,startguess(2)+w,stepsize do begin
isum=0
for j=0,n-1,1 do begin
radtest=sqrt((x(j)-ix)^2+(y(j)-iy)^2)
if (abs(radtest-rad) lt 1.0) then isum=isum+1
endfor
printf,poi,ix,iy,rad,isum
endfor
endfor
endfor
close,poi
free_lun,poi
data=get_data('trash13.dat')
x=reform(data(0,*))
y=reform(data(1,*))
r=reform(data(2,*))
tot=reform(data(3,*))
idx=where(tot eq max(tot))
print,'maxtot:',max(tot)
if (n_elements(idx) eq 1) then begin
x0=x(idx)
y0=y(idx)
r0=r(idx)
endif
if (n_elements(idx) gt 1) then begin
x0=x(idx(0))
y0=y(idx(0))
r0=r(idx(0))
endif
end

 PRO fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
 ; Fits a circle that passes through the three designated coordinates
 a=[[x1,y1,1.0],[x2,y2,1.0],[x3,y3,1.0]]
 d=[[x1*x1+y1*y1,y1,1.0],[x2*x2+y2*y2,y2,1.0],[x3*x3+y3*y3,y3,1.0]]
 e=[[x1*x1+y1*y1,x1,1.0],[x2*x2+y2*y2,x2,1.0],[x3*x3+y3*y3,x3,1.0]]
 f=[[x1*x1+y1*y1,x1,y1],[x2*x2+y2*y2,x2,y2],[x3*x3+y3*y3,x3,y3]]
 a=determ(a,/check,/double)
 d=-determ(d,/check,/double)
 e=determ(e,/check,/double)
 f=-determ(f,/check,/double)
 ;
 x0=-d/2./a
 y0=-e/2./a
 radius=sqrt((d*d+e*e)/4./a/a-f/a)
 return
 end
 
 
 
 PRO gostripthename,str,fitsname
 ;xx=strpos(str,'245')
 ;fitsname=strmid(str,xx,strlen(str)-xx)
 str2=strsplit(str,'/',/extract)
 fitsname=str2(n_elements(str2)-1)
 return
 end
 
 PRO gofindradiusandcenter,im_in,x0,y0,radius
 common rememberthis,firstguess
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 ; im=laplacian(im,/CENTER)
 im=SOBEL(im)
 ; im treshold and remove some single pixels
 idx=where(im gt max(im)/4.)
 jdx=where(im le max(im)/4.)
 im(idx)=1
 im(jdx)=0
 imuselater=im
 ; remove specks
 im=median(im,3)
 writefits,'inputimageforsicle.fits',im_in
 writefits,'sicle.fits',im
 ; find good estimates of the circle radius and centre
 ntries=100
 idx=where(im ne 0)
 coords=array_indices(im,idx)
 nels=n_elements(idx)
 get_lun,rew
 openw,rew,'trash2.dat'
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
     printf,rew,x0,y0,radius
     endfor
 close,rew
 free_lun,rew
 spawn,'grep -v NaN trash2.dat > aha2.dat'
 spawn,'mv aha2.dat trash2.dat'
 data=get_data('trash2.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 get_lun,iuy & openw,iuy,'circle.dat' & printf,iuy,x0,y0,radius & close,iuy & free_lun,iuy
 firstguess=[x0,y0,radius]
 ; So, that was a robust first guess - but not good enough! Using the first guess we go on and (hopefully) improve
print,'First guess x0,y0,r0:',firstguess
startguess=[x0,y0,radius,7,2]
godoitbetter,startguess,imuselater,x0,y0,radius
print,'Best x0,y0,r0:',x0,y0,radius
get_lun,iuy & openw,iuy,'circle.dat' & printf,iuy,x0,y0,radius & close,iuy & free_lun,iuy
if (n_elements(x0) gt 1 or n_elements(y0) gt 1 or n_elements(radius) gt 1) then stop
 return
 end
 







;--------------------------------------------------------------------------------
; will take a FITS file of the Moon and estimate the radius
; of the disc from the relation based on JD, and estimate disc centre based on
; a fitting routine, and write new keywords into the FITS header
; Will also rotate the image by 7 degrees to compensate for HW problem, on some images.
;--------------------------------------------------------------------------------
; get the travel time file
common datas,jd_table,t_table
file='HORIZONS/traveltime.dat'
data=get_data(file)
jd_table=reform(data(0,*))
t_table=reform(data(1,*))
;.............................
files='listofFITSfilestoannotate.txt'
openr,1,files
while not eof(1) do begin
name=''
readf,1,name
print,'Read ',name,' from ',files
name=strcompress(name,/remove_all)
im=readfits(name,header,/silent)
; do not further process any image with Q_FLAG_1 neq 0
gettheqlag1,header,qflag1
if (qflag1 ne 0) then print,'Skipping, - since qflag1 ne 0 - the file: ',name
if (qflag1 eq 0) then begin
l=size(im)
if (l(0) gt 2) then stop
;.............................
get_time,header,JD
gofindradiusandcenter,im,x0,y0,radius
goupdatethehedaer,x0,y0,radius,header
JDradius=MOONradius(jd)
print,'Two estimates of radius: ',radius,JDradius
goupdatetheJDheader,x0,y0,JDradius,header
gostripthename,name,fitsname
print,'Stripped filename:',fitsname
; if necessary, rotate the image
         if (JD lt 2455886.0d0) then begin
         godotherequirederotation,im,x0,y0
         sxaddpar, header, 'ROTATED', 7, 'degrees clockwise, about x0,y0 '
         endif
writefits,strcompress('MOVEME/'+fitsname,/remove_all),im,header
endif
endwhile
close,1
print,'Output is now in MOVEME/ - deal with it'
end
