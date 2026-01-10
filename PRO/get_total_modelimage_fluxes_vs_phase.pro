PRO getjdfromname,name,jdstr
 jdstr=strmid(name,strpos(name,'245'),15)
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
 
 colornames=['red','green','blue','orange']
 ;paths=['/data/pth/IDEAL_g0p6_t0p1/',$
 ;       '/data/pth/IDEAL_g0p6_t0p2/',$
 ;       '/data/pth/IDEAL_g0p8_t0p2/',$
 ;       '/data/pth/IDEAL_g0p8_t0p1/']
  paths=['/data/pth/HAPKEX/IDEAL/',$
         '/data/pth/HAPKE63/OUTPUT/IDEAL/']
 for ipath=0,n_elements(paths)-1,1 do begin
     files=file_search(paths(ipath),'ideal_LunarImg_SCA_0p300_JD_*.fit',count=n)
     obsname='mlo'
print,'Found ',n,' ideal files'
     openw,33,'model_flux_vs_phase.dat'
     for i=0,n-1,1 do begin
         im=readfits(files(i),h,/sil)
         getjdfromname,files(i),jdstr
         jd=double(jdstr); double(strmid(h(where(strpos(h,'JULIAN') ne -1)),15,15))
         MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname
         totflux=total(im,/double)/22e-8*50000.0
         printf,33,format='(f15.7,1x,f8.2,1x,f20.3,1x,f7.3)',jd,phase_angle_M,totflux,10-2.5*alog10(totflux)
         endfor
     close,33
     data=get_data('model_flux_vs_phase.dat')
print,data
     jd=reform(data(0,*))
     ph=reform(data(1,*))
     totflux=reform(data(2,*))
     V=reform(data(3,*))
     !P.CHARSIZE=2
     !P.THICK=3
     !x.thick=2
     !y.thick=2
     if (ipath eq 0) then plot,yrange=[-4,-14],psym=7,ph,V,xtitle='Lunar Phase [FM=0]',ytitle='V',title='Synthetic Hapke63 models, Clementien albedo'
     if (ipath gt 0) then oplot,ph,V,psym=7,color=fsc_color(colornames(ipath))
     if (ipath eq 0) then begin
         ; overplot Allen
         oplot,ph,0.25+5*alog10(0.00258)+0.027*abs(ph),psym=4,color=fsc_color('red')
         V10=+0.23
         rdelta=0.0026
         phaselaw=0.026*abs(ph)+4.0e-9*ph^4
         Vallen=5.0*alog10(rdelta)+V10+phaselaw
         oplot,ph,Vallen,psym=4,color=fsc_color('orange')
         ; get JPL
         data=get_data('JPL.data')
         JPL_jd=reform(data(0,*))
         JPL_V=reform(data(1,*))
         nJPL=n_elements(JPL_V)
         phJPL=fltarr(n)
         for i=0,nJPL-1,1 do begin
             MOONPHASE,JPL_jd(i),phase_angle_M,alt_moon,alt_sun,obsname
             phJPL(i)=phase_angle_M
             endfor
         oplot,phJPL,JPL_V,psym=2,color=fsc_color('green')
         endif
     endfor
 end
