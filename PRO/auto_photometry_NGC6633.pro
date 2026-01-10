PRO godophotometry,im,fname
; uses astrometry.net toi extract anulus photometry
; outputs coordinates and machine mags
writefits,'im.fits',im
; call the script
spawn,"./extract_RADEC_fromFITS.scr"
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
openw,66,'colated_NGC6633.dat'
for ifile=0,n-1,1 do begin
im=readfits(files(ifile),header,/silent)
get_JD_from_filename,files(ifile),JD
get_everything_fromJD,JD,am
get_EXPOSURE,header,exposuretime
getfiltername,files(ifile),filtername
if (max(im) lt 50000. and max(im) gt 10000. and min(im) gt 200) then begin
l=size(im)
if (l(0) ne 2) then im=avg(im,2,/double)
;tvscl,hist_equal(im)
spawn,"rm test.cat"
spawn,'rm im.* output.astrometry coords.astrometry RA.str DEC.str platescale.dat rotangle.dat'
godophotometry,im,files(ifile)
spawn,"awk 'NF ==14 ''' test.cat > table2.dat"
data=get_data('table2.dat')
limmagerr=0.01
idx=where(data(11,*) eq 0 and data(2,*) le limmagerr)
if (idx(0) eq -1) then stop
nidx=n_elements(idx)
data=data(*,idx)
mag=reform(data(1,*))+replicate(2.5*alog10(exposuretime),nidx)
magerr=reform(data(2,*))
RA=reform(data(9,*))
DEC=reform(data(10,*))
nstars=n_elements(RA)
fmt='(f15.7,5(1x,f9.4),1x,a)'
for k=0,nstars-1,1 do begin 
print,format=fmt,JD,mag(k),magerr(k),RA(k),DEC(k),am,filtername
printf,66,format=fmt,JD,mag(k),magerr(k),RA(k),DEC(k),am,filtername
endfor
endif
endfor
close,66
print,'Now run "plot_colated_ngc6633.pro"'
end
