PRO correctslopes,im1,im2
;..........................
mean1=mean(im1)
sfit1=sfit(im1,1)
im1=im1-sfit1+mean1
;..........................
mean2=mean(im2)
sfit2=sfit(im2,1)
im2=im2-sfit2+mean2
;..........................
return
end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

PRO getstats,subim1,subim2,level,var
if_scale=0
level=mean(subim1,/double)
print,'Level ratio:',mean(subim1,/double)/mean(subim2,/double)
subim2=subim2/mean(subim2,/double)*level
diff=subim2-subim1
var=stddev(diff)^2/2.
return
end


filters=['VE1','IRCUT','VE2','V','B']
for ifilter=0,4,1 do begin
filter=filters(ifilter)
openw,44,strcompress('variance_level'+filter+'.dat',/remove_all)
path='/media/SAMSUNG/MOONDROPBOX/JD2456065/'
;path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456065/'
files=file_search(strcompress(path+'245*_'+filter+'.fits*',/remove_all),count=n)
print,'Found ',n,' files.'
bias=readfits('superbias.fits')
for i=0,n-1,1 do begin
im=double(readfits(files(i),header))
get_EXPOSURE,header,exptime
l=size(im,/dimensions)
if (n_elements(l) ne 2) then begin
for j=0,l(2)-1,2 do begin
im1=reform(im(*,*,j))-bias
im2=reform(im(*,*,j+1))-bias
;correctslopes,im1,im2
adu=3.78
adu=1.0
w=90
subim1=im1(218-w:218+w,215-w:215+w)*adu
subim2=im2(218-w:218+w,215-w:215+w)*adu
getstats,subim1,subim2,level,var
printf,44,level,var,exptime
endfor
endif
endfor
close,44
data=get_data(strcompress('variance_level'+filter+'.dat',/remove_all))
level=reform(data(0,*))
variance=reform(data(1,*))
exposure=reform(data(2,*))
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.CHARSIZE=1.1
!P.MULTI=[0,1,2]
level=level/adu
variance=variance/adu
idx=sort(level)
level=level(idx)
variance=variance(idx)
exposure=exposure(idx)

maxrange=min([66000,max([max(level),max(variance)])])
plot,/isotropic,xtitle='Counts',ytitle='Variance',level,variance,psym=7,xrange=[0,maxrange],yrange=[0,maxrange],xstyle=3,ystyle=3,title=filter
idx=where(level le 55000L)
level=level(idx)
variance=variance(idx)
exposure=exposure(idx)
res=linfit(level,variance,/double,yfit=yhat)
print,'Linfit: ',res
oplot,level,yhat
res=POLY_FIT(level,variance, 2,/double,yfit=parabola)
print,'Parabolic coffecicients: ',res
xyouts,/normal,0.7,0.9,'c0: '+string(res(0),format='(g12.6)')
xyouts,/normal,0.7,0.88,'c1: '+string(res(1),format='(g12.6)')
xyouts,/normal,0.7,0.86,'c2: '+string(res(2),format='(g12.6)')
oplot,level,parabola,color=fsc_color('red')
plots,[0,maxrange],[0,maxrange],linestyle=2
plot,psym=7,exposure,level,xtitle='Exp time [s]',ytitle='Counts in FITS'
endfor
end
