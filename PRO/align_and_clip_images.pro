FUNCTION stackalign,im
 ; will align and the stack the images inside 'im'
 l=size(im,/dimensions)
 if (n_elements(l) eq 2) then stop
 nims=l(2)
stack=im
; first align the frames
stack=reform(im(*,*,0))
im0=stack
for ii=1,nims-1,1 do begin
    OFFSET  =  alignoffset(reform(im(*,*,ii)), im0, Cor)
print,ii,offset
    newim=shift_sub(reform(im(*,*,ii)), -OFFSET(0), -OFFSET(1))
    stack=[[[stack]],[[newim]]]
    endfor
; then average
 stacked=avg(stack,2,/double)
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
 
 ;---------------------------------------------------------------------
 ; Will align and clip images found in a directory
 ;---------------------------------------------------------------------
 ; will work on a set of files named in the file 'files'
 ; it is assumed that these images already has had the bias subtracted!
 ;---------------------------------------------------------------------
 lolimit=10000
 maxlim=55000
 openr,1,'files'
	ic=0
 ; first read all images, scale them to same flux and place in a 3D-cube
 while not eof(1) do begin
     str=''
     readf,1,str  
         im=readfits(str,h,/silent)
; select frames that have a chance of being good
	 if (max(im) gt lolimit and max(im) lt maxlim) then begin
	print,'Accepted ',str
	if (ic eq 0) then stack=im/max(im)*55000.0
	if (ic gt 0) then stack=[[[stack]],[[im/max(im)*55000.0]]]
	ic=ic+1
	endif
     endwhile
 close,1
; now go and align those images in 'stack'
 average=stackalign(stack)
; and write it out
sxaddpar, h, 'PROCESSING', ic, 'frames used in stacking'
writefits,'aligned.fits',average,h
 end
