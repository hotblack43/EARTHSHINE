 PRO gostripthename,str,fitsname
 ;xx=strpos(str,'245')
 ;fitsname=strmid(str,xx,strlen(str)-xx)
 str2=strsplit(str,'/',/extract)
 fitsname=str2(n_elements(str2)-1)
 return
 end

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

get_lun,ccv
openw,ccv,'info.dat'
files=file_search('/data/pth/DARKCURRENTREDUCED/SELECTED_1/*.fits',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i),header,/silent)
gofindradiusandcenter_fromheader,header,x0,y0,radius
gostripthename,files(i),fitsname
print,format='(3(1x,f9.4),1x,a)',x0,y0,radius,fitsname
printf,ccv,format='(3(1x,f9.4),1x,a)',x0,y0,radius,fitsname
endfor
close,ccv
free_lun,ccv
end
