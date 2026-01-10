PRO findoutliers,jd,DCR,header,im,maxdev
         get_info_from_header,header,'DISCX0',x0
         get_info_from_header,header,'DISCY0',y0
         get_info_from_header,header,'RADIUS',radius
im=im-median(im)-2
;
r=fltarr(512,512)
!P.MULTI=[0,2,2]
for i=0,512-1,1 do begin
di2=(i-x0)^2
for j=0,512-1,1 do begin
r(i,j)=sqrt(di2+(j-y0)^2)
if (r(i,j) le radius and median(im(i,j,*)) le 40) then begin
residuals=(im(i,j,*)-median(im(i,j,*)))/robust_sigma(im(i,j,*))
res=robust_linefit(findgen(512),residuals)
yhat=res(0)+res(1)*findgen(512)
residuals=residuals-yhat
if (max(abs(residuals)) gt maxdev) then begin
printf,45,format='(f15.7,1x,f9.4,2(1x,i3))',jd,max(abs(residuals)),i,j
print,format='(f15.7,1x,f9.4,2(1x,i3))',jd,max(abs(residuals)),i,j
plot,residuals,xstyle=3
endif
endif
endfor
endfor
end


close,/all
openr,1,'nicelist.txt'
openw,45,'flashes.txt'
while not eof(1) do begin
jd=''
readf,1,jd
print,jd
name1='/media/thejll/OLDHD/ASTRO/EARTHSHINE/data/pth/DARKCURRENTREDUCED/SELECTED_10/*'+jd+'*.fits'
DCR=readfits(find_file(name1),header)
im=readfits('/media/thejll/OLDHD/MOONDROPBOX/JD2456091/'+jd+'*.fits.gz')
findoutliers,jd,DCR,header,im,7
endwhile
close,1
close,45
end
