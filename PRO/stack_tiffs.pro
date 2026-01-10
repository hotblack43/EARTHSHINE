PRO get_specific_feature_offset_2,im,x0,y0
;--------------------------------------------------------------------------------
; Routine to indicate a feature on the lunar disc - used for alignment purposes
; Works by using the 'center of gravity' of the pixel counts in the image.
;	im	:(INPUT)	: The image
;
;	x0,y0	:(OUTPUT)	: The coordinates in image frame of the C.G.
;--------------------------------------------------------------------------------
x=total(im,2)
x0=where(x eq max(x))
if (size(x0,/dimensions) ge 2) then x0=reform(x0(0))
y=total(im,1)
y0=where(y eq max(y))
if (size(y0,/dimensions) ge 2) then y0=reform(y0(0))
return
end

PRO get_specific_feature_offset,im,x0,y0
;--------------------------------------------------------------------------------
; Routine to indicate a feature on the lunar disc - used for alignment purposes
; Works interactively with theuser who must clikc on the chosen feature.
;	im	:(INPUT)	: The image to click on
;
;	x0,y0	:(OUTPUT)	: The coordinates in image frame of the selected feature
;--------------------------------------------------------------------------------
print,'Click on a universal feature'
contour,im
cursor,a,b,/data
print,a,b
x0=a
y0=b
return
end

PRO	get_best_shift,im0_in,im_in,bestXshift,bestYshift,maxXshift,maxYshift,congridfactor
;--------------------------------------------------------------------------------
; Routine to further align two images. Uses correlation to refine the alignemnt
; Correlates a subframe of the two images selected by taking into account the
; effect of the SHIFT operators (end effects)
;	im0_in,im_in		:(INPUT)	: The two images to be aligned
;	maxXshift,maxYshift	:(INPUT)	: Maximum X and Y shifts to be tested
;
;	bestXshift,bestYshift	:(OUTPUT)	: The calculated best shift
;--------------------------------------------------------------------------------
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
print,'Best correlation=',bestcorr,' at fine adjusted shift: ',bestXshift/congridfactor,bestYshift/congridfactor
return
end


PRO stack,files,stacked,howmany,congridfactor
;--------------------------------------------------------------------------------
; Routine to align and stack a set of images
; files		:(INPUT)	: a list of filenames indicating the images to b stacked
; howmany	:(INPUT)	: how many frames you wish to coadd
;
; stacked	:(OUTPUT)	: the frame resulting after alignment and averaging
;--------------------------------------------------------------------------------
openw,66,'count_vs_SN.dat'
n=n_elements(files)
;======================================================
; get images and their offsets
; indicate how many images you wish to coadd
imstart=0
imstop=imstart+howmany
imshifts=intarr(2,imstop-imstart+1)*0+9999
k=0
maxXshift=3
maxYshift=3
;READ_JPEG ,files(imstart), im0, /GRAYSCALE
im0 = READ_TIFF(files(imstart), R, G, B)
im0=total(im0,1)
l=size(im0,/dimensions)
if (congridfactor ne 1) then im0=congrid(im0,l(0)*congridfactor,l(1)*congridfactor)
stacked=im0
count=100
c=congridfactor
			loadct,17
for i=imstart+1,imstop,1 do begin
	print,'...............................'
	;READ_JPEG ,files(i), im, /GRAYSCALE
im = READ_TIFF(files(i), R, G, B)
im=total(im,1)
	l=size(im,/dimensions)
	if (congridfactor ne 1) then im=congrid(im,l(0)*congridfactor,l(1)*congridfactor)
	l=size(im,/dimensions)
	im=rebin(im,l/congridfactor)
	get_specific_feature_offset_2,im,x00,y00
	imshifts(0,k)=x00
	imshifts(1,k)=y00
	xsh=imshifts(0,0)-imshifts(0,k)
	ysh=imshifts(1,0)-imshifts(1,k)
	k=k+1
	print,'Rough shifting image',i,' by :',xsh,ysh
	shifted=shift(im,xsh,ysh)
	im=shifted
	get_best_shift,im0,im,bestXshift,bestYshift,maxXshift,maxYshift,congridfactor
		if (abs(bestXshift) ne maxXshift and abs(bestYshift) ne maxYshift) then begin
			;print,i
			im=shift(im,bestXshift,bestYshift)
			l=size(im,/dimensions)
			stacked=stacked+double(im)
			writefits,strcompress('SHIFTS/shiftedmoon_'+string(count)+'.fits',/remove_all),im
			window,0,xsize=l(0),ysize=l(1)
			device,decomposed=0
			show= HIST_EQUAL(stacked)
			tvscl,show
			xyouts,50,30,string(count-100),/device
			pict=tvrd()
			filename=strcompress('SHIFTS/shiftedmoon_'+string(count)+'.gif',/remove_all)
			write_gif,filename,pict
			; set up some lines across the earthlit side of the disc
			a=150*c
			b=200*c
			d=300*c
			e=100*c
			f=130*c
			;print,a,b,d,a,e,f
			line1=stacked(a,b:d)
			line2=stacked(a,e:f)
			line3=line1-smooth(line1,7,/edge_truncate)
; FT estimate of S/N
line=reform(stacked(a,*))
z=FFT(line,-1)
zz=z*conj(z)
nzz=n_elements(zz)
index=float(total(zz(0:nzz-10))/total(zz))  ; fraction of low -f prower
; Print the signal, noise and signal/noise on screen
print,'1:',' S: ',mean(line1)-mean(line2),' N: ',stddev(line1),' S/N: ',(mean(line1)-mean(line2))/stddev(line1)
print,'2:',' S: ',mean(line1)-mean(line2),' N: ',stddev(line3),' S/N: ',(mean(line1)-mean(line2))/stddev(line3)
print,'3: FF based S/N estimate :',index
; and into a file 'count_vs_SN.dat', first item is the number of frames coadded, second is the broad-band S/N, third is the 'hi-pass' S/N:
printf,66,count,(mean(line1)-mean(line2))/stddev(line1),(mean(line1)-mean(line2))/stddev(line3),index
			count=count+1
	endif
endfor
stacked=stacked/float(count)
close,66
end


;---------------------------------------------------------------------------
; MAIN routine calling the others
; USAGE NOTES:
;	Give the right path to the images you wish to stack in the line below ('files=....')
;	Note the different usage for indicating paths and files in Unix and Windows.
;---------------------------------------------------------------------------
set_plot,'win
; First argument to file_search is the PATH to the images, second argument is the generic NAME of the files:
files=file_search('C:\Documents and Settings\Peter Thejll\Desktop\16bits\','*.TIFF')
congridfactor=1.0
;....................
; perform the alignment and stacking:
howmany=3	;n_elements(files)-1
;----- merg16:
merg16,[files(0),files(1),files(2)],'C:\Documents and Settings\Peter Thejll\Desktop\16bits\merg16_3stack.tif',gamma=2.2
;....................
; save results and do some plotting:
writefits,strcompress('stacked_new_'+string(howmany)+'_uint.FIT',/remove_all),uint(stacked)
writefits,strcompress('stacked_new_'+string(howmany)+'_float.FIT',/remove_all),(stacked)
end
