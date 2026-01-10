 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
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

;----------------------------------------------
file='somefilestoinspect.txt'
!P.MULTI=[0,2,7]
openr,1,file
while not eof(1) do begin
str=''
readf,1,str
bits=strsplit(str,' ',/extract)
B=readfits(bits(0),Bheader)
V=readfits(bits(1),Vheader)
getcoordsfromheader,Bheader,Bx0,By0,radius
getcoordsfromheader,Vheader,Vx0,Vy0,radius
get_EXPOSURE,Bheader,Bexptime
get_EXPOSURE,Vheader,Vexptime
; get rid of some sky level
B=B-mean(B(50:100,By0-20:By0+20))
V=V-mean(V(50:100,Vy0-20:Vy0+20))
; get fluxes
B=B/Bexptime(0)
V=V/Vexptime(0)
print,'flux ratio B/V: ',total(B,/double)/total(V,/double)
; shift V to B position
V=shift_sub(V,Bx0-Vx0,By0-Vy0)
both=[B,V]
decomposed=0
contour,/isotropic,title=str,hist_equal(both),/cell_fill

plot,ytitle='B-V [fluxes - cts/s]',xstyle=3,B(*,By0)-V(*,Vy0),yrange=[-60,6]
endwhile
close,1
end
