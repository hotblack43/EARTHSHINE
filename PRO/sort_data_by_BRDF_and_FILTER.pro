FUNCTION correctedflux,flux,an,k
 m=-2.5*alog10(flux)
 mcorr=m-k*am
 value=10^(mcorr/(-2.5))
 return,value
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
         xyouts,-0.8,(!Y.crange(1)-!Y.crange(0))*0.8+!Y.crange(0),'\phi!dmed!n='+string(median(diff),format='(f7.4)'),charsize=1.3
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
 !P.charthick=3
 filternames=['B','IRCUT','V','VE1','VE2']
 coln=['blue','orange','green','yellow','red']
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
 airm=[]
 phase=[]
 for k=0,n_elements(jd)-1,1 do begin
     get_mlo_airmass,jd(k),am
     getphasefromJD,JD(k),ph
     airm=[airm,am]
     phase=[phase,ph]
     endfor
 albedo=reform(data(1,*))
 erralbedo=reform(data(2,*))
 alfa=reform(data(3,*))
 bpwr=reform(data(4,*))
 pedestal=reform(data(5,*))
 totcounts=reform(data(11,*))
 flux=reform(data(14,*))
 brdtype=reform(data(16,*))
 filter=reform(data(17,*))
 openw,77,'eureqain.csv'
 printf,77,'  A,        filter,   brdf,    phase,     airm, magnitude, jd'
 c=','
 d=''
 for mnop=0,n_elements(filter)-1,1 do printf,77,format='(6(f11.5,a),f15.7,a)',albedo(mnop),c,filter(mnop),c,brdtype(mnop),c,phase(mnop),c,airm(mnop),c,-2.5*alog10(flux(mnop)),c,jd(mnop),d
 close,77
 ;
 !P.MULTI=[0,2,3]
 !P.THICK=4
 !P.charsize=1.9
 !P.charthick=3
 for ifilter=0,4,1 do begin
	idx=where(filter eq ifilter)
	plot,xrange=[90,180],xtitle='|!7p!3|',ytitle='LEA',title=filternames(ifilter),ystyle=3,yrange=[0,max(albedo(idx))],abs(phase(idx)),albedo(idx),psym=3
	for itype=0,5,1 do begin
	idx=where(filter eq ifilter and brdtype eq itype)
	oplot,abs(phase(idx)),albedo(idx),psym=itype+1
	endfor
;a=get_kbrd()
 endfor
end
