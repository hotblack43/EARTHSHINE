FUNCTION getbrightness,im,idx
 value=mean(im(idx))
 return,value
 end
 
 PRO getpatchcoords,n,lon0a,lat0a,lon0b,lat0b
 factor=0.90	; special factor to 'shrink' the longitudes 
	        ; for the patches - i.e. yo draw the patches 
                ; away from the edge of the lunar disk

 data=get_data('patch_pairs.dat')
 lat0a=reform(data(0,*))
 lon0a=reform(data(1,*))*factor
 lat0b=reform(data(2,*))
 lon0b=reform(data(3,*))*factor
 n=n_elements(lon0b)
 return
 end
 
 PRO get_JD_from_filename,name,JD
 idx=strpos(name,'24')
 JD=double(strmid(name,idx(0),15))
 return
 end
 
 
 
 PRO getpatchidx,lat0,lon0,w_lat,w_lon,lon,lat,idx
 idx=where(lon ge lon0-w_lon and lon le lon0+w_lon and lat gt lat0-w_lat and lat le lat0 + w_lat)
 
 return
 end
 
 PRO MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname
 ;-----------------------------------------------------------------------
 ; Set various constants.
 ;-----------------------------------------------------------------------
 RADEG  = 180.0/!PI
 DRADEG = 180.0D/!DPI
 AU = 149.6d+6       ; mean Sun-Earth distance     [km]
 Rearth = 6365.0D    ; Earth radius                [km]
 Rmoon = 1737.4D     ; Moon radius                 [km]
 Dse = AU            ; default Sun-Earth distance  [km]
 Dem = 384400.0D     ; default Earth-Moon distance [km]
 MOONPOS, jd, ra_moon, DECmoon, dis
 distance=dis/6371.
 eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME='mlo';obsname
 SUNPOS, jd, ra_sun, DECsun
 eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
 RAdiff = ra_moon - ra_sun
 sign = +1
 if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
 phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
 phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
 return
 end
 
 
 PRO getphasefromJD,JD,phase
 MOONPHASE,jd(0),phase_angle_M,alt_moon,alt_sun,obsname
 phase=phase_angle_M
 return
 end
 ;=============================================================
 ; Code to extract fiducial patch brightness values
 close,/all
 openw,77,'dsbsratio.dat'
 getpatchcoords,npatches,lon0a,lat0a,lon0b,lat0b
 files=file_search('/data/pth/UNIVERSALSETOFMODELS/newH-63_HIRESscaled_LA/convolved_albedo0p31/BBSO_CLEANED_IMAGES/*.fits',count=n)
 for i=0,n-1,1 do begin
     im=readfits(files(i),/sil)
     if ((size(im))(0) eq 3) then begin
         get_JD_from_filename,files(i),JD
         getphasefromJD,JD,phase
         halo=reform(im(*,*,0))
         model=reform(im(*,*,1))
         lon=reform(im(*,*,2))
         lat=reform(im(*,*,3))
         bbsocleaned=reform(im(*,*,4))
         a_patch=fltarr(3,npatches)
         b_patch=fltarr(3,npatches)
         for ipatch=0,npatches-1,1 do begin
             for imtype=0,2,1 do begin
                 getpatchidx,lat0a(ipatch),lon0a(ipatch),4,10,lon,lat,idx
                 getpatchidx,lat0b(ipatch),lon0b(ipatch),4,10,lon,lat,jdx
                 if (imtype eq 0) then begin
                     a_patch(imtype,ipatch)=getbrightness(halo,idx)
                     b_patch(imtype,ipatch)=getbrightness(halo,jdx)
                     endif
                 if (imtype eq 1) then begin
                     a_patch(imtype,ipatch)=getbrightness(model,idx)
                     b_patch(imtype,ipatch)=getbrightness(model,jdx)
                     endif
                 if (imtype eq 2) then begin
                     a_patch(imtype,ipatch)=getbrightness(bbsocleaned,idx)
                     b_patch(imtype,ipatch)=getbrightness(bbsocleaned,jdx)
                     endif
                 endfor	; imtype loop
             endfor	; ipatch loop
         print,'-----------------------------------------------'
         ; print the patch-mean ratio for the three image types
         if (mean(avg(a_patch/b_patch,1)) lt 1) then begin
                 print,format='(f15.7,1x,f9.4,6(1x,g10.5))',jd,phase,avg(a_patch/b_patch,1),avg(a_patch(2,*)/b_patch(2,*),1)/avg(a_patch(1,*)/b_patch(1,*),1),avg(a_patch(0,*)/b_patch(0,*),1)/avg(a_patch(1,*)/b_patch(1,*),1)
             printf,77,format='(f15.7,1x,f9.4,6(1x,g10.5))',jd,phase,avg(a_patch/b_patch,1),avg(a_patch(2,*)/b_patch(2,*),1)/avg(a_patch(1,*)/b_patch(1,*),1),avg(a_patch(0,*)/b_patch(0,*),1)/avg(a_patch(1,*)/b_patch(1,*),1)
             endif else begin
                 print,format='(f15.7,1x,f9.4,6(1x,g10.5))',jd,phase,avg(b_patch/a_patch,1),avg(b_patch(2,*)/a_patch(2,*),1)/avg(b_patch(1,*)/a_patch(1,*),1),avg(b_patch(0,*)/a_patch(0,*),1)/avg(b_patch(1,*)/a_patch(1,*),1)
             printf,77,format='(f15.7,1x,f9.4,6(1x,g10.5))',jd,phase,avg(b_patch/a_patch,1),avg(b_patch(2,*)/a_patch(2,*),1)/avg(b_patch(1,*)/a_patch(1,*),1),avg(b_patch(0,*)/a_patch(0,*),1)/avg(b_patch(1,*)/a_patch(1,*),1)
             
             endelse
         endif
     endfor
 close,77
 end
