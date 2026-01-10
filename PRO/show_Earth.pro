PRO gogettheMLOphotocentredistance,im,ph_dist
; calculates distance froms pecially marked pixel and the gravity centre of the rest of the image
tvscl,im
; find MLO
idx=where(im eq max(im))
co=array_indices(im,idx)
MLOmean=mean(im(idx))
print,'mean MLO pixel brightness:',MLOmean
x0=mean(co(0))
y0=mean(co(1))
print,'MLO coords in image: ',mean(co(0)),mean(co(1))
jdx=where(im lt 0.7*MLOmean and im gt 0)
openw,66,'photoctr.dat'
for i=0,n_elements(jdx)-1,1 do begin
coo=array_indices(im,jdx(i))
x=coo(0)
y=coo(1)
dist=sqrt((x-x0)^2+(y-y0)^2)
print,dist,im(x,y),dist*im(x,y)
printf,66,dist,im(x,y),dist*im(x,y)
;im(x,y)=max(im)
;tvscl,im
endfor
close,66
data=get_data('photoctr.dat')
d=reform(data(0,*))
bri=reform(data(1,*))
histo,d,0,700,10,title='Distance in pixels from MLO'
wm=total(d*bri)/total(bri)
ph_dist=wm;median(d)
return
end

PRO     gomarkMLO,image,lon,lat,image_special
observatory,'mlo',obs
lon0=360.0-obs.longitude
lat0=obs.latitude
print,'MLO lon,lat: ',lon0,lat0
w=1
idx=where(lon gt lon0-w and lon lt lon0+w)
jdx=where(lat gt lat0-w and lat lt lat0+w)
print,'Image max: ',max(image)
image_special=image
image_special(idx,jdx)=2
return
end

PRO godospecial2,JD,latSAL,lonSAL,image,meanalbedo,npixels
 ; what is the cos(lat) weighted average of image when only non-zero pixels are averaged?
         MOONPOS, JD, ra_moon, dec_moon
;
 kdx=where(image ne 0)
 npixels=n_elements(kdx)
 nlon=n_elements(lonSAL)
 nlat=n_elements(latSAL)
 weights=image*0.0
 for ilon=0,nlon-1,1 do begin
         longitude=lonSAL(ilon)
     for ilat=0,nlat-1,1 do begin
	 latitude=latSAL(ilat)
         eq2hor, ra_moon, dec_moon, JD, alt_moon, az, ha, lat=latitude, lon=longitude
         weights(ilon,ilat)=cos(latSAL(ilat)*!dtor)*abs(sin(alt_moon*!dtor))
         endfor
     endfor
 weights=weights/mean(weights)
 meanalbedo=mean(image(kdx)*weights(kdx))
 print,'mean of sin(alt_moon)- and cos(lat)-weighted (lit parts only!) image: ',meanalbedo
 return
 end
 
 PRO godospecial1,latSAL,lonSAL,image
 ; what is the cos(lat) weighted average of image?
 nlon=n_elements(lonSAL)
 nlat=n_elements(latSAL)
 weights=image*0.0
 for ilon=0,nlon-1,1 do begin
     for ilat=0,nlat-1,1 do begin
         weights(ilon,ilat)=cos(latSAL(ilat)*!dtor)
         endfor
     endfor
 weights=weights/mean(weights)
 print,'mean of weighted image: ',mean(image*weights)
 return
 end
 
 PRO blankoutbitsoftheimage,image,now,lon,lat
 ; blank out thebits of the image that are not sunlit and are not vissible from the Moon
 for ilon=0,n_elements(lon)-1,1 do begin
     for ilat=0,n_elements(lat)-1,1 do begin
         longitude=lon(ilon)
         latitude=lat(ilat)
         SUNPOS, now, ra_sun, dec_sun
         eq2hor, ra_sun, dec_sun, now, alt_sun, az, ha, lat=latitude, lon=longitude
         if (alt_sun lt 0.0) then image(ilon,ilat)=0.0
         MOONPOS, now, ra_moon, dec_moon
         eq2hor, ra_moon, dec_moon, now, alt_moon, az, ha, lat=latitude, lon=longitude
         if (alt_moon lt 0.0) then image(ilon,ilat)=0.0
         endfor
     endfor
 return
 end
 
 PRO add_continents_etc,lon,lat,image,lonSAL,latSAL
 ; image is the cloudimage - in percent 0-100
 writefits,'image_input.fits',image
 ; get the surface albedo map
 sal=readfits('MERIS_SAL.fits')
 alfa_cloud=0.5
 albedo_scaling=0.20
 ;.....................................
 ; fix geometry and size
 sal=CONGRID(sal, 192, 92, /INTERP)
 sal=reverse(sal,2)
 sal=shift(sal,96,0)
 ;.....................................
 ; get some useful pixels for later
 ; identify ocean pixels
 idx=where(sal lt 20)
 ; identify ice pixels
 jdx=where(sal gt 240)
 ; identify land pixels
 ldx=where(sal ge 10)
 ;.....................................
 ; scale
 sal=sal/255.*albedo_scaling
 ; set ocean albedo
 sal(idx)=0.05
 ;set ice albedo
 sal(jdx)=0.7
 ; set landpixels
 ; sal(ldx)=0.0;0.1
 ;
 writefits,'SALedited.fits',sal
 lonSAL=findgen(192)/192.*360.
 latSAL=findgen(92)/91.*(2.*86.6531)-86.6531
 ; now add a tcdc-weighted surface albedo to theimage
 surfaceimage=(1.-image/100.)*sal
 cloudimage=image/100.*alfa_cloud
 writefits,'surfaceimage.fits',surfaceimage
 writefits,'cloudimage.fits',cloudimage
 image=surfaceimage+cloudimage
 ; add poor-mans Rayleigh scattering
 extinction=0.15	; as for V band?
 image=(1.-extinction)*image+extinction/2.
