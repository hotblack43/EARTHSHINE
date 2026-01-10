 PRO get_phaseangle,h,PHSAN_E
 ipos=where(strpos(h,'PHSAN_E') ne -1)
 date_str=strmid(h(ipos),11,21)
 PHSAN_E=float(date_str)
 return
 end

PRO parse,str,anglename,selectedname
l=strsplit(str,' ',/extract)
anglename=l(0)
selectedname=l(1)
return
end

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

;-----------------------------------------------------------
;-----------------------------------------------------------
bias=readfits('superbias.fits',/sil)
openr,1,'minnaert_images_list_Vb.txt'
openw,44,'minnaert_output.txt'
while not eof(1) do begin
str=''
readf,1,str
parse,str,anglename,selectedname
print,'names: ',anglename,selectedname
angles=readfits(anglename,h,/sil)
get_Isun,h,Isun
get_phaseangle,h,PHSAN_E
theta_i=reform(angles(*,*,0))
;theta_i=reverse(theta_i,2)
theta_i=reverse(theta_i,1)
theta_r=reform(angles(*,*,1))
im=readfits(selectedname,h,/sil)
im=im-bias
get_EXPOSURE,h,exptime
getcoordsfromheader,h,x0,y0,radius
im=shift(im,256-x0,256-y0)
window,2,xsize=512*2/2,ysize=512/2
tvscl,[rebin(theta_i/max(theta_i),256,256),rebin(im/max(im),256,256)]
openw,4,'minnaert.dat'
fmtstr='(6(1x,f15.7))'
lim=0.2*max(im)
for i=0,511,1 do begin
for j=0,511,1 do begin
if (im(i,j) gt lim and theta_i(i,j) ne 0 and theta_r(i,j) ne 0) then begin
mu=cos(theta_r(i,j))
mu0=cos(theta_i(i,j))
observedflux=im(i,j)/exptime
Incidentflux=Isun*!pi*mu0
r=observedflux/Incidentflux
printf,4,format=fmtstr,mu,mu0,alog(r*mu),alog(mu*mu0),observedflux,Incidentflux
endif
endfor
endfor
close,4
writefits,'im.fits',im
writefits,'theta_i.fits',theta_i
writefits,'theta_r.fits',theta_r
data=get_data('minnaert.dat')
y=reform(data(2,*))          
x=reform(data(3,*))          
idx=where(finite(x) eq 1 and finite(y) eq 1)
if (n_elements(idx) gt 3) then begin
x=x(idx)
y=y(idx)
window,3
plot,x,y,psym=3,/isotropic 
res=robust_linefit(x,y,yhat,sig,sigs)
oplot,x,yhat;,color=fsc_color('red')
print,'Intercept : ',res(0),' +/- ',sigs(0)
print,'k         : ',res(1),' +/- ',sigs(1)
printf,44,format='(f9.4,2(1x,f10.5))',PHSAN_E,res(0),res(1)
endif
stop
endwhile
close,1
close,44
print,'You now have output in file "minnaert_output.txt"'
end

