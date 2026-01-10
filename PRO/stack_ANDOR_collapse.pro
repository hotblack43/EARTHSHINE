;---------------------------------------------------------------------------
; MAIN routine calling the others
; USAGE NOTES:
;	Give the right path to the images you wish to stack in the line below ('files=....')
;	Note the different usage for indicating paths and files in Unix and Windows.
;---------------------------------------------------------------------------
pathname='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455473/'
framename='CoAdd-100Frame-LO-r1.fits'
file=pathname+framename
print,'WIll process ',file
;....................
; indicate the dark frame:
darkfilename='float_MHM_dark_20ms.fits'
dark=readfits(pathname+darkfilename)
;....................
; perform the stacking:
yes_subtract_dark=1	; this will turn on (1) dark-frame subtraction
if (yes_subtract_dark eq 1) then begin
print,'Using dark frame ',pathname+darkfilename
im_big=readfits(file,h)
l=size(im_big,/dimensions)
stacked=total(im_big,3)/float(l(2)) - dark
 sxaddpar, h, 'DARKNAME', darkfilename , 'Name of dark file subtracted'
endif
if (yes_subtract_dark ne 1) then begin
im_big=readfits(file,h)
l=size(im_big,/dimensions)
stacked=total(im_big,3)/float(l(2))
 sxaddpar, h, 'DARKNAME',"" , 'NO dark file subtracted'
endif
 sxaddpar, h, 'PROCESSING',"" , 'NO alignments performed'
 sxaddpar, h, 'N_COADD', l(2), 'Number of frames averaged over'
 sxaddpar, h, 'ORIG_NAM', framename, 'Name of original science frame'
;....................
; save results and do some plotting:
writefits,strcompress(pathname+'stacked_'+framename,/remove_all),stacked,h
print,'Straight stacking done - no alignemnts, see ',strcompress(pathname+'stacked_'+framename,/remove_all)
end
