; First get lunar magnitudes from the formula in Allen
file='Allenmoon.dat'
data=get_data(file)
allen_JD=reform(data(0,*))
allen_phase=reform(data(1,*))
allen_Vmag=reform(data(2,*))
;
Openw,4,'Lunar_magnitudes,dat'
files=file_search('Lambert_Lunar_Images\Lunar*.fts',count=nfiles)
for ifile=0,nfiles-1,1 do begin
	im=readfits(files(ifile),header)
	mean_val=mean(im)
	stdd=stddev(im)
	;print,mean_val,stdd
	; find the BS
	idx=where(im gt mean_val*1.0)
	bright = ARRAY_INDICES(im, idx)
	; find the ES
	jdx=where(im le 1.0*mean_val and im gt 0)
	dark = ARRAY_INDICES(im, jdx)
	fraction=float(n_elements(idx))/float(n_elements(where(im gt 0)))
	;plots,bright(0,*),bright(1,*),psym=3
	;plots,dark(0,*),dark(1,*),psym=4
	printf,4,strmid(header(9),17,10),-2.5*alog10(total(im(bright(0,*),bright(1,*)))),-2.5*alog10(total(im(dark(0,*),dark(1,*)))), $
	-2.5*alog10(total(im(bright(0,*),bright(1,*)))/n_elements(bright)),$
	-2.5*alog10(total(im(dark(0,*),dark(1,*)))/n_elements(dark)),fraction*100.0
endfor
close,4
data=get_data('Lunar_magnitudes,dat')
jd=reform(data(0,*))
bri=reform(data(1,*))
dar=reform(data(2,*))
bri_surf=reform(data(3,*))
dar_surf=reform(data(4,*))
frac=reform(data(5,*))
fil='horizons_results.dat'
data2=get_dataXX(fil)
hjd=reform(data2(0,*))
mag=reform(data2(7,*))
surf_mag=reform(data2(8,*))
hor_frac=reform(data2(14,*))
!P.MULTI=[0,1,2]
;plot,jd,bri_surf,psym=-7,yrange=[5,-21],xstyle=1,xtitle='time(days)',ytitle='mags per pixel',title='BS = sym+line, (thick:jpl), ES = sym',charsize=1.3
;oplot,jd,dar_surf,psym=4
;oplot,hjd,surf_mag-26,psym=-6,thick=2
plot,jd,mag,psym=-7,yrange=[-3.5,-13.5],xstyle=1,ystyle=1,xtitle='time (days)',ytitle='Magnitudes [-2.5*log10(flux)]',title='Thick: Lambert; thin:jpl',charsize=1.3
oplot,jd,dar,psym=4
oplot,hjd,bri+12.3,psym=-6,thick=2
oplot,allen_jd,allen_Vmag,psym=5
;--------- Same as above but for Hapke data
Openw,4,'Lunar_magnitudes,dat'
files=file_search('Hpake_Lunar_Images\Lunar*.fts',count=nfiles)
for ifile=0,nfiles-1,1 do begin
	im=readfits(files(ifile),header)
	mean_val=mean(im)
	stdd=stddev(im)
	;print,mean_val,stdd
	; find the BS
	idx=where(im gt mean_val*1.0)
	bright = ARRAY_INDICES(im, idx)
	; find the ES
	jdx=where(im le 1.0*mean_val and im gt 0)
	dark = ARRAY_INDICES(im, jdx)
	fraction=float(n_elements(idx))/float(n_elements(where(im gt 0)))
	;plots,bright(0,*),bright(1,*),psym=3
	;plots,dark(0,*),dark(1,*),psym=4
	printf,4,strmid(header(9),17,10),-2.5*alog10(total(im(bright(0,*),bright(1,*)))),-2.5*alog10(total(im(dark(0,*),dark(1,*)))), $
	-2.5*alog10(total(im(bright(0,*),bright(1,*)))/n_elements(bright)),$
	-2.5*alog10(total(im(dark(0,*),dark(1,*)))/n_elements(dark)),fraction*100.0
endfor
close,4
data=get_data('Lunar_magnitudes,dat')
jd=reform(data(0,*))
bri=reform(data(1,*))
dar=reform(data(2,*))
bri_surf=reform(data(3,*))
dar_surf=reform(data(4,*))
frac=reform(data(5,*))
fil='horizons_results.dat'
data2=get_dataXX(fil)
hjd=reform(data2(0,*))
mag=reform(data2(7,*))
surf_mag=reform(data2(8,*))
hor_frac=reform(data2(14,*))

;plot,jd,bri_surf,psym=-7,yrange=[5,-21],xstyle=1,xtitle='time(days)',ytitle='mags per pixel',title='BS = sym+line, (thick:jpl), ES = sym',charsize=1.3
;oplot,jd,dar_surf,psym=4
;oplot,hjd,surf_mag-26,psym=-6,thick=2
plot,jd,mag,psym=-7,yrange=[-3.5,-13.5],xstyle=1,ystyle=1,xtitle='time (days)',ytitle='Magnitudes [-2.5*log10(flux)]',title='Thick: Hapke; thin:jpl',charsize=1.3
oplot,jd,dar,psym=4
oplot,hjd,bri+12.3,psym=-6,thick=2
oplot,allen_jd,allen_Vmag,psym=5
;
;plot,jd,frac,charsize=1.3,xtitle='time (days)',ytitle='Illuminated fraction (jpl: symb.) in %'
;oplot,hjd,hor_frac,psym=6
end