PRO get_circle,l,coords,circle,radius,maxval
circle=fltarr(l)*0.0
astep=0.1d0
x0=coords(0)
y0=coords(1)
for angle=0.0d0,360.0d0-astep,astep do begin
	x=x0+radius*cos(angle*!dtor)
	y=y0+radius*sin(angle*!dtor)
print,x,y
	circle(x,y)=maxval
endfor
return
end
 PRO getcoordsfromheader,header,x0,y0,radius1,radius2,discra
 ; get X0
 idx=strpos(header,'DISCX0')
 jdx=where(idx ne -1)
 if (jdx(0) eq -1) then stop
 X0=float(strmid(header(jdx),10,19))
 ; get Y0
 idx=strpos(header,'DISCY0')
 jdx=where(idx ne -1)
 if (jdx(0) eq -1) then stop
 Y0=float(strmid(header(jdx),10,19))
 ; get DISCRA
 idx=strpos(header,'DISCRA')
 jdx=where(idx ne -1)
 if (jdx(0) eq -1) then stop
 discra=float(strmid(header(jdx),10,19))
 ; get RADIUS1
 idx=strpos(header,'Radius estimated from JD')
 jdx=where(idx ne -1)
 if (jdx(0) eq -1) then stop
 radius1=float(strmid(header(jdx),10,19))
 ; get RADIUS2
 idx=strpos(header,'Radius estimated from model image')
 jdx=where(idx ne -1)
 if (jdx(0) eq -1) then stop
 radius2=float(strmid(header(jdx),10,19))
;
x0=x0(0)
y0=y0(0)
radius1=radius1(0)
radius2=radius2(0)
discra=discra(0)
 return
 end

PRO make_circle,x0,y0,r,im_in
x0=x0(0)
y0=y0(0)
r=r(0)
angle=findgen(6000)/6000.*360.0
x=fix(x0+r*cos(angle*!dtor))
y=fix(y0+r*sin(angle*!dtor))
im_in(x,y)=max(im_in)
return
end

PRO adjustcircleandreturnabetterheader,im,header,x0,y0,radius,q_flag
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
while (a ne 'q') do begin
im_in=im
make_circle,x0,y0,radius,im_in
tvscl,im_in
a=get_kbrd()
dx=0.9876
dy=0.9876
dr=0.25
print,'use. e u,d,r,l b,c,C'
if (a eq 'e') then begin; toggle histogram_equalization on image
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
endwhile
; update header with sxaddpar stuff - set DISCX0, DISCY0
if (x0 ne x0_in) then sxaddpar, header, 'DISCX0',x0, 'Disc centre in x, estimated by eye'
if (y0 ne y0_in) then sxaddpar, header, 'DISCY0',y0, 'Disc centre in y, estimated by eye'
if (radius ne radius_in) then sxaddpar, header, 'DISCRA',radius, 'Disc radius, estimated by eye'
return
end

 PRO gostripthename,str,fitsname
 str2=strsplit(str,'/',/extract)
 fitsname=str2(n_elements(str2)-1)
 return
 end



;------------------------------------------------
; Inspect correctness of RADIUS and X0,Y0 in CUBE images
;------------------------------------------------
; Update header if correction needed
;------------------------------------------------
window,0,xsize=1024,ysize=512
files=file_search('/data/pth/CUBES/*MkII*.fit*',count=n)
for i=0,n-1,1 do begin
str=files(i)
gostripthename,str,fitsname
q_flag=0
im=readfits(files(i),header,/sil)
getcoordsfromheader,header,x0,y0,radius1,radius2,discra
raw=reform(im(*,*,0))
adjustcircleandreturnabetterheader,raw,header,x0,y0,discra,q_flag
writefits,'ADJUSTED/'+fitsname,im,header
endfor
end

