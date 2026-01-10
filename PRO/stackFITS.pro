PRO quality,im,quality
l=size(im,/dimensions)
subimage=im-mean(im)
z=fft(subimage,-1)
z2=shift(z*conj(z),l(0)/2,l(1)/2)
rowsum=total(alog(z2),1)
colsum=total(alog(z2),2)
allsum=(rowsum+colsum)/2.
idx=where(allsum ge max(allsum)/2.)
quality=max(idx)-min(idx)
return
end

PRO align_method1,stackim,aligned_1,aligned_2 
;
; aligns images from pixel shifts in the range -2 to 2 for a 30x30 window
; best aligment is based on maximizing correlation between window subimages
;
common quality,quality
l=size(stackim,/dimensions)
nims=l(2)
quality=indgen(nims)
window=2^5
contour,stackim(*,*,0)
print,'Click on a central feature...'
cursor,a,b,/device
left=a-window/2.
right=a+window/2.
down=b-window/2.
up=b+window/2.
; measure quality of subimage 0 via FFT
quality,stackim(left:right,down:up,0),qual
print,'Quality of image 0:',qual
quality(0)=qual

for i=1,nims-1,1 do begin
Rmax=-9e20
frame=5
for xshift=-frame,frame,1 do begin
for yshift=-frame,frame,1 do begin
R=correlate(stackim(left:right,down:up,0),shift(stackim(left:right,down:up,i),xshift,yshift))
if (R gt Rmax) then begin
;	print,i,xshift,yshift,R,' best so far..'
	bestxshift=xshift
	bestyshift=yshift
	Rmax=R
endif
endfor
endfor
; shift the image optimally
if (abs(bestyshift) eq frame or abs(bestxshift) eq frame) then print,'Warning - on edge of frame!'
stackim(*,*,i)=shift(stackim(*,*,i),bestxshift,bestyshift)
; measure quality of subimage i via FFT
quality,stackim(left:right,down:up,i),qual
print,'Quality of image ',i,':',qual
quality(i)=qual
endfor
print,'Mean image quality:',mean(quality)
jdx=where(quality ge mean(quality))
aligned_1=total(stackim,3)/float(nims)
aligned_2=total(stackim(*,*,jdx),3)/float(n_elements(jdx))
return
end

common quality,quality
device,/decomposed,retain=2
WINDOW, 1, XSIZE = 512, YSIZE = 512
prestring='Moon'
files=file_search('/home/pth/Desktop/ASTRO/ANDOR/','Vega_ANDOR_*.fits')
nims=n_elements(files)
imcount=0
skipfile=indgen(nims)*0
rebin_factor=1
for ifile=0,nims-1,1 do begin
; stack the files after by-eye shifts
if (skipfile(ifile) eq 0) then begin
 	print,files(ifile)
	im=readfits(files(ifile),header)
	l=size(im,/dimensions)
	im=rebin(im,l(0)*rebin_factor,l(1)*rebin_factor)
	contour,im
	cursor,a,b,/DEVICE
	print,a,b
	if (imcount eq 0) then begin
		stackim=im
		centerx0=fix(a)
		centery0=fix(b)
	endif
		centerx=fix(a)
		centery=fix(b)
	if (imcount ne 0) then begin
		stackim=[[[stackim]],[[shift(im,centerx0-centerx,centery0-centery)]]]
;	 	contour,stackim(*,*,imcount)
	endif
	imcount=imcount+1
endif	; end of ifskipfile...
endfor	; end of ifile loop
;
rough_align=total(stackim,3)/float(nims)
rough_align=rebin(rough_align,l)
writefits,strcompress(prestring+'_STACKED_rough_align.FIT',/remove_all),rough_align
print,'STD/mean of rough_align:',stddev(rough_align)/mean(rough_align)
; now apply more refined realigment
align_method1,stackim,aligned_1,aligned_2 
aligned_1=rebin(aligned_1,l)
aligned_2=rebin(aligned_2,l)
print,'STD/mean of aligned_1:',stddev(aligned_1)/mean(aligned_1)
print,'STD/mean of aligned_2:',stddev(aligned_2)/mean(aligned_2)
WINDOW, 0, XSIZE = 500, YSIZE = 500 
contour,rough_align
WINDOW, 1, XSIZE = 500, YSIZE = 500 
contour,aligned_1
WINDOW, 2, XSIZE = 500, YSIZE = 500 
contour,aligned_2
writefits,strcompress(prestring+'_STACKED_aligned_1.FIT',/remove_all),aligned_1
writefits,strcompress(prestring+'_STACKED_aligned_2.FIT',/remove_all),aligned_2
end

