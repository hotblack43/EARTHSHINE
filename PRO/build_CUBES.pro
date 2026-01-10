 PRO getcoordsfromheader,header,x0,y0,radius,discra
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     x0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     y0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCRA')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCRA not in header. Assigning dummy value'
     discra=134.327880000
     endif else begin
     discra=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),15,9))
     endelse
 return
 end

 PRO determineFLIP2,ideal_in,raw_in,x0,y0,refimFLIPneed,refimFLOPneed
 raw=raw_in/max(raw_in)
 ideal=ideal_in/max(ideal_in)
 ;window,1,xsize=1024,ysize=512
 ;...........................
 ; no flip or flop
 ; shift ideal to same position as observed
 ideal=shift(ideal,x0-256,y0-256)
 r1=correlate(raw,ideal)
 ;..........................
 ; just a flip
 ideal=ideal_in/max(ideal_in)
 ideal=reverse(ideal,1)
 ideal=shift(ideal,x0-256,y0-256)
 r2=correlate(raw,ideal)
 ;..........................
 ; just a flop
 ideal=ideal_in/max(ideal_in)
 ideal=reverse(ideal,2)
 ideal=shift(ideal,x0-256,y0-256)
 r3=correlate(raw,ideal)
 ;..........................
 ; a flip and a flop
 ideal=ideal_in/max(ideal_in)
 ideal=reverse(reverse(ideal,1),2)
 ideal=shift(ideal,x0-256,y0-256)
 r4=correlate(raw,ideal)
 ;..........................
 r=[r1,r2,r3,r4]
 idx=where(r eq max(r))
 if (idx eq 0) then begin
     refimFLIPneed=0
     refimFLOPneed=0
     return
     endif
 if (idx eq 1) then begin
     refimFLIPneed=1
     refimFLOPneed=0
     return
     endif
 if (idx eq 2) then begin
     refimFLIPneed=0
     refimFLOPneed=1
     return
     endif
 if (idx eq 3) then begin
     refimFLIPneed=1
     refimFLOPneed=1
     return
     endif
 end
 
 PRO dotheflipflop,im1,x0,y0,flipneed,flopneed
 if (flipneed eq 1) then begin
     im1=reverse(im1,1)
     endif
 if (flopneed eq 1) then begin
     im1=reverse(im1,2)
     endif
 ; then shift to match observed image c entre
 im1=shift(im1,x0-256,y0-256)
return
end

;======================================================
; Version 1 of code that bilds 'cubes' of data with 9 fields
; 0 = observed image
; 1 =
; 2 =
; 3 =
; 4 = ideal image
; 5 = longitude image
; 6 = latitude image
; 7 = in-angle image
; 8 = out-angle image
;=========================================================
close,/all
openr,1,'Vjds.list'
while not eof(1) do begin
jdstr=''
readf,1,jdstr
if (jdstr eq 'stop') then stop
str='/data/pth/DARKCURRENTREDUCED/SELECTED_4/'+jdstr+'*'
imfile=file_search(str)
if (imfile(0) ne  '') then begin
obs=readfits(imfile,header)
getcoordsfromheader,header,x0,y0,radius,discra
;-----------
atall=file_search('OUTPUT/IDEAL/ideal_LunarImg_SCA_0p310_JD_'+jdstr+'.fit')
if (atall ne '') then begin
ideal=readfits('OUTPUT/IDEAL/ideal_LunarImg_SCA_0p310_JD_'+jdstr+'.fit')
lonlat=readfits('OUTPUT/lonlatSELimage_JD'+jdstr+'.fits')
inout=readfits('OUTPUT/Angles_JD'+jdstr+'.fits')
cube=[]
lonim=lonlat(*,*,0)
latim=lonlat(*,*,1)
inangle=inout(*,*,0)
outangle=inout(*,*,1)
obsangle=inout(*,*,2)
blank=obs*0.0
; check if flip/flops are eeded
determineFLIP2,ideal,obs,x0,y0,flipneed,flopneed
cube=[[[cube]],[[obs]]]
cube=[[[cube]],[[blank]]]
cube=[[[cube]],[[blank]]]
cube=[[[cube]],[[blank]]]
 dotheflipflop,ideal,x0,y0,flipneed,flopneed
cube=[[[cube]],[[ideal]]]
 dotheflipflop,lonim,x0,y0,flipneed,flopneed
cube=[[[cube]],[[lonim]]]
 dotheflipflop,latim,x0,y0,flipneed,flopneed
cube=[[[cube]],[[latim]]]
 dotheflipflop,inangle,x0,y0,flipneed,flopneed
cube=[[[cube]],[[inangle]]]
 dotheflipflop,outangle,x0,y0,flipneed,flopneed
cube=[[[cube]],[[outangle]]]
 dotheflipflop,obsangle,x0,y0,flipneed,flopneed
cube=[[[cube]],[[obsangle]]]
outname='CUBES/cube_MkV_JD'+jdstr+'.fits'
writefits,outname,cube,header
endif
endif
endwhile
close,1
end
