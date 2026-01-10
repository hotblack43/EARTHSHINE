 PRO gofindradiusandcenter_fromheader,header,x0,y0,radius
 ; Will take a header and read out DISCX0, DISCY0 and RADIUS
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
 return
 end

files=file_search('/data/pth/CUBES/*MkIII_one*',count=n)
openw,28,'POTENTIALLY_bad_cubes.txt'
for i=0,n-1,1 do begin
im=readfits(files(i),header,/sil)
gofindradiusandcenter_fromheader,header,x0,y0,radius
im=reform(im(*,*,0))
im=im/max(im)
im=shift(im,256-x0,256-y0)
; 454.32739   0.00031326114
;  82.673855   0.00017327299
if ((im(82,256) lt 0.00017327299) and (im(454,256) lt 0.00031327299)) then begin
if (i eq 0) then plot,im(*,256),/ylog,yrange=[1e-10,1]
if (i gt 0) then oplot,im(*,256)
endif else begin
print,files(i)
printf,28,files(i)
endelse
endfor
close,28
end

