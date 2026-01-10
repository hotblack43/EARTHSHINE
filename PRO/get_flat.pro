pro get_flat, files,  flat_file, darkfile, l, m,   $
                 ndark_integ=ndark_integ, ndata_integ=ndata_integ,  $
        object=object, c=c, maxiter=maxiter, xr=xr, yr=yr, shift_flag=shift_flag, $
        minfrac=minfrac, setmask=setmask, mask=mask
;+
; NAME: GET_FLAT
; PURPOSE: Produce the flat patterns for arbitray  observations
; CALLING SEQUENCE:
;         GET_flat, files, flat_file, darkfile
; INPUT:
;      files        an array of  data files
;      flat_file   a flat image file to be written
;
; OPTIONAL INPUT:
;      darkfile    a dark frame file
; INPUT KEYWORDS:
;   subpixel    if set, the determnaition is done with subpixel-accuracy
;   shift          if set, the given shift is used.
;   setmask      if set,  the routine allows the user to select the pixels at which
;                the flat pattern is to be determined.
;   minfrac      if set, the data is enforced to have values greater than or equal to
;                 minfrac*median(data)
;  HISTORY
;        2004 July, J. Chae. Added new keywords: setmask and minfrac
;-

          ; Read Dark Frames

if n_elements(ndata_integ) eq 0 then ndata_integ=1.
if n_elements(ndark_integ) eq 0 then ndark_integ=1.
if n_elements(minfrac) eq 0 then minfrac=0.01
if n_elements(darkfile) eq 0 then begin
   dark=0.
endif else if darkfile eq '' then begin
   dark=0.
endif else begin
 dark=float(readfits(darkfile, /sil))/ndark_integ

endelse

          ; Read Data and subtract dark levels

nf = n_elements(files)


for k=0, nf-1 do begin
    tmp=(float(readfits(files(k), /sil))/ndata_integ -dark)

     if k eq 0 then begin
     s=size(tmp)
     if n_elements(xr) ne 2 then xr=[0, s(1)-1]
     if n_elements(yr) ne 2 then yr=[0, s(2)-1]
     nx=xr(1)-xr(0)+1
      ny=yr(1)-yr(0)+1
     logimages=fltarr(nx, ny, nf)
     endif
     m1=median(tmp(xr(0):xr(1), yr(0):yr(1)))*minfrac
    logimages(*,*,k) = alog(tmp(xr(0):xr(1), yr(0):yr(1))>m1 )
    tvscl, logimages(*,*,k)
endfor

if keyword_set(setmask) then begin
select=xdefroi(logimages(*,*,nf/2))

mask0 = replicate(0B, nx, ny)
mask0(select)=1
mask=bytarr(nx, ny, nf)
for k=0, nf-1 do mask[*,*,k]=mask0

endif



;t1=systime(/second)
flat = gaincalib (logimages, l, m,object=object,c=c,  mask=mask, maxiter=maxiter, shift_flag=shift_flag)
;t2=systime(/second)
;print, t2-t1, ' seconds elapsed!'


flat1=replicate(1., s(1), s(2))
flat1(xr(0):xr(1), yr(0):yr(1))=exp(flat)
object1=replicate(exp(median(object)), s(1), s(2))
object1(xr(0):xr(1), yr(0):yr(1))=exp(object)
object=object1
c=exp(c)
flat=fix(round(((flat1-1.)>(-1.)<2.)*30000))
fxhmake,  h, flat
fxaddpar, h, 'BSCALE', 1/30000.
fxaddpar, h, 'BZERO', 1.
writefits, flat_file, flat, h

end

