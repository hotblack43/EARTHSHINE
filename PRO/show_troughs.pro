PRO if_rotated,header,iflag
iflag=314
idx=where(strpos(header,'ROTATED') ne -1)
if (idx(0) eq -1) then return
iflag=1
return
end

close,/all
files=file_search('/data/pth/DARKCURRENTREDUCED/SELECTED_4d/24*.fits*',count=n)
openw,44,'troughs.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),header)
if_rotated,header,iflag
if (iflag ne 1) then begin
print,files(i)
getcoordsfromheader,header,x0,y0,radius
if (x0-radius le 10 or x0+radius gt 511 or y0-radius lt 0 or y0+radius ge 511) then goto,jump
line1=avg(im(0:40,*),0)
print,x0,y0,radius,y0-radius,y0+radius
xx=findgen(512)
idx=where(xx lt y0(0)-radius(0)-1 or xx gt y0(0)+radius(0)+1)
xx=xx(idx)
yy=[line1(idx)]
res=robust_linefit(xx,yy)
yhat=res(0)+res(1)*findgen(512)
printf,format='(f9.4,1x,g12.5,a,a)',44,mean(line1(y0-radius:y0+radius))-mean(yhat(y0-radius:y0+radius)),max(im),' ',files(i)
jump:
endif
endfor
close,44
end
