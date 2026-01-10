 PRO getJDfromheader,header,JD
 idx=where(strpos(header,'DATE') ne -1)
 line=header(idx)
 line=strmid(line,11,strlen(line)-1)
 line=strmid(line,0,19)
 yyyy=fix(strmid(line,0,4))
 mm=strmid(line,5,2)
 dd=strmid(line,8,2)
 hh=strmid(line,11,2)
 mi=strmid(line,14,2)
 ss=strmid(line,17,2)
 JD=double(julday(mm,dd,yyyy,hh,mi,ss))
 return
 end

PRO getphasefromJD,JD,phase
 MOONPHASE,jd(0),phase_angle_M,alt_moon,alt_sun,obsname
 phase=phase_angle_M
 return
 end
 
 PRO getexposure,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 

!P.MULTI=[0,1,2]
!P.CHARSIZE=1.6
; Get AERONET data
;data=get_data('../AERONET/plotmeAERONET_2011_2012.dat')
data=get_data('../AERONET/plotmeAERONET_H_2011_2012.dat')
jdabscoeff=reform(data(0,*))
abscoeff=reform(data(1,*))
;----------- 
openw,22,'all_halo_slopes.dat'
files=file_search('/media/thejll/OLDHD/CUBES/cube_*',count=nB)
for i=0,nB-1,1 do begin
	stack=readfits(files(i),Bheader,/silent)
	im=reform(stack(*,*,0))
        get_info_from_header,Bheader,'DISCX0',x0
        get_info_from_header,Bheader,'DISCY0',y0
        get_info_from_header,Bheader,'RADIUS',radius
	getJDfromheader,Bheader,JD
        getphasefromJD,JD,phase
        getexposure,Bheader,Bexposure
	;print,jd,Bexposure,phase,x0,y0,radius
;
imtoshow=im
	l=size(im,/dimensions)
theta=fltarr(l(0),l(1))
radii=fltarr(l(0),l(1))
for icol=0,l(0)-1,1 do begin
for irow=0,l(1)-1,1 do begin
    theta(icol,irow)=atan((irow-y0)/(icol-x0))/!dtor
    radii(icol,irow)=sqrt((irow-y0)^2+(icol-x0)^2)-radius
endfor
endfor
dr=5
openw,44,'profile.dat'
for deltar=1,512,dr do begin
idx=where(radii gt deltar and radii lt deltar+dr)
if (n_elements(idx) gt 100) then begin
;imtoshow(idx)=max(imtoshow)
;contour,/isotropic,imtoshow,/cell_fill,nlevels=101
;print,deltar,max(im(idx))
printf,44,deltar,max(im(idx))
endif
endfor
close,44
data=get_data('profile.dat')
r=reform(data(0,*))
y=reform(data(1,*))
r=alog10(r)
y=alog10(y)
plot,r,y,psym=7,xtitle='log!d10!n(r)',ytitle='Halo profile and fit'
res=robust_linefit(r,y,yhat,sig,coef_sig)
oplot,r,yhat,color=fsc_color('red')
residual=((yhat-y)/y)*100.
error_1_2=max(abs(residual(where(r gt 1 and r lt 2))))
xyouts,/normal,0.2,0.9,'Slope error: '+string(coef_sig(1),format='(f10.5)')
xyouts,/normal,0.2,0.85,'MAX res (%) : '+string(error_1_2,format='(f10.5)')
oplot,[1.0,1.0],[!Y.crange],linestyle=2
oplot,[2.0,2.0],[!Y.crange],linestyle=2
;
plot,yrange=[-10,10],xstyle=3,ystyle=3,r,residual,ytitle='Errror in %',xtitle='log!d10!n(r)'
oplot,[1.0,1.0],[!Y.crange],linestyle=2
oplot,[2.0,2.0],[!Y.crange],linestyle=2
oplot,[!x.crange],[0,0],linestyle=2
; interpolate in AERONET data
AEROinterpolated=INTERPOL(abscoeff,jdabscoeff,jd)
fmt='(f15.7,3(1x,f10.4),1(1x,e15.5),1x,f7.2)'
print,format=fmt,jd,res(1),coef_sig(1),sig,AEROinterpolated,error_1_2
printf,22,format=fmt,jd,res(1),coef_sig(1),sig,AEROinterpolated,error_1_2
;a=get_kbrd()
endfor
close,22
end
