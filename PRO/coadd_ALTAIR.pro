PRO get_coordsandscale,h,x0,y0,X0RA,y0DEC,scale
idx=where(strpos(h,'COMMENT scale') ne -1)
str=h(idx)
bits=strsplit(str,' ',/extract)
scale=double(bits(2))
;
idx=where(strpos(h,'CRPIX1') ne -1)
str=h(idx)
bits=strsplit(str,' ',/extract)
x0=double(bits(2))
;
idx=where(strpos(h,'CRPIX2') ne -1)
str=h(idx)
bits=strsplit(str,' ',/extract)
y0=double(bits(2))
;
idx=where(strpos(h,'CRVAL1') ne -1)
str=h(idx)
bits=strsplit(str,' ',/extract)
x0RA=double(bits(2))
;
idx=where(strpos(h,'CRVAL2') ne -1)
str=h(idx)
bits=strsplit(str,' ',/extract)
y0DEC=double(bits(2))
;
return
end

;--------------------------
; Main
files=file_search('/media/OLDHD/ALTAIR/*.new',count=n)
nref=50
im=readfits(files(nref),h)
stack=im
get_coordsandscale,h,x0,y0,x0RA,y0DEC,scale0
openw,55,'shifts.dat'
for i=0,n-1,1 do begin
if (i ne nref) then begin
im=readfits(files(i),h2,/silent)
get_coordsandscale,h2,x,y,xRA,yDEC,scale
delta_x=x-x0+(xRA-x0RA)*3600.0d0/(scale*cos(!dtor*abs(yDEC)))
delta_y=y-y0+(yDEC-y0DEC)*3600.0d0/scale
print,x-x0,(xRA-x0RA)*3600.0d0/scale
vector=sqrt(delta_x^2+delta_y^2)
if (vector lt 3000) then begin
subim=shift_sub(im,-delta_x,-delta_y)
;subim=im
tvscl,subim
stack=[[[stack]],[[subim]]]
printf,55,delta_x,delta_y
print,delta_x,delta_y
endif
endif
endfor
close,55
avim=avg(stack,2)
tvscl,hist_equal(avim)
writefits,'avim.fits',avim,h
end
