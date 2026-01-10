 PRO get_Isun,h,Isun
; ISUN    =        1412.36303487 / Sun intensity  
 ipos=where(strpos(h,'ISUN') ne -1)
 date_str=strmid(h(ipos),11,21)
 ISUN=float(date_str)
 return
 end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

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
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),15,9))
     endelse
 return
 end

angles=readfits('OUTPUT/Angles_JD2455865.7628125.fits',h)
get_Isun,h,Isun
theta_i=reform(angles(*,*,0))
theta_i=reverse(theta_i,2)
theta_r=reform(angles(*,*,1))
im=readfits('/data/pth/DARKCURRENTREDUCED/SELECTED_1/2455865.7628170MOON_V_AIR_DCR.fits',h)
bias=readfits('superbias.fits')
im=im-bias
get_EXPOSURE,h,exptime
getcoordsfromheader,h,x0,y0,radius
print,x0,y0,radius
im=shift(im,256-x0,256-y0)
openw,4,'minnaert.dat'
fmtstr='(1x,f12.2,4(1x,f13.8))'
lim=0.1*max(im)
for i=0,511,1 do begin
for j=0,511,1 do begin
if (im(i,j) gt lim and theta_i(i,j) ne 0 and theta_r(i,j) ne 0) then begin
printf,4,format=fmtstr,im(i,j)/exptime/Isun,theta_i(i,j),theta_r(i,j),alog(im(i,j)/exptime/Isun*cos(theta_r(i,j))),alog(cos(theta_i(i,j))*cos(theta_r(i,j)))
endif
endfor
endfor
close,4
writefits,'im.fits',im
writefits,'theta_i.fits',theta_i
writefits,'theta_r.fits',theta_r
data=get_data('minnaert.dat')
x=reform(data(3,*))          
y=reform(data(4,*))          
idx=where(finite(x) eq 1 and finite(y) eq 1)
x=x(idx)
y=y(idx)
plot,x,y,psym=3,/isotropic 
res=robust_linefit(x,y,yhat,sig,sigs)
oplot,x,yhat,color=fsc_color('red')
print,'Intercept : ',res(0),' +/- ',sigs(0)
print,'k         : ',res(1),' +/- ',sigs(1)
end

