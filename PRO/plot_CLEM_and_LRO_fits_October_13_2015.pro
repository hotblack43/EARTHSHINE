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
PRO         findBRDFoffset,table
 types=['H-X_HIRESscaled', 'H-X_LRO', 'H-X_UVVISnoscale', 'newH-63_HIRESscaled', 'newH-63_LRO', 'newH-63_UVVISnoscale']
l=size(table,/dimensions)
for itype=0,4,1 do begin
for jtype=itype+1,5,1 do begin
x1=table(itype,*)
x2=table(jtype,*)
liste=[]
for i=0,l(1)-1,1 do begin
if (x1(i) gt 0 and x2(i) gt 0) then begin
	liste=[[liste],[x1(i),x2(i)]]
endif
endfor
diff=liste(0,*)-liste(1,*)
print,itype,jtype,median(diff),stddev(diff),correlate(liste(0,*),liste(1,*))
histo,diff,-1,1,0.02,xtitle=types(itype)+' - '+types(jtype),/abs
oplot,[0,0],[!Y.crange],linestyle=1
charsi=!P.charsize
xyouts,-0.8,(!Y.crange(1)-!Y.crange(0))*0.8+!Y.crange(0),'!7D!3!dmed!n='+string(median(diff),format='(f7.4)'),charsize=1.3
xyouts,-0.8,(!Y.crange(1)-!Y.crange(0))*0.7+!Y.crange(0),'!7r!3!dr!n='+string(robust_sigma(diff),format='(f7.4)'),charsize=1.3
!P.charsize=charsi
plot,/isotropic,liste(0,*),liste(1,*),psym=7,xrange=[0,1],yrange=[0,1],xstyle=3,ystyle=3,xtitle=types(itype),ytitle=types(jtype)
oplot,[0,1],[0,1],linestyle=1
endfor
endfor
return
end
PRO get_mlo_airmass,jd,am
 ;
 ; Calculates the airmass of the observed Moon as seen from MLO
 ;
 ; INPUT:
 ;   jd  -   julian day
 ; OUTPUT:
 ;   am  -   the required airmass
 ;
 lat=19.53d0
 lon=155.576
 MOONPOS,jd,ra,dec
 eq2hor,ra,dec,jd,alt,az,lon=lon,lat=lat
 ra=degrad(ra)
 dec=degrad(dec)
 lat=degrad(lat)
 lon=degrad(lon)
 am = airmass(jd,ra,dec,lat,lon)
 return
 end
 

 ;======================================================
 filternames=['B','IRCUT','V','VE1','VE2']
 coln=['red','green','blue','orange','yellow','gray']
 types=['H-X_HIRESscaled', 'H-X_LRO', 'H-X_UVVISnoscale', 'newH-63_HIRESscaled', 'newH-63_LRO', 'newH-63_UVVISnoscale']
 file='CLEM_and_LRO_fits_October_13_2015.numerical'
 data=get_data(file)
 idx=sort(data(0,*))
 data=data(*,idx)
 jd=data(0,*)
 uniqjd=jd(sort(data(0,*)))
 uniqjd=jd(uniq(uniqjd))
 nuniq=n_elements(uniqjd)
 help,data
 jd=reform(data(0,*))
 airmass=[]
 phase=[]
 for k=0,n_elements(jd)-1,1 do begin
	get_mlo_airmass,jd(k),am
        getphasefromJD,JD(k),ph
        airmass=[airmass,am]
        phase=[phase,ph]
 endfor
 albedo=reform(data(1,*))
 brdtype=reform(data(16,*))
 filter=reform(data(17,*))
 !P.CHARSIZE=2
 !P.THICK=4
 for ifilter=0,4,1 do begin
     !P.MULTI=[0,2,4]
     print,filternames(ifilter)
     table=[]
     for ijd=0,nuniq-1,1 do begin
         line=fltarr(6)
         for itype=0,5,1 do begin
             idx=where(jd eq uniqjd(ijd) and filter eq ifilter and brdtype eq itype)
             if (idx(0) ne -1) then line(itype)=mean(albedo(idx))
             if (idx(0) eq -1) then line(itype)=-999
             endfor
         table=[[table],[line]]
         endfor
         findBRDFoffset,table
     plot,table(0,*),yrange=[0,1],title='Filter '+filternames(ifilter),psym=1,xtitle='Obs #',ytitle='Albedo'
     oplot,table(1,*),color=fsc_color('red'),psym=1
     oplot,table(2,*),color=fsc_color('green'),psym=1
     oplot,table(3,*),color=fsc_color('orange'),psym=1
     oplot,table(4,*),color=fsc_color('gray'),psym=1
     endfor
 end
