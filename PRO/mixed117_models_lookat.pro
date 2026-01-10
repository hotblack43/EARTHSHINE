PRO getfiltertypefromJD,JD_in,filtertype
common switches,iflag,data,jd,ty
if (iflag ne 314) then begin
data=get_data('JD_FILTERTYPE.txt')
jd=reform(data(0,*))
ty=reform(data(1,*))
iflag=314
endif
idx=where(jd eq jd_in)
if (idx(0) eq -1) then stop
filtertype=ty(idx(0))
return
end

PRO MOONPHASE,jd,az_moon,phase_angle_E,alt_moon,alt_sun,obsname
 ;-----------------------------------------------------------------------
 ; Set various constants.
 ;-----------------------------------------------------------------------
 RADEG  = 180.0/!PI
 DRADEG = 180.0D/!DPI
 AU = 149.597871d+6       ; mean Sun-Earth distance     [km]
 Rearth = 6365.0D    ; Earth radius                [km]
 Rmoon = 1737.4D     ; Moon radius                 [km]
 Dse = AU            ; default Sun-Earth distance  [km]
 Dem = 384400.0D     ; default Earth-Moon distance [km]
 MOONPOS, jd, ra_moon, DECmoon, dis
 distance=dis/Rearth
 eq2hor, ra_moon, DECmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
 SUNPOS, jd, ra_sun, DECsun
 eq2hor, ra_sun, DECsun, jd, alt_sun, az, ha, OBSNAME=obsname
 RAdiff = ra_moon - ra_sun
 sign = +1
 if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
 phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
 phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
 return
 end
 
 PRO extractmags,JD,DSmag,TOTmag,im
 ; find the lonlat file
 ideal=reform(im(*,*,0))
 lon=reform(im(*,*,1))
 lat=reform(im(*,*,2))
; Crisium
 w=3
 lon0=59
 lat0=17.5
 idx=where(lon gt lon0-w and lon lt lon0+w and lat gt lat0-w and lat lt lat0+w)
 Nidx=n_elements(idx)
 jdx=where(im gt 1)	; NOTE: this slects for BS pixels only
 Njdx=n_elements(jdx)
 imshow=ideal
 imshow(idx)=max(ideal)
;tvscl,imshow
;Grimaldi
 w_lon=1
 w_lat=10
 lon0=-68
 lat0=-5
 kdx=where(lon gt lon0-w_lon and lon lt lon0+w_lon and lat gt lat0-w_lat and lat lt lat0+w_lat)
 Nkdx=n_elements(idx)
 imshow=ideal
 imshow(kdx)=max(ideal)
;tvscl,imshow
;
 DS1=total(im(idx),/double)
 DS2=total(im(kdx),/double)
 DS1mag=-2.5*alog10(DS1)+5.*alog10(6.67)+2.5*alog10(Nidx)
 DS2mag=-2.5*alog10(DS2)+5.*alog10(6.67)+2.5*alog10(Nkdx)
 DSmag=max([DS1mag,DS2mag])
 TOTmag=-2.5*alog10(total(im(jdx),/double,/NaN))+5.*alog10(6.67)+2.5*alog10(Njdx)
 end
 PRO get_JULIAN_And_ALBEDO,h,JD,albedo
 ;JULIAN  = '2456104.8794353'    /Julian day                                      
 ;ALBEDO  = ' 0.38594'           /Earth model albedo 
 idx=where(strpos(h,'JULIAN') ne -1)
 JDstr=h(idx(0))
 idx=where(strpos(h,'ALBEDO') ne -1)
 ALBEDOstr=h(idx(0))
 albedo=double(strmid(ALBEDOstr,11,8))
 jd=double(strmid(JDstr,11,15))
 return
 end
 
common switches,iflag,datafortypes,jdfortypes,types
iflag=1
filternames=['B','V','VE1','VE2','IRCUT']
 for wantedfilter=1,5,1 do begin
 files=file_search('ideal_lon_lat_2*.fits',count=n)
 openw,1,'plotme.dat'
 for i=0,n-1,1 do begin
     im=readfits(files(i),h,/silent)
     get_JULIAN_And_ALBEDO,h,JD,albedo
     getfiltertypefromJD,JD,filtertype
     if (filtertype eq wantedfilter) then begin
     MOONPHASE,jd,az_moon,phase_angle_E,alt_moon,alt_sun,obsname
     extractmags,JD,DSmag,TOTmag,im
     print,format='(f15.7,1x,f9.4,1x,f9.5,3(1x,f9.4))',jd,phase_angle_E,albedo,DSmag,TOTmag,DSmag-TOTmag
     printf,1,format='(f15.7,1x,f9.4,1x,f9.5,2(1x,f9.4))',jd,phase_angle_E,albedo,DSmag,TOTmag
     endif
     endfor
 close,1
 data=get_data('plotme.dat')
 jd=reform(data(0,*))
 ph=reform(data(1,*))
 albedo=reform(data(2,*))
 DSmag=reform(data(3,*))
 TOTmag=reform(data(4,*))
 !P.CHARSIZE=1.2
 !P.CHARTHICK=2
 !P.THICK=3
 !x.THICK=2
 !y.THICK=2
 !P.MULTI=[0,1,2]
 symtouse=1
 tstr=filternames(wantedfilter-1)+' Fitted model data: new H-63. Clem NOT scaled to Wildey'
 plot,xstyle=3,title=tstr,abs(ph),albedo,psym=symtouse,xtitle='Earth phase angle',ytitle='Model albedo',xrange=[0,180]
 ldx=where(ph lt 0)
 oplot,abs(ph(ldx)),albedo(ldx),psym=symtouse,color=fsc_color('red')
 plot,xstyle=3,yrange=[6,12],ystyle=3,abs(ph),DSmag-TOTmag,psym=symtouse,xtitle='Earth phase angle',ytitle='DSmag - TOTmag [mag/arcsec!u2!n]',xrange=[0,180]
 oplot,abs(ph(ldx)),DSmag(ldx)-TOTmag(ldx),psym=symtouse,color=fsc_color('red')
 ; printstats
 print,'Min Max albedo: ',min(albedo),max(albedo)
 mdx=where(finite(DSmag-TOTmag) eq 1)
 print,'Min max DS - TOT: ',min(DSmag(mdx)-TOTmag(mdx)),max(DSmag(mdx)-TOTmag(mdx))
 endfor	; end of filter loop
 end
 
