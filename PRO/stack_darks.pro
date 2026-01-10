PRO get_meanhalfmedianval,im,meanhalfmedianval
l=size(im,/dimensions)
lo=fix(l(2)*0.2)
hi=fix(l(2)*0.8)
meanhalfmedianval=fltarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
for j=0,l(1)-1,1 do begin
line=im(i,j,*)
line=line(sort(line))
middle=line(lo:hi)
meanhalfmedianval(i,j)=mean(middle)
endfor
endfor
return
end

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
contour,im
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
contour,im
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


PRO stack_darks_special,files,stacked
;--------------------------------------------------------------------------------
; Routine to align and stack a set of images using the mean half median method
; files		:(INPUT)	: a filename indicating the stack to be stacked
; stacked	:(OUTPUT)	: the frame resulting after alignment and averaging
;--------------------------------------------------------------------------------
bigstack=readfits(files,h)
l=size(bigstack,/dimensions)
nims=l(2)
get_meanhalfmedianval,bigstack,meanhalfmedianval
stacked=meanhalfmedianval
help,stacked
return
end

;---------------------------------------------------------------------------
; MAIN routine calling the others
; USAGE NOTES:
;	Give the right path to the images you wish to stack in the line below ('files=....')
;	Note the different usage for indicating paths and files in Unix and Windows.
;---------------------------------------------------------------------------
; First argument to file_search is the PATH to the images, second argument is the generic NAME of the files:
path='/media/LaCie/ASTRO/ANDOR/EXTRACTED/'
path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455469/
path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455473/'
files=file_search(path,'Dark-15s-10Frame.fits',count=ncount)
;....................
; perform the alignemnt and stacking:
stack_darks_special,files,stacked
;....................
; save results and do some plotting:
;writefits,strcompress('UINT_dark.fits',/remove_all),uint(stacked)
writefits,strcompress('float_dark.fits',/remove_all),(stacked)
set_plot,'ps
contour,stacked
plot,total(stacked,2)
plot_io,total(stacked,2)
device,/close
print,'Finished: Now inspect the results for statistics in the file count_vs_SN.dat'
end
