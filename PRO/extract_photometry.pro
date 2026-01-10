PRO goplotpatches,im,x1,x2,x3,x4,y1,y2,y3,y4
val=3.*max((im))
sob=sobel(im)
im=im+sob/max(sob)*val
im(x1:x2,y1)=val
im(x2,y1:y2)=val
im(x1:x2,y2)=val
im(x1,y1:y2)=val
im(x3:x4,y3)=val
im(x4,y3:y4)=val
im(x3:x4,y4)=val
im(x3,y3:y4)=val
contour,im,/isotropic,/cell_fill,nlevels=101,xstyle=1,ystyle=1
return
end


PRO get_photometric_ratio,image,ratio,average
common boxes,x1,x2,x3,x4,y1,y2,y3,y4
print,x1,x2,x3,x4,y1,y2,y3,y4
patch1=mean(image(x1:x2,y1:y2))
patch2=mean(image(x3:x4,y3:y4))
ratio=patch1/patch2	; for linear images
average=mean([patch1,patch2])
;print,patch1,patch2,ratio
return
end

PRO get_im_phase,filename,im,phase
;print,filename
		im=readfits(filename,header)
		  jd=double(strmid(header(8),16,32-16))
		  MPHASE,jd, phase
                  phase=double(strmid(header(9),16,32-16))
return
end



;=====================================================================================
; code to extract photometric information from images of the Moon
common boxes,x1,x2,x3,x4,y1,y2,y3,y4
;width=4
;x1=85-width & x2=85+width & x3=440-width & x4=440+width 
;y1=254-width & y2=254+width & y3=257-width & y4=257+width ; suitable for centered 512x512 image
;x1=76 & x2=89 & y1=227 & y2=252
;x3=404 & x4=417 & y3=303 & y4=331
; one DS patch, one BS patch
x1=123 & x2=126 & y1=241 & y2=271
x3=388 & x4=391 & y3=237 & y4=278
; two DS patches
x1=125 & x2=133 & y1=280 & y2=285
x3=125 & x4=133 & y3=230 & y4=235
; two BS patches
x1=372 & x2=375 & y1=314 & y2=321
x3=382 & x4=385 & y3=274 & y4=283


;
openw,5,'DSBS_ratio.dat'
;-----------------------
path='OUTPUT/IDEAL/'
InSpacefiles=file_search(path+'InSpace_*.fit',count=nfiles1)
Observefiles=file_search(path+'Observed_*.fit',count=nfiles2)
Cleanedfiles=file_search(path+'Cleaned_*.fit',count=nfiles3)
BBSOfiles=file_search(path+'BBSO_cleaned_*.fit',count=nfiles4)
if ((nfiles1 ne nfiles2) or (nfiles1 ne nfiles3 or (nfiles1 ne nfiles4))) then stop
nfiles=nfiles1 ; (say)
;-------------
; set a pedestal to remove from ALL images
for ifile=0,nfiles-1,1 do begin
print,'----------------------------------------------------------------'
	get_im_phase,InSpacefiles(ifile),im,phase
	get_photometric_ratio,im,ratio_InSpace,avspace

	get_im_phase,Observefiles(ifile),im,dummy
	get_photometric_ratio,im,ratio_Observed,avObs

	if (ifile eq 0) then goplotpatches,im,x1,x2,x3,x4,y1,y2,y3,y4

	get_im_phase,Cleanedfiles(ifile),im,dummy
	get_photometric_ratio,im,ratio_Cleaned,avClean

	get_im_phase,BBSOfiles(ifile),im,dummy
	get_photometric_ratio,im,ratio_BBSO,AvBBSO

	print,phase,ratio_InSpace,ratio_Observed,ratio_Cleaned,ratio_BBSO,avspace
fmt='(7(1x,f12.6))'
	printf,5,format=fmt,phase,ratio_InSpace,ratio_Observed,ratio_Cleaned,ratio_BBSO,avspace
endfor
close,5
;
end
