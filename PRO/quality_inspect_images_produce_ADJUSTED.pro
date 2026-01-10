 PRO get_circle,x0,y0,circle,radius_in,maxval
 radius=radius_in(0)
 circle=fltarr(512,512)*0.0
 astep=0.1d0
 for angle=0.0d0,360.0d0-astep,astep do begin
     x=x0+radius*cos(angle*!dtor)
     y=y0+radius*sin(angle*!dtor)
     if ((x ge 0 and x le 511) and (y ge 0 and y le 511)) then circle(x,y)=maxval
     endfor
 return
 end

PRO adjustcircleandreturnabetterheader,im_in,header,x0,y0,radius,q_flag
im=im_in
x0_in=x0
y0_in=y0
radius_in=radius
; in a loop waiting for 'q' do this:
; build circle, shown on image
; read keys, shift circle
; wait for either 'b' for 'bad image' and then set q_flag, or 'r' to return updated header
maxval=max(im)
q_flag=1
a=''
print,'Adjust with: e/E u/d r/l b c/C   q to write file and next image'
while (a ne 'q') do begin
maxval=max(im)
get_circle,x0,y0,circle,radius,maxval
tvscl,im+circle
a=get_kbrd()
dx=0.7876
dy=0.7876
dr=0.25
if (a eq 'e') then begin; toggle histogram_equalization on image
im=alog10(im_in)
;im=hist_equal(im_in)
endif
if (a eq 'E') then begin; toggle histogram_equalization on image
im=im_in
endif
if (a eq 'u') then begin; shift circle up
y0=y0+dy
endif
if (a eq 'd') then begin; shift circle down
y0=y0-dy*1.07654
endif
if (a eq 'r') then begin; shift circle right
x0=x0+dx
endif
if (a eq 'l') then begin; shift circle right
x0=x0-dx*1.05643
endif
if (a eq 'b') then begin; image is bad somehow so set the bad falg
q_flag=999
endif
if (a eq 'c') then begin; radius is too large, decrease
radius=radius-dr
endif
if (a eq 'C') then begin; radius is too small, increase
radius=radius+dr
endif
print,'Adjust with: e u/d r/l b c/C   q to write file and next image'
endwhile
; update header with sxaddpar stuff - set DISCX0, DISCY0
if (x0 ne x0_in) then sxaddpar, header, 'DISCX0',x0, 'Disc centre in x, estimated by eye'
if (y0 ne y0_in) then sxaddpar, header, 'DISCY0',y0, 'Disc centre in y, estimated by eye'
if (radius ne radius_in) then sxaddpar, header, 'RADIUS',radius, 'Disc radius, estimated by eye'
return
end

 PRO gostripthename,str,fitsname
 ;xx=strpos(str,'245')
 ;fitsname=strmid(str,xx,strlen(str)-xx)
 str2=strsplit(str,'/',/extract)
 fitsname=str2(n_elements(str2)-1)
 return
 end

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
 idx=strpos(header,'DISCRA')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCRA not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),15,9))
     endelse
 return
 end

files='allfilestoinspect.txt'
get_lun,edm
openr,edm,files
while not eof(edm) do begin
str=''
readf,edm,str
im=readfits(str,header,/silent)
getcoordsfromheader,header,x0,y0,radius
x0=x0(0)
y0=y0(0)
radius=radius(0)
gostripthename,str,basicname
adjustcircleandreturnabetterheader,im,header,x0,y0,radius,q_flag
if (q_flag eq 999) then basicname='BAD_'+basicname
writefits,'ADJUSTED/'+basicname,im,header
endwhile
close,edm
free_lun,edm
end
