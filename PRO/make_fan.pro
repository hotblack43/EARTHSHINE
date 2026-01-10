PRO make_fan,orgimage,image,x0,y0,r,angle,file,iregion
;	help,orgimage,image,x0,y0,r,angle,file,iregion
;
common info,JD,imnum
if_display=0    ; want TVSCL???
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
    step=5.8976
    radstep=r/27.54
    radstep=r/20.
endif
if (iregion eq 'Crisium') then begin
    step=15.8976
    radstep=r/27.54
    radstep=r/20.
endif

for theta_lo=angle-step/2.05,angle+step/2.05,step do begin
    theta_hi=theta_lo+step
    openw,44,'temp.dat'
    for rad_var=r*0.7,1.5*r,radstep do begin
        mask=intarr(l(0),l(1))*0
        if (iregion eq 'Grimaldi') then begin
            idx=where(theta gt theta_lo and theta le theta_hi and radii lt rad_var+radstep and radii ge rad_var and xline lt x0)
        endif
        if (iregion eq 'Crisium') then begin
            idx=where(theta gt theta_lo and theta le theta_hi and radii lt rad_var+radstep and radii ge rad_var and xline gt x0)
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
set_plot,'x
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
        printf,75,format='(i4,1x,d20.6,6(1x,f9.4))',imnum,JD,grimaldi_value,region-predscat,ratio,x0,y0,r
endif
return
end

