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
     radius=float(strmid(header(jdx),11,19))
     endelse
 x0=x0(0)
 y0=y0(0)
 radius=radius(0)
 return
 end

openr,1,'diskcoordinates_usethese.txt'

path='/data/pth/DARKCURRENTREDUCED/SELECTED_4d/'
openw,34,'badfiles_coordinatewise.txt'
openw,33,'deltas_x0_y0_radius.dat'
while not eof(1) do begin
str=''
readf,1,str
bits=strsplit(str,' ',/extract)
x0=bits(0)
y0=bits(1)
r=bits(2)
err1=bits(3)
err2=bits(4)
err3=bits(5)
err4=bits(6)
err5=bits(7)
fna=bits(8)
im=readfits(path+fna,header,/sil)
gofindradiusandcenter_fromheader,header,x00,y00,radius
printf,33,x0-x00,y0-y00,r-radius
if (abs(x0-x00) gt 1.6 or abs (y0-y00) gt 1.6 or abs(r-radius) gt 1.6) then printf,34,path+fna
endwhile
close,1
 close,33
 close,34
;
data=get_data('deltas_x0_y0_radius.dat')
!P.MULTI=[0,2,3]
!p.charsize=2.7
!p.charthick=2
!P.thick=4
print,median(data(0,*)),robust_sigma(data(0,*))
print,median(data(1,*)),robust_sigma(data(1,*))
print,median(data(2,*)),robust_sigma(data(2,*))
histo,data(0,*),-6,6,0.2,xtitle='!7D!3x',/abs
histo,data(1,*),-6,6,0.2,xtitle='!7D!3y',/abs
histo,data(2,*),-6,6,0.2,xtitle='!7D!3r',/abs
end
