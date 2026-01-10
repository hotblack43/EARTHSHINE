 PRO getcoordsfromheader,header,x0,y0,radius
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
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),15,9))
     endelse
 x0=x0[0]
 y0=y0[0]
 radius=radius[0]
 return
 end

;
im=readfits('data/pth/DARKCURRENTREDUCED/SELECTED_4/2456017.7279621MOON_VE2_AIR_DCR.fits',h)
getcoordsfromheader,h,x0,y0,radius
im=shift_sub(im,256-x0,256-y0)
a=''
while (a ne 'q') do begin
im_reversed=hist_equal(reverse(im,1))
tvscl,im/total(im)-im_reversed/total(im_reversed)
a=get_kbrd()


endwhile
end

