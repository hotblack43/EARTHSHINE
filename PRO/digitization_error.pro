PRO	put_poisson,im,seed
l=size(im,/dimensions)
maxnumber=0
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
if (im(i,j) gt 0) then begin
	number=randomn(seed,poisson=im(i,j))
	im(i,j)=number
;	if (number gt maxnumber) then begin
;		print,'number:',maxnumber
;		maxnumber=number
;	endif
endif
endfor
endfor
kdx=where(im lt 0)
if (kdx(0) ne -1) then begin
	im(kdx)=0.0
	stop
endif
return
end

; read the file that eshine_16 produced 
file='JD_phaseangle_BSDSratio_MoonHapke.dat'
data=get_data(file)
JD=reform(data(0,*))
openw,47,'JDmaxmin.dat'
printf,47,format='(2(1x,f20.6))',max(jd),min(jd)
close,47
;Isun=reform(data(1,*))
;Iearth=reform(data(2,*))
;ph_M=reform(data(3,*))
;ph_E=reform(data(4,*))
ph_E=reform(data(1,*))
; start readingthe IDEAL images produced by eshine_16
path='/home/pth/SCIENCEPROJECTS/EARTHSHINE/OUTPUT/IDEAL/'
openw,44,'ratios.dat'
for i=0,115,1 do begin
print,i
if (i le 9) then filename=strcompress(path+'ideal_LunarImg_000'+string(i)+'.fit',/remove_all)
if (i gt 9) then filename=strcompress(path+'ideal_LunarImg_00'+string(i)+'.fit',/remove_all)
if (i gt 99) then filename=strcompress(path+'ideal_LunarImg_0'+string(i)+'.fit',/remove_all)
im=readfits(filename)
FWCAP=200000.
FWCAP=20000.
im=im/max(im)*FWCAP	; pretend "well exposed"
ncoadd=350
sum=im*0.0
num=randomn(seed)
seed=num
for icoadd=1,ncoadd,1 do begin
	imccd=im
	put_poisson,imccd,seed	; generate Poisson noise
	imccd=long(imccd/FWCAP*(0.8*(2L^16-1)))	; round off to near max of 16 bits
;	print,max(imccd)
	sum=sum+imccd
endfor
imccd=sum/float(ncoadd)
xl1=82
xr1=86
yd1=237
yu1=241
xl2=409
xr2=413
yd2=310
yu2=314

region1=im(xl1:xr1,yd1:yu1)
region2=im(xl2:xr2,yd2:yu2)
region1ccd=imccd(xl1:xr1,yd1:yu1)
region2ccd=imccd(xl2:xr2,yd2:yu2)
ratio=mean(region1)/mean(region2)
ratioccd=mean(region1ccd)/float(mean(region2ccd))
;...............
      obsname='lapalma'
      MOONPOS, jd(i), ra_moon, dec_moon, dis
      eq2hor, ra_moon, dec_moon, jd(i), alt_moon, az_moon, ha_moon,  OBSNAME=obsname
      SUNPOS, jd(i), ra_sun, dec_sun
      eq2hor, ra_sun, dec_sun, jd(i), alt_sun, az, ha, OBSNAME=obsname
;...............
print,ph_e(i),ratio,ratioccd,(ratio-ratioccd)/ratio*100.0,' %'
printf,44,format='(f8.3,1x,7(f15.6,1x))',ph_e(i),mean(region1),mean(region2),ratio,ratioccd,(ratio-ratioccd)/ratio*100.0,alt_moon,alt_sun
contour,im,/cell_fill,nlevels=11,/isotropic,xstyle=1,ystyle=1
xyouts,200,900,'Err: '+string((ratio-ratioccd)/ratio*100.0)+' %.',charsize=1.2
plots,[xl1,xl1],[yd1,yu1]
plots,[xl1,xr1],[yu1,yu1]
plots,[xr1,xr1],[yu1,yd1]
plots,[xr1,xl1],[yd1,yd1]

plots,[xl2,xl2],[yd2,yu2]
plots,[xl2,xr2],[yu2,yu2]
plots,[xr2,xr2],[yu2,yd2]
plots,[xr2,xl2],[yd2,yd2]
endfor
close,44
end

