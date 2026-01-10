FUNCTION stackalign,im
 ; will align and the stack the images inside 'im'
 l=size(im,/dimensions)
 help,im
 if (n_elements(l) eq 2) then stop
 nims=l(2)
stack=im
; first align the frames
;stack=reform(im(*,*,0))
;im0=stack
;tvscl,im0
;for ii=1,nims-1,1 do begin
;    OFFSET  =  alignoffset(reform(im(*,*,ii)), im0, Cor)
;print,ii,offset
;printf,44,ii,offset
;    newim=shift_sub(reform(im(*,*,ii)), -OFFSET(0), -OFFSET(1))
;    stack=[[[stack]],[[newim]]]
;    tvscl,total(stack,3)
;    endfor
;; then sum
 stacked=total(stack,3,/double)
 return,stacked
 end
 
 PRO parseit,str,framename,darkfilename
 idx=strpos(str,' ')
 framename=strmid(str,0,idx)
 darkfilename=strmid(str,idx+1,strlen(str))
 print,'PARSEIT: str=',str
 print,'PARSEIT: framename=',framename
 print,'PARSEIT: darkfilename=',darkfilename
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
window,1,xsize=512,ysize=512
 openw,44,'offsets.dat'
 yes_subtract_dark=1	; this will turn on (1) dark-frame subtraction
 pathname='~/EROS/'
 framename=''
 darkfilename=''
 openr,1,'files'
 while not eof(1) do begin
     str=''
     readf,1,str & parseit,str,framename,darkfilename
     file=pathname+framename
	print,'Will test existence of ',file
     if (file_exist(file) eq 1) then begin 
	print,'Will process ',file
	print,'I have tested that it exists!'
     end else begin
	stop
     endelse
     ;....................
     ; indicate the dark frame:
     dark=readfits(strcompress(pathname+darkfilename,/remove_all),/NOSCALE)
	print,'Mean of dark frame is :',mean(dark)
     ;....................
     ; perform the stacking:
     if (yes_subtract_dark eq 1) then begin
         print,'Using dark frame ',pathname+darkfilename
         print,'Using file       ',file
         im_big=readfits(file,h,/NOSCALE)
         l=size(im_big,/dimensions)
         stacked=stackalign(im_big)/float(l(2)) - dark
         sxaddpar, h, 'DARKNAME', darkfilename , 'Name of dark file subtracted'
         print,'Corner value : ',mean(stacked(0:10,0:10)),mean(dark(0:10,0:10))
         endif
     if (yes_subtract_dark ne 1) then begin
         im_big=readfits(file,h,/NOSCALE)
         l=size(im_big,/dimensions)
         stacked=stackalign(im_big)/float(l(2))
         sxaddpar, h, 'DARKNAME',"" , 'NO dark file subtracted'
         endif
     sxaddpar, h, 'PROCESSING',"" , 'Alignments performed'
     sxaddpar, h, 'N_COADD', l(2), 'Number of frames averaged over'
     sxaddpar, h, 'ORIG_NAM', framename, 'Name of original science frame'
     ;....................
     ; save results and do some plotting:
     writefits,strcompress(pathname+'align_stacked_'+framename,/remove_all),float(stacked),h
     print,'Alignment and stacking done, see ',strcompress(pathname+'align_stacked_'+framename,/remove_all)
     endwhile
 close,1
close,44
 end
