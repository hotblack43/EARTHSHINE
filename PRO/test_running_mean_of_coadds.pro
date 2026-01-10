



; code to test whether RON has zero mean - i.e. whether co-adding images
; leaves the mean alone
ntries=100
file='/media/SAMSUNG/EARTHSHINE/MOONDROPBOX/JD2456015/2456015.7742682MOON_V_AIR.fits.gz'
file='/media/OLDHD/pth/SAMSUNG/MOONDROPBOX/JD2456015/2456015.7742682MOON_V_AIR.fits.gz'
org=double(readfits(file))
l=size(org,/dimensions)
n=l(2)
openw,33,'data.dat'
for i=0,n-1,1 do begin
im=reform(org(*,*,i))
if (i eq 0) then sum=im
if (i gt 0) then sum=sum+im
print,mean(sum)/float(i+1)
printf,33,mean(sum)/float(i+1)
endfor
close,33
data=get_data('data.dat')
plot,ystyle=3,(data(0,*)-1378.8)/1378.8*100.0,psym=7,xtitle='# of frames added',ytitle='Running mean [%]'
end
