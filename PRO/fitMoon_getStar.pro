PRO circlefinder,x1,y1,x2,y2,x3,y3,x0,y0,radius
; will find the center and radius of the circxle that passes through the points (x1,y1),(x2,y2) and (x3,y3)
term1=x1^2+y1^2
term2=x2^2+y2^2
term3=x3^2+y3^2
a=determ([[x1,y1,1.],[x2,y2,1.],[x3,y3,1.]],/double)
d=-determ([[term1,y1,1.],[term2,y2,1.],[term3,y3,1.]],/double)
e=determ([[term1,x1,1.],[term2,x2,1.],[term3,x3,1.]],/double)
f=-determ([[term1,x1,y1],[term2,x2,y2],[term3,x3,y3]],/double)
x0=-d/2./a
y0=-e/2./a
radius=sqrt((d^2+e^2)/4./a^2-f/a)
return
end
FUNCTION petersfunc1,a
;
;	A circle is fitted
;
common moon,image
common keep,bestcorr
x0=a(0)
y0=a(1)
r=a(2)
corr=evaluate1(image,x0,y0,r)
if (corr lt bestcorr) then begin
    print,format='(a,3(1x,f8.3),1x,f8.3)','In petersfunc1:',a,corr
    bestcorr=corr
endif
openw,72,'Moonfit.dat'
printf,72,a(0),a(1),a(2)
close,72
return,corr
end


PRO fit_moon1,file,orgimage,x0_in,y0_in,r_in,x0,y0,r
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
tot1=total(image)
despeckle,image
tot2=total(image)
print,'despeckling removed ',tot1-tot2
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

PRO letsdocircle,file,image,x00,y00,radius,x0,y0,r,bestcorr,orgimage,imnum,imstart
common angles,angle_Grimaldi,angle_crisium
common facts,probableradius,probablex00,probabley00

fit_moon1,file,image,x00,y00,radius,x0,y0,r
if (bestcorr gt 10) then begin
	tvscl,orgimage
;	print,'CLICK ON LEFT EDGE OF MOON.'
;	cursor,aL,bL,/device
;	wait,0.5
;	print,'CLICK ON RIGHT EDGE OF MOON.'
;	cursor,aR,bR,/device
;	r=abs(aR-aL)/2.0
;	x00=aL+r
;	y00=(bL+bR)/2.
;make_row_sum_plot,orgimage,x00,y00,radius
;stop
radius=probableradius
x00=probablex00
y00=probabley00
	fit_moon1,file,image,x00,y00,radius,x0,y0,r
endif
x00=x0
y00=y0
radius=r
fmt='(a,3(1x,f8.3))'
printf,55,format=fmt,'Centre and radius: ',x00,y00,radius
;save_fitted_pars_circle,file,x00,y00,radius
;save_lastfit_circle,file,x00,y00,radius
;
; First look at Grimaldi
;
iregion='Grimaldi'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,r,angle_Grimaldi
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,r,angle_Grimaldi,file,iregion
;
; Then look at Crisium
;
iregion='Crisium'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,r,angle_crisium
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,r,angle_crisium,file,iregion
;
return
end

FUNCTION evaluate1,image,x0,y0,r
;
;	Evaluate correlation between image and circle
;
make_circle,x0,y0,r,x,y
image2=image
image2(x,y)=max(image)
image3=image*0.0
image3(x,y)=1.0
;corr=abs(1./correlate(image3,image,/double))
corr=abs(1d3/total(image3*image))
tvscl,image+image3
return,corr
end

FUNCTION get_data,filename
data = READ_ASCII(filename)
get_data=data.field1
return,get_data
end

PRO make_ellipse,x0,y0,r1,r2,x,y
angle=findgen(3000)/3000.*360.0
x=fix(x0+r1*cos(angle*!dtor))
y=fix(y0+r2*sin(angle*!dtor))
return
end

FUNCTION evaluate2,image,x0,y0,r1,r2
make_ellipse,x0,y0,r1,r2,x,y
image2=image
image3=image*0.0
image2(x,y)=max(image)
image3(x,y)=1.0
;corr=abs(1./correlate(image3,image,/double))
number=total(image3*image)
corr=abs(1d3/number)
tvscl,image+image3
return,corr
end

PRO find_feature,orgimage,image,x0,y0,r,angle
tvscl,orgimage
print,'CLICK ON FEATURE!!'
cursor,a,b,/device
plots,[a,a],[b,b],psym=7,/device
plots,[x0,x0],[y0,y0],psym=6,/device
angle=atan((y0-b)/(x0-a))/!dtor
print,'Angle found was:',angle,' degrees',(y0-b)/(x0-a)
return
end

