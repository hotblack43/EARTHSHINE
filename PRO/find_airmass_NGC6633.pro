PRO goshowmovie,im
l=size(im)
if (l(0) ne 2) then begin
nims=l(3)
for l=0,10,1 do begin
for k=0,nims-1,1 do tvscl,hist_equal(im(*,*,k))
endfor
endif
return
end
PRO get_JD_from_filename,name,JD
liste=strsplit(name,'/',/extract)
idx=strpos(liste,'24')
ipoint=where(idx ne -1)
JD=double(liste(ipoint))
return
end

 PRO get_everything_fromJD,JD,am
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the airm
 RANGC6633=276.6746013236485	; in degrees
 DECNGC6633=6.4771424218804725	; in degrees
 am = airmass(JD, RANGC6633*!dtor, DECNGC6633*!dtor, lat*!dtor, lon*!dtor)
 return
 end

PRO getfiltername,filename,filtername
;/media/SAMSUNG/CLEANEDUP2455945/2455945.0716098MOON_VE2_AIR_DCR.fits
bit1=strmid(filename,strpos(filename,'_')+1,strlen(filename))
filtername=strmid(bit1,0,strpos(bit1,'_'))
return
end

files=file_search('/media/thejll/OLDHD/MOONDROPBOX/NGC6633/*6633*',count=n)
for ifile=0,n-1,1 do begin
im=readfits(files(ifile),header,/silent)
get_JD_from_filename,files(ifile),JD
get_everything_fromJD,JD,am
get_EXPOSURE,header,exposuretime
getfiltername,files(ifile),filtername
if (max(im) lt 50000. and max(im) gt 10000. and min(im) gt 200) then begin
print,format='(2(1x,g10.4),1x,f9.4,1x,a10,1x,f15.7,1x,f9.3)',min(im),max(im),exposuretime,filtername,JD,am
;histo,im,350,450,1
;oplot,[median(im),median(im)],[!Y.crange],linestyle=1
;goshowmovie,im
;
l=size(im)
if (l(0) ne 2) then im=avg(im,2,/double)
tvscl,hist_equal(im)
endif
endfor
end
