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
 n=n_elements(jd)
 phase=[]
 for i=0,n-1,1 do begin
     MOONPHASE,jd(i),phaseval,alt_moon,alt_sun,obsname
     phase=[phase,phaseval]
     endfor
 return
 end
 
 
 PRO getalldata,fstr,filename,jd,albedo,alfa,beta,pedestal,Acoeff,rmse,zodi,SL,phase
 print,'Reading file ',filename
 str="grep "+fstr+" "+filename+" | awk '{print $1,$2,$4,$5,$6,$7}'  > extracted_data.dat"
 spawn,str
 data=get_data('extracted_data.dat')
 jd=reform(data(0,*))
 albedo=reform(data(1,*))
 alfa=reform(data(2,*))
 beta=reform(data(3,*))
 pedestal=reform(data(4,*))
 Acoeff=reform(data(5,*))
;rmse=reform(data(6,*))
;zodi=reform(data(7,*))
;SL=reform(data(8,*))
 getphasefromJD,JD,phase
 return
 end
 
 
 
 !P.MULTI=[0,2,3]
 !P.charsize=2
 !P.thick=3
 !P.charthick=2
 !X.style=3
 !y.style=3
 filename1='CLEM.halotrials_May_23_2016.txt' 
 spawn,"wc "+filename1
;filename2='CLEM.profiles_fitted_results_July_24_2013.txt' 
;filename2="CLEM.profiles_fitted_results_July_24_2013.txt"
 filename2="CLEM.profiles_fitted_results_Oct_2013_NEW_Hapke63.txt"
 spawn,"wc "+filename2
 filternames=['B','V','VE1','VE2','IRCUT']
 for ifilter=0,4,1 do begin
     fstr='_'+filternames(ifilter)+'_'
     getalldata,fstr,filename1,jd1,albedo1,alfa1,beta1,pedestal1,Acoeff1,rmse1,zodi1,SL1,phase1
     getalldata,fstr,filename2,jd2,albedo2,alfa2,beta2,pedestal2,Acoeff2,rmse2,zodi2,SL2,phase2
     plot,xrange=[75,150],yrange=[0,max([albedo1,albedo2])],$
     title=filternames(ifilter),abs(phase1),albedo1,psym=7,/nodata,xtitle='Lunar phase [FM = 0]',ytitle='Albedo'
     oplot,phase1,albedo1,psym=7,color=fsc_color('red')
     oplot,phase2,albedo2,psym=7,color=fsc_color('green')
;---
     plot,/isotropic,alfa1,alfa2,psym=1,xtitle='!7a!3!d1!n',ytitle='!7a!3!d2!n'
     plot,/isotropic,beta1,beta2,psym=1,xtitle='!7b!3!d1!n',ytitle='!7b!3!d2!n'
     plot,pedestal1,pedestal2,psym=1,xtitle='pedestal!d1!n',ytitle='pedstal!d2!n'
     plot,Acoeff1,Acoeff2,psym=1,xtitle='Acoeff!d1!n',ytitle='Acoeff!d2!n'
     endfor
 end
