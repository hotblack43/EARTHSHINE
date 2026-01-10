PRO get_specific_feature_offset_2,im,x0,y0
;--------------------------------------------------------------------------------
; Routine to indicate a feature on the lunar disc - used for alignment purposes
; Works by using the 'center of gravity' of the pixel counts in the image.
;	im	:(INPUT)	: The image 
;
;	x0,y0	:(OUTPUT)	: The coordinates in image frame of the C.G.
;--------------------------------------------------------------------------------
help,im
; sum along rows
x=total(im,2)
x0=where(x eq max(x))
; sum along cols
y=total(im,1)
y0=where(y eq max(y))
tvscl,im
; plot a hair cross
plots,[x0,x0],[!Y.CRANGE]
plots,[!X.CRANGE],[y0,y0]
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
tvscl,im
cursor,a,b,/data
print,a,b
x0=a
y0=b
return
end

PRO	get_best_shift,im0_in,im_in,bestXshift,bestYshift,maxXshift,maxYshift
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
print,bestcorr,bestXshift,bestYshift
return
end


PRO stack,files,stacked,dark,howmany,yes_subtract_dark
;--------------------------------------------------------------------------------
; Routine to align and stack a set of images
; files		:(INPUT)	: a list of filenames indicating the images to b stacked
; dark		:(INPUT)	: the dark frame to subtract from all images
; howmany	:(INPUT)	: how many frames you wish to coadd
;
; stacked	:(OUTPUT)	: the frame resulting after alignment and averaging
;--------------------------------------------------------------------------------
openw,66,'count_vs_SN.dat'
n=n_elements(files)
; get the appropriate flat field
factor=1	; rebinning factor
;======================================================
; get images and their offsets
; indicate how many images you wish to coadd
imstart=0
imstop=imstart+howmany-1
imshifts=intarr(2,imstop-imstart+1)*0+9999
k=0
openw,56,'2pixels.dat'
for i=imstart,imstop,1 do begin
	im=float(readfits(files(i)))
 	if (yes_subtract_dark eq 1) then im=im-dark
	l=size(im,/dimensions)
	if (factor ne 1) then im=rebin(im,l/factor)
	get_specific_feature_offset_2,im,x00,y00
	;get_specific_feature_offset,im,x00,y00
	imshifts(0,k)=x00
	imshifts(1,k)=y00
	if (i eq imstart) then stack=im
	if (i ne imstart) then begin
		xsh=imshifts(0,0)-imshifts(0,k)
		ysh=imshifts(1,0)-imshifts(1,k)
		print,'shifting image ',i,' by :',xsh,ysh
		shifted=shift(im,xsh,ysh)
		stack=[[[stack]],[[shifted]]]
	endif
	k=k+1
endfor
idx=where(imshifts(0,*) ne 9999)
imshifts=imshifts(*,idx)
stack=stack(*,*,idx)
l=size(stack,/dimensions)
print,l
stop
nims=l(2)
;======================================================
maxXshift=2
maxYshift=2
im0=stack(*,*,0)
tvscl,im0
stacked=float(im0)
count=0
idcols=[53,63,69,106,136,176,200,220,246,276,282,287]
for i=1,nims-1,1 do begin
	im=stack(*,*,i)
	get_best_shift,im0,im,bestXshift,bestYshift,maxXshift,maxYshift
		if (abs(bestXshift) ne maxXshift and abs(bestYshift) ne maxYshift) then begin
			print,i,'best shift:',bestXshift,bestYshift
			im=shift(im,bestXshift,bestYshift)
			if (i eq 1) then stack2=im
			if (i gt 1) then stack2=[[[stack2]],[[im]]]
row=im(idcols,254)
printf,format='(12(f8.2,1x))',56,row
print,format='(12(f8.2,1x))',row
			stacked=stacked+float(im)
			window,0,xsize=500,ysize=500
			device,decomposed=0
			loadct,17
			show= HIST_EQUAL(stacked)
			tvscl,show
			window,2,xsize=110,ysize=110
			subim=stacked(60:160,220:320)
			subim=HIST_EQUAL(subim)
			tvscl,subim
			; set up some lines across the earthlit side of the disc
				line1=stacked(150,200:300)
				line2=stacked(150,100:130)
				line3=line1-smooth(line1,7,/edge_truncate)
				; Print the signal, noise and signal/noise on screen
print,'1:',' S: ',mean(line1)-mean(line2),' N: ',stddev(line1),' S/N: ',(mean(line1)-mean(line2))/stddev(line1)
print,'2:',' S: ',mean(line1)-mean(line2),' N: ',stddev(line3),' S/N: ',(mean(line1)-mean(line2))/stddev(line3)
; and into a file 'count_vs_SN.dat', first item is the number of frames coadded, second is the broad-band S/N, third is the 'hi-pass' S/N:
printf,66,count,(mean(line1)-mean(line2))/stddev(line1),(mean(line1)-mean(line2))/stddev(line3)
			count=count+1
		endif
endfor
stacked=stacked/float(count)
close,66
close,56
print,'SAving stack ...'
SAVE,stack2,filename='aligned_stack.sav'
end


;---------------------------------------------------------------------------
; MAIN routine calling the others
; USAGE NOTES:
;	Give the right path to the images you wish to stack in the line below ('files=....')
;	Note the different usage for indicating paths and files in Unix and Windows.
;---------------------------------------------------------------------------
; First argument to file_search is the PATH to the images, second argument is the generic NAME of the files:
pathname='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455473/'
; Lund mode
; files=file_search(pathname,'Moon-LundMode-30s-10_R2_*',count=ncount)
; coAdd mode
files=file_search(pathname,'CoAdd-100Frame-r1.fits',count=ncount)
;....................
; indicate the dark frame:
dark=readfits(pathname+'float_MHM_dark_20ms.fits')
;....................
; perform the alignemnt and stacking:
howmany=ncount
yes_subtract_dark=1	; this will turn on (1) dark-frame subtraction
stack,files,stacked,dark,howmany,yes_subtract_dark
;....................
; save results and do some plotting:
writefits,strcompress('stacked_float.FIT',/remove_all),(stacked)
set_plot,'ps
tvscl,stacked
plot,total(stacked,2)
plot_io,total(stacked,2)
device,/close
print,'Finished: Now inspect the results for statistics in the file count_vs_SN.dat'
end
