PRO getJDfromname,filename,JD,filtername
print,filename
bits=strsplit(filename,'\/',/extract)
idx=strpos(bits,'245')
ipos=where(idx eq 0)
stump=bits(ipos)
bits=strsplit(stump,'MOON',/extract)
JD=double(bits(0))
return
end

files=file_search('/data/pth/ANDOR/MOONDROPBOX/','*MOON_*.fits*',count=n)
openw,44,'azi_moon_JD.dat'
for i=0L,n-1,1 do begin
;print,files(i)
im=readfits(files(i),h,/silent)
getJDfromname,files(i),JD,filtername
SUNPOS, jd, ra, dec
eq2hor, ra, dec, jd, sun_alt, sun_az,lon=station_lon,lat=station_lat
; Moon
MOONPOS, jd, ra, dec, dis, geolong, geolat
MPHASE, jd, k
eq2hor, ra, dec, jd, moon_alt, moon_az,lon=station_lon,lat=station_lat
print,jd,moon_az,format='(f15.7,1x,f6.2)'
printf,44,jd,moon_az,format='(f15.7,1x,f6.2)'
endfor
close,44
end
