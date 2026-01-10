PRO get_specific_feature_offset_2,im,x0,y0
x=total(im,2)
x0=where(x eq max(x))
y=total(im,1)
y0=where(y eq max(y))
print,x0,y0
;contour,im
;plots,[x0,x0],[!Y.CRANGE]
;plots,[!X.CRANGE],[y0,y0]
return
end

PRO get_specific_feature_offset,im,x0,y0
print,'Click on a universal feature'
;contour,im
;cursor,a,b,/data
print,a,b
x0=a
y0=b
return
end

PRO	get_best_shift,im0_in,im_in,bestXshift,bestYshift,maxXshift,maxYshift
bestcorr=-9e10
for xshift=-maxXshift,maxXshift,1 do begin
for yshift=-maxYshift,maxYshift,1 do begin
im0=im0_in
im=im_in
im=shift(im,xshift,yshift)
; avoid folded bits
if (xshift gt 0) then begin
l=size(im0,/dimensions)
im0=im0(xshift-1:l(0)-1,*)
l=size(im,/dimensions)
im = im(xshift-1:l(0)-1,*)
endif
if (xshift le 0) then begin
l=size(im0,/dimensions)
im0=im0(0:l(0)-1+xshift,*)
l=size(im,/dimensions)
im = im(0:l(0)-1+xshift,*)
endif
if (yshift gt 0) then begin
l=size(im0,/dimensions)
im0=im0(*,yshift-1:l(1)-1)
l=size(im,/dimensions)
im = im(*,yshift-1:l(1)-1)
endif
if (yshift le 0) then begin
l=size(im0,/dimensions)
im0=im0(*,0:l(1)-1+yshift)
l=size(im,/dimensions)
im = im(*,0:l(1)-1+yshift)
endif
subim1=im0
subim2=im
R=correlate(subim1,subim2)
if (R gt bestcorr) then begin
bestcorr=R
bestXshift=xshift
bestYshift=yshift
endif
endfor
endfor
if (bestcorr eq -9e10) then stop
print,bestcorr,bestXshift,bestYshift
return
end

PRO clipimage,im,maxcol
im=im(0:maxcol-1,*)
return
end

PRO stack,files,stacked
openw,66,'count_vs_SN.dat'
n=n_elements(files)
; get the appropriate flat field
;flat=readfits('/home/pth/SCIENCEPROJECTS/WORK/median_flat_frame_may28.FIT')
;dark=float(readfits('I:\ASTRO\AUSTRALIAMOON\sydneydark.fit'))
dark=float(readfits('ANDREW/DATA/sydneydark.fit'))
factor=2	; rebinning factor
;======================================================
; get all images and their offsets
imstart=0
howmany=199
imstop=imstart+howmany
imshifts=intarr(2,imstop-imstart+1)*0+9999
k=0
;maxcol=605
for i=imstart,imstop,1 do begin
if (i ne 11) then begin
	im=float(readfits(files(i)))
 	im=im-dark
	l=size(im,/dimensions)
	im=congrid(im,l(0)*factor,l(1)*factor,cubic=-0.5)
;	im=rebin(im,l*factor)
	get_specific_feature_offset_2,im,x00,y00
	;get_specific_feature_offset,im,x00,y00
	imshifts(0,k)=x00
	imshifts(1,k)=y00
	if (i eq imstart) then stack=im
	if (i ne imstart) then begin
		xsh=imshifts(0,0)-imshifts(0,k)
		ysh=imshifts(1,0)-imshifts(1,k)
		print,'shitning image',i,' by :',xsh,ysh
		shifted=shift(im,xsh,ysh)
		;clipimage,shifted,maxcol
		stack=[[[stack]],[[shifted]]]
	endif
	k=k+1
	help,stack
endif
endfor
idx=where(imshifts(0,*) ne 9999)
imshifts=imshifts(*,idx)
stack=stack(*,*,idx)
l=size(stack,/dimensions)
nims=l(2)
;======================================================
maxXshift=2
maxYshift=2
im0=stack(*,*,0)
;tvscl,im0
stacked=float(im0)
count=0
for i=1,nims-1,1 do begin
	im=stack(*,*,i)
	get_best_shift,im0,im,bestXshift,bestYshift,maxXshift,maxYshift
		if (abs(bestXshift) ne maxXshift and abs(bestYshift) ne maxYshift) then begin
			print,i
			im=shift(im,bestXshift,bestYshift)
			stacked=stacked+float(im)
			;window,0
			;device,decomposed=0
;			loadct,17
			show= HIST_EQUAL(stacked)
			;tvscl,show
			;window,2,xsize=110,ysize=110
			subim=stacked(60:160,220:320)
			subim=HIST_EQUAL(subim)
			;tvscl,subim
				line1=stacked(150,200:300)
				line2=stacked(150,100:130)
print,'1:',mean(line1)-mean(line2),stddev(line1),(mean(line1)-mean(line2))/stddev(line1)
				line3=line1-smooth(line1,7,/edge_truncate)
print,'2:',mean(line1)-mean(line2),stddev(line3),(mean(line1)-mean(line2))/stddev(line3)
	printf,66,count,(mean(line1)-mean(line2))/stddev(line1),(mean(line1)-mean(line2))/stddev(line3)
			count=count+1
		endif
endfor
stacked=stacked/float(count)
;stacked=stacked/float(count)-dark
writefits,strcompress('stacked_new_'+string(howmany)+'_uint.FIT',/remove_all),uint(stacked)
writefits,strcompress('stacked_new_'+string(howmany)+'_float.FIT',/remove_all),(stacked)
;set_plot,'ps
;contour,stacked
;plot,total(stacked,2)
;plot_io,total(stacked,2)
;device,/close
close,66
end



;files=file_search('I:\ASTRO\AUSTRALIAMOON\','moon*.FIT')
files=file_search('ANDREW/DATA/','moon*.FIT')
;files=file_search('/home/pth/moon/ANDREW/DATA/','moon*.FIT')
stack,files,stacked
end