PRO make_fan,orgimage,image,x0,y0,r,angle,file,iregion
;	help,orgimage,image,x0,y0,r,angle,file,iregion
;
common info,JD,imnum
common results,corrected_im
if_display=1    ; want TVSCL???
; now make fan...
l=size(image,/dimensions)
radii=fltarr(l)
theta=fltarr(l)
xline=intarr(l)
yline=intarr(l)
for icol=0,l(0)-1,1 do begin
for irow=0,l(1)-1,1 do begin
    xline(icol,irow)=icol
    yline(icol,irow)=irow
    radii(icol,irow)=sqrt((icol-x0)^2+(irow-y0)^2)
    theta(icol,irow)=atan((irow-y0)/(icol-x0))/!dtor
endfor
endfor
if (iregion eq 'Grimaldi') then begin
    step=6.8976
    radstep=r/27.54
    radstep=r/31.
endif
if (iregion eq 'Crisium') then begin
    step=6.8976
    radstep=r/27.54
    radstep=r/31.
endif

for theta_lo=angle-step/2.05,angle+step/2.05,step do begin
    theta_hi=theta_lo+step
    openw,44,'temp.dat'
    for rad_var=r*0.65,1.5*r,radstep do begin
    ;print,theta_lo,rad_var
        mask=intarr(l(0),l(1))*0
        if (iregion eq 'Grimaldi') then begin
            idx=where(theta gt theta_lo and theta le theta_hi and radii lt rad_var+radstep and radii ge rad_var and xline lt x0)
            grimaldi_idx=where(theta gt theta_lo and theta le theta_hi and xline lt x0)
        endif
        if (iregion eq 'Crisium') then begin
            idx=where(theta gt theta_lo and theta le theta_hi and radii lt rad_var+radstep and radii ge rad_var and xline gt x0)
            crisium_idx=where(theta gt theta_lo and theta le theta_hi and xline gt x0)
        endif
        numbers=n_elements(idx)
        if (idx(0) ne -1) then mask(xline(idx),yline(idx))=1
        if (if_display eq 1) then tvscl,orgimage+mask*20000.
        kdx=where(mask eq 1)
        value=-911
        std=-911
        if (kdx(0) ne -1 and numbers gt 2) then begin
            value=median(orgimage(kdx))
            std=stddev(orgimage(kdx))/sqrt(n_elements(kdx)-1)
            print,theta_lo,rad_var,value,std,numbers
            printf,44,rad_var+radstep/2.,value,std
        endif
        wait,1
    endfor
            if (iregion eq 'Grimaldi') then kdx=where(theta gt theta_lo and theta le theta_hi and radii lt r and radii ge r-r/20. and xline lt x0)
            if (iregion eq 'Crisium') then kdx=where(theta gt theta_lo and theta le theta_hi and radii lt r and radii ge r-r/20. and xline gt x0)
            region=median(orgimage(kdx))
    close,44
    data=get_data('temp.dat')
    rrr=reform(data(0,*))
    lys=reform(data(1,*))
    std=reform(data(2,*))
    idx=where(lys gt -911)
    rrr=rrr(idx)
    lys=lys(idx)
    std=std(idx)
set_plot,'ps
device,filename=strcompress('fan'+iregion+'.ps',/remove_all)
    plot,rrr,lys,psym=-7,xtitle='Distance from Moon center (pixels)',ytitle='Counts',charsize=1.9,ystyle=1,title='Angle ='+string(theta_lo)
    oploterr,rrr,lys,std
    plots,[r,r],[!Y.CRANGE],linestyle=2
    idx=where(rrr gt r*1.05 and rrr lt 1.45*r)
    meanx=mean(rrr(idx))
    res=linfit(rrr(idx),lys(idx),yfit=lysmodel,sigma=sigs,chisq=chi2)
    oplot,rrr(idx),lysmodel,thick=3
    oplot,rrr,rrr*res(1)+res(0),thick=1
    xxx=indgen(l(0))
    uncertainty=sqrt(sigs(0)^2+(sigs(1)*(xxx-meanx))^2)
    oplot,xxx,xxx*res(1)+res(0)+uncertainty,linestyle=1
    oplot,xxx,xxx*res(1)+res(0)-uncertainty,linestyle=1
