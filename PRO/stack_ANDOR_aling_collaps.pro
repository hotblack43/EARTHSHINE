FUNCTION stackalign,im
; will align and the stack the images inside 'im'
l=size(im,/dimensions)
if (n_elements(l) eq 2) then stop
nims=l(2)
; first align the frames
stack=reform(im(*,*,0))
im0=reform(im(*,*,0))
for ii=1,nims-1,1 do begin
OFFSET  =  alignoffset(reform(im(*,*,ii)), im0, Cor)
newim=ROT(reform(im(*,*,ii)), 0.0, 1.0,OFFSET(0),OFFSET(1), CUBIC=-0.5)
stack=[[[stack]],[[newim]]]
tvscl,newim
endfor
; then sum
stacked=total(stack,3)
stop
return,stacked
end

PRO parseit,str,framename,darkfilename
idx=strpos(str,' ')
framename=strmid(str,0,idx)
darkfilename=strmid(str,idx+1,strlen(str))
return
end

;---------------------------------------------------------------------------
; Will align and 'collapse' a set of images found
; in a single FITS file
;-----------------------------------------------------------
; will work on a set of files named in the file 'files'
; files is set up as 
; name1 darkname1
; name2 darkname2
; name3 darkname3
; where 'nameX' is the name of a FITS field containing many scienceframes, and
; 'darknameX' is the dark field to use 
;---------------------------------------------------------------------------
yes_subtract_dark=1	; this will turn on (1) dark-frame subtraction
pathname='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455473/'
framename=''
darkfilename=''
openr,1,'files'
while not eof(1) do begin
	str=''
	readf,1,str & parseit,str,framename,darkfilename
	file=pathname+framename
	print,'WIll process ',file
	;....................
	; indicate the dark frame:
	dark=readfits(pathname+darkfilename)
	;....................
	; perform the stacking:
	if (yes_subtract_dark eq 1) then begin
		print,'Using dark frame ',pathname+darkfilename
		im_big=readfits(file,h)
		l=size(im_big,/dimensions)
		stacked=stackalign(im_big)/float(l(2)) - dark
 		sxaddpar, h, 'DARKNAME', darkfilename , 'Name of dark file subtracted'
	endif
	if (yes_subtract_dark ne 1) then begin
		im_big=readfits(file,h)
		l=size(im_big,/dimensions)
		stacked=stackalign(im_big)/float(l(2))
 		sxaddpar, h, 'DARKNAME',"" , 'NO dark file subtracted'
	endif
 	sxaddpar, h, 'PROCESSING',"" , 'Alignments performed'
 	sxaddpar, h, 'N_COADD', l(2), 'Number of frames averaged over'
 	sxaddpar, h, 'ORIG_NAM', framename, 'Name of original science frame'
	;....................
	; save results and do some plotting:
	writefits,strcompress(pathname+'align_stacked_'+framename,/remove_all),stacked,h
	print,'Alignment and stacking done, see ',strcompress(pathname+'align_stacked_'+framename,/remove_all)
	endwhile
close,1
end
