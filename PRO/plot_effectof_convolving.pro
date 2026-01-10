@getphasefromJD.pro
function get_squaremean,im,x0,y0,w
sq=im(x0-w:x0+w,y0-w:y0+w)
;print,sq
value=mean(sq,/double)
return,value
end
 FUNCTION get_JD_from_filename,name
 idx=strpos(name,'24')
 JD=double(strmid(name,idx,15))
 return,JD
 end


close,/all
!P.thick=8
!x.thick=6
!y.thick=6
!P.charsize=1.6
!P.charthick=2
x0=144
y0=199
w=4
openw,33,'effectsofalfa_4.dat'
files=file_search('FITIDEALS/OUTPUT/IDEAL/ideal_image_*',count=nims)
;files='FITIDEALS/OUTPUT/IDEAL/ideal_image_JD2456134.0740965.fits'
;nims=1
for imnum=0,nims-1,1 do begin
; get JD and the lunar phase
	JD=get_JD_from_filename(files(imnum))
	getphasefromJD,JD,phase
;print,files(imnum),jd,phase,'       ************'
	spawn,"cp "+files(imnum)+" infil.fits"
	im0=readfits('infil.fits',/sil)
	sq0val=get_squaremean(im0,x0,y0,w)
	orgflux=total(im0,/double)
	plot,im0(*,y0),/ylog,yrange=[0.001d0,1e3],xtitle='Image column #',ytitle='Counts'
	for alfa=1.87279,1.70,-.05 do begin
		fname=strcompress('out_'+string(alfa,format='(f4.2)')+'.fits',/remove_all)
		spawn,"./justconvolve_spPFS_special infil.fits "+fname+" "+string(alfa,format='(f4.2)')+" 0.0 0.0"
		im=readfits(fname,/sil)
		imflux=total(im,/double)
		im=im/imflux*orgflux
		oplot,im(*,y0)
		sqval=get_squaremean(im,x0,y0,w)
		printf,33,jd,alfa*1.601890,(sqval-sq0val)/sq0val*100.0,phase
		print,jd,alfa*1.601890,(sqval-sq0val)/sq0val*100.0,phase
	endfor	; alfa value
	oplot,[x0-w,x0-w],[3e-3,1]
	oplot,[x0+w,x0+w],[3e-3,1]
endfor	; loop imnum
close,33
end