device,/close
set_plot,'win
endfor
;predict scattered light at patch
predscat=res(0)+res(1)*(r-radstep/2.)
print,'predicted scatter at patch:',predscat
fmt='(a,4(1x,f13.6),1x,a,f12.1,2(1x,a,f12.4))'
print,format=fmt,iregion+': ',res,sigs,' chi^2=',chi2,'RAWREG=',region,'CORSCAT=',region-predscat,file
printf,55,format=fmt,iregion+': ',res,sigs,' chi^2=',chi2,'RAWREG=',region,'CORSCAT=',region-predscat
if (iregion eq 'Grimaldi') then begin
        openw,72,'Grimaldi_Crisium.temp'
        printf,72,region-predscat
        close,72
endif
if (iregion eq 'Crisium') then begin
        openr,72,'Grimaldi_Crisium.temp'
        readf,72,grimaldi_value
        close,72
        ratio=grimaldi_value/(region-predscat)
        printf,55,format='(a,f9.4)','Grimaldi/Crisium:',ratio
        printf,75,format='(i4,1x,d20.6,6(1x,f9.4))',1,1,grimaldi_value,region-predscat,ratio,x0,y0,r
endif
; calculate the image minus the predicted scatter, in the cone
if (iregion eq 'Grimaldi') then begin
    corrected_im=orgimage
    corrected_im(grimaldi_idx)=corrected_im(grimaldi_idx)-(res(0)+res(1)*radii(grimaldi_idx))
endif
if (iregion eq 'Crisium') then begin
    corrected_im(crisium_idx)=corrected_im(crisium_idx)-(res(0)+res(1)*radii(crisium_idx))
endif
return
end


PRO fit_moon2,file,orgimage,x0_in,y0_in,r1_in,r2_in,x0,y0,r1,r2
; PURPOSE   - to find the center and radii of the Moon in the image orgimage
; INPUTS    - file,x0_in,y0_in,r1_in,r2_in: filename and initial guesses of center and radii
; OUTPUTS   - x0,y0,r1,r2
;----------------------------------------------------
; 	Note - fits an ellipse
;----------------------------------------------------
common moon,image
x0=x0_in
y0=y0_in
r1=r1_in
r2=r2_in
image=orgimage
;
a=[x0,y0,r1,r2]
xi=[[1,0,0,0],[0,1,0,0],[0,0,1,0],[0,0,0,1]]
ftol=1.e-6
POWELL,a,xi,ftol,fmin,'petersfunc2'
;print,xi
;
x0=a(0)
y0=a(1)
r1=a(2)
r2=a(3)
;
return
end


PRO letsdoellipse,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2,bestcorr,orgimage,imnum,imstart
common angles,angle_Grimaldi,angle_crisium

fit_moon2,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2
if (bestcorr gt 5) then begin
    tvscl,orgimage
    print,'CLICK ON LEFT EDGE OF MOON.'
    cursor,aL,bL,/device
    wait,0.5
    print,'CLICK ON RIGHT EDGE OF MOON.'
    cursor,aR,bR,/device
    r=abs(aR-aL)/2.0
    x00=aL+r
    y00=(bL+bR)/2.
    fit_moon2,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2
endif
x00=x0
y00=y0
radius1=r1
radius2=r2
fmt='(a,4(1x,f8.3))'
printf,55,format=fmt,'Centre and radii : ',x00,y00,r1,r2
;save_fitted_pars_ellipse,file,x00,y00,radius1,radius2
;save_lastfit_ellipse,file,x00,y00,radius1,radius2
;
; First look at Grimaldi
;
iregion='Grimaldi'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_Grimaldi
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_Grimaldi,file,iregion
;
; Then look at Crisium
;
iregion='Crisium'
;
; find Feature
;

find_feature,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_crisium
;
; find the scattered light in the relevant cone
;
make_fan,orgimage,image,x0,y0,(radius1+radius2)/2.,angle_crisium,file,iregion
;
return
end

PRO get_lastfit_circle,file,x00,y00,radius
x00=0.0
y00=0.0
radius=0.0
openr,72,'lastfit_circle'
readf,72,x00,y00,radius
print,'Opened lastfit_circle, found: x00,y00,radius=',x00,y00,radius
close,72
return
end

PRO get_lastfit_ellipse,file,x00,y00,radius1,radius2
x00=0.0
y00=0.0
radius1=0.0
radius2=0.0
openr,72,'lastfit_ellipse'
readf,72,x00,y00,radius1,radius2
print,'Opened lastfit_ellipse, found:x00,y00,radius1,radius2=',x00,y00,radius1,radius2
close,72
return
end