; and fill in those pescy gaps with 0's - set to minimum of rest
kdx=where(image ne 0)
mdx=where(image eq 0)
if n_elements(mdx) ne 0 then begin
image(mdx)=min(image(kdx))
print,'Filled 0s up with: ',min(image(kdx))
endif
 writefits,'SAL_clouds_Rayleigh.fits',image
 ; that is - pretend a fraction of the light is lost due to extinction
 ; and that half of that comes back as Rayleigh scattered light
 godospecial1,latSAL,lonSAL,image
 return
 end
 
 PRO getthedata,jd,lon,lat,tcdc
 common flags,iflag
 path='/data/pth/NETCDF/'
 path='/media/thejll/OLDHD/'
 if (iflag ne 314) then begin
     file=path+'X2.105.173.146.258.9.8.4.nc'
     id = NCDF_OPEN(file)
     NCDF_VARGET, id, 'lon',    lon
     NCDF_VARGET, id, 'lat',    lat
     NCDF_VARGET, id, 'time',   time
     NCDF_VARGET, id, 'tcdc',   tcdc
     NCDF_CLOSE,  id
     jd=julday(1,1,1,0,0,0)+time/24.
     file=path+'X2.105.173.146.258.9.9.36.nc'
     id = NCDF_OPEN(file)
     NCDF_VARGET, id, 'lon',    lon2
     NCDF_VARGET, id, 'lat',    lat2
     NCDF_VARGET, id, 'time',   time2
     NCDF_VARGET, id, 'tcdc',   tcdc2
     NCDF_CLOSE,  id
     jd2=julday(1,1,1,0,0,0)+time2/24.
     file=path+'X2.105.173.146.258.9.9.0.nc'
     id = NCDF_OPEN(file)
     NCDF_VARGET, id, 'lon',    lon3
     NCDF_VARGET, id, 'lat',    lat3
     NCDF_VARGET, id, 'time',   time3
     NCDF_VARGET, id, 'tcdc',   tcdc3
     NCDF_CLOSE,  id
     jd3=julday(1,1,1,0,0,0)+time3/24.
     jd=[jd,jd3,jd2]
     tcdc=[[[tcdc]],[[tcdc3]],[[tcdc2]]]
     idx=where(tcdc eq 32766)
     tcdc=tcdc*0.1+3276.5
     iflag=314
     endif
 return
 end
 
 
 PRO getNCEPcloudimage,now,jd,lon,lat,tcdc,image
 delta=abs(jd-now)
 idx=where(delta eq min(delta))
 image=reform(tcdc(*,*,idx))
 return
 end
 
 
 ;----------------------------------------------------------
 ; Generates a simulated image of Earth as seen from the
 ; Moon, for any time 2010-2012
 ; Uses clouds from NCEP and otherwise a static land-sea albedo map
 ;-------------------------------------------------------------
 common flags,iflag
 iflag=1
 if_show_continents=0	; 1 if show land outlines, 0 if not
 special_mark_MLO=1	; whther to mark MLO with coded pixels, or not
 ; get the data from nc files
 getthedata,jd,lon,lat,tcdc
 observatory_names=['mlo']
 loadct,0
 device='ps'
 device='X'
 if (device eq 'X') then device,decomposed=0
 get_lun,hqx
 openr,hqx,'allJDstorunshow_Earth_on.txt'
 now=0.0d0
 openw,83,'meanalbedos.dat'
 while not eof(hqx) do begin
     print,'-------------------------------------------'
     readf,hqx,now
     caldat,now,mm,dd,yy,hour,min,sec
     obsname=observatory_names(0)
         MOONPOS, now, ra_moon, dec_moon
         eq2hor, ra_moon, dec_moon, now, alt_moon, az, ha, obsname=obsname
	if (alt_moon gt 0) then begin
     get_lun,iia
     openw,iia,strcompress('scenario_dat.'+obsname,/remove_all)
     dat_str=strcompress(string(mm)+'/'+string(dd)+'/'+string(yy)+' at '+string(hour)+':'+string(min)+':'+string(fix(sec)))
     tit_str=strcompress(dat_str+' Obs = '+obsname+' as seen from Moon')
     get_lun,iba
     openw,iba,strcompress('titelstring.'+obsname,/remove_all)
     printf,iba,tit_str
     close,iba & free_lun,iba
     doy=fix(julday(mm,dd,yy)-julday(12,31,yy-1))
     time=hour+min/60.d0+sec/3600.d0
     ; First see if Moon is vissible from the chosen observatory at the given time
     ; and whether the Sun has set
     MOONPOS, now, ra_moon, dec_moon, dis
     distance=dis/6371.
     eq2hor, ra_moon, dec_moon, now, alt_moon_obs, az_moon, ha_moon,  OBSNAME=obsname
     SUNPOS, now, ra_sun, dec_sun
     eq2hor, ra_sun, dec_sun, now, alt_sun, az, ha, OBSNAME=obsname
     ; see the earth from the Moon
     ;         finding_longlat_moon_at_zenith,mm,dd,yy,hour,min,sec,longitude,latitude
     getmoonslonltatzenith,now,longitude,latitude
     map_set,latitude,longitude,0,/satellite,sat_p=[distance,0,0],title=tit_str,/isotropic
     getNCEPcloudimage,now,jd,lon,lat,tcdc,image
     add_continents_etc,lon,lat,image,lonSAL,latSAL
     blankoutbitsoftheimage,image,now,lon,lat
     kdx=where(image ne 0)
     godospecial2,now,latSAL,lonSAL,image,meanalbedo,npixels
     writefits,'blankedoutimage.fits',image
     if (special_mark_MLO eq 1) then gomarkMLO,image,lon,lat,image_special
     contour,image,lon,lat,/overplot,/cell_fill,nlevels=101
     if (if_show_continents eq 1) then map_continents,/overplot,title=title,color=235,mlinethick=2
     im=tvrd()
     write_jpeg,strcompress('EARTHVIEWS/Moonview_'+string(now,format='(f15.7)')+'_'+obsname+'.jpg',/remove_all),im
; ------------------
; get the special image for measuring MLO-photocentre distance
map_set,latitude,longitude,0,/satellite,sat_p=[distance,0,0],/isotropic,/noborder
contour,image_special,lon,lat,/overplot,/cell_fill,nlevels=101
im_special=tvrd()
gogettheMLOphotocentredistance,im_special,ph_dist
     ;----------------------
; once more - without border or titles
     map_set,latitude,longitude,0,/satellite,sat_p=[distance,0,0],/noborder,/isotropic
     contour,image,lon,lat,/overplot,/cell_fill,nlevels=101
     im=tvrd()
     close,iia & free_lun,iia
	printf,83,format='(f15.7,1x,f6.4,1x,i5,1x,f5.1)',now,meanalbedo,npixels,ph_dist
	print,format='(f15.7,1x,f6.4,1x,i5,1x,f5.1)',now,meanalbedo,npixels,ph_dist
	endif
     endwhile
 print,'-------------------------------------------'
 close,hqx
 free_lun,hqx
 close,83
 end
 