PRO locate_filter_edge_mask,image,maskleft,maskright
contour,image
print,'Click slightly left of left edge of filter'
cursor,ml,dummy
wait,0.5
print,'Click slightly right of right edge of filter'
cursor,mr,dummy
wait,0.5
maskleft=ml
maskright=mr
return
end

PRO make_circle,x0,y0,r,x,y
angle=findgen(1000)/1000.*360.0
x=fix(x0+r*cos(angle*!dtor))
y=fix(y0+r*sin(angle*!dtor))
; make another layer outside first
ran=randomu(seed)
x=[x,fix(x0+(r+1)*cos(angle*!dtor+ran))]
y=[y,fix(y0+(r+1)*sin(angle*!dtor+ran))]
; make another layer inside other two
x=[x,fix(x0+(r-1)*cos(angle*!dtor-ran))]
y=[y,fix(y0+(r-1)*sin(angle*!dtor-ran))]
return
end


PRO generateJD,obsdate,obstime,JD
year=fix(strmid(strmid(obsdate,11,10),0,4))
month=fix(strmid(strmid(obsdate,11,10),5,2))
dd=fix(strmid(strmid(obsdate,11,10),8,2))
hh=fix(strmid(strmid(obstime,11,8),0,2))
mm=fix(strmid(strmid(obstime,11,8),3,2))
ss=fix(strmid(strmid(obstime,11,8),6,2))
JD=julday(month,dd,year,hh,mm,ss)
return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;             LUNAR FEATURE PHOTOMETRIC ANALYSER
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
common keep,bestcorr
common info,JD,imnum
common facts,probableradius,probablex00,probabley00
common results,corrected_im
;--------------------------------------
if_rebin=1	; set to 1 if rebinning of image is needed
rebin_factor=1.
probableradius=410.168*rebin_factor
probablex00=694.931*rebin_factor
probabley00=534.054*rebin_factor
maskleft=450*rebin_factor   ; column to start image rescaling at, from left
scalefactor=1.   ; factor rescale bright side by
;--------------------------------------

openw,75,'tabulated_output.dat'
printf,75,'image_number    JD          GRIM   reg-scat     ratio      x0        y0       r'

fit_form=2	; fit Moon's rim with an ellipse
fit_form=1	; fit Moon's rim with a circle
file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\stacked_ChrisAlg_PeterStack_349_float.fit'
file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\May25\May25\IMG75.FIT'
;
;
openw,55,'Crisium_Grimaldi_fits.results'

printf,55,'================================================================================='
printf,55,'  '
bestcorr=1e20
rdfits_struct, file, struct, /silent
results=readfits(file,header)
image=double(struct.im0)
l=size(image,/dimensions)
if (if_rebin eq 1) then image=congrid(image,l(0)*rebin_factor,l(1)*rebin_factor)
l=size(image,/dimensions)

ncols=l(0)
nrows=l(1)
window,0,xsize=ncols,ysize=nrows
tvscl,image
; find center and radius from three points
cursor,x1,y1,/device
wait,1
cursor,x2,y2,/device
wait,1
cursor,x3,y3,/device
circlefinder,x1,y1,x2,y2,x3,y3,probablex00,probabley00,probableradius
;mask the bright part of the image
image(maskleft:l(0)-1,*)=image(maskleft:l(0)-1,*)/scalefactor
write_bmp,'Moon.bmp',image
orgimage=image
; edge-enhance the image
image=sobel(image)
median_sobel=median(image)
std_sobel=stddev(image)
idx=where(image gt median_sobel+3.0*std_sobel)
jdx=where(image le median_sobel+3.0*std_sobel)
image(idx)=1.0
image(jdx)=0.0
l=size(image,/dimensions)
; guess at parameters...
x00=probablex00
y00=probabley00
radius=probableradius
radius1=probableradius
radius2=probableradius
; guess by making row sum and looking for edge...
;make_row_sum_plot,image,x00,y00,radius
;-------------------------------------------------------------------
; find center and rim by Powell's method....
;
if (fit_form eq 1) then begin
	letsdocircle,file,image,x00,y00,radius,x0,y0,r,bestcorr,orgimage,imnum,imstart
endif	; end of fitting circle
if (fit_form eq 2) then begin
	letsdoellipse,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2,bestcorr,orgimage,imnum,imstart
endif	; end of fitting ellipse
close,55
close,75
; write corrected image
writefits,'MAy25_IMG75_linearskyremoved.fit',double(corrected_im)
end
