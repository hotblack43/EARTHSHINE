PRO gooverplot,a,binsize,xra
 pcol=!P.color
 !P.color=fsc_color('red')
 histo,a,min(xra),max(xra),binsize,/overplot,/abs
 oplot,[median(a),median(a)],[!Y.crange],linestyle=2
 sd=robust_sigma(a)/sqrt(n_elements(a)-1)
 oplot,[median(a)-sd,median(a)-sd],[!Y.crange],linestyle=1
 oplot,[median(a)+sd,median(a)+sd],[!Y.crange],linestyle=1
 !P.color=pcol
print,' press a key ...'
klo=get_kbrd()
 return
 end
 
 PRO gomakehisto,a,xtitstr,binw,xra
 histo,xtitle=xtitstr,a,min(a),max(a),binw,/abs
xra=!X.crange
 oplot,[median(a),median(a)],[!Y.crange],linestyle=2
 sd=robust_sigma(a)/sqrt(n_elements(a)-1)
 oplot,[median(a)-sd,median(a)-sd],[!Y.crange],linestyle=1
 oplot,[median(a)+sd,median(a)+sd],[!Y.crange],linestyle=1
 x0=min(!X.crange)+0.15*(max(!x.crange)-min(!x.crange));median(a)-2.*robust_sigma(a)
 y0=!y.crange(0)+0.88*(!Y.crange(1)-!Y.crange(0))
 offset=0.13*(max(!Y.crange)-min(!Y.crange))
 xyouts,/data,x0,y0,'Median: '+string(median(a),format='(f8.5)')
 xyouts,/data,x0,y0-offset,'SD!dm!n: '+string(sd(a),format='(f8.4)')
 return
 end
 PRO godostats,true_x,x,true_y,y,xstr,ystr,effectofbias
 print,'---------------------------------------------------'
 R=correlate(x,y)
 plot,xstyle=3,ystyle=3,y,x,ytitle=xstr,xtitle=ystr,$
 psym=1,charsize=1.7,thick=3
 res=robust_linefit(y,x)
 yhat=res(0)+res(1)*y
 oplot,y,yhat,color=fsc_color('red')
 xyouts,/data,median(y)-2.*robust_sigma(y),median(x)+1.5*robust_sigma(x),'Slope: '+string(res(1),format='(f6.3)')
;oplot,[0,0],[!Y.crange],linestyle=0
 oplot,[median(y),median(y)],[!Y.crange],linestyle=1
 oplot,[median(y),median(y)],[!Y.crange],linestyle=2
 oplot,[!X.crange],[median(x),median(x)],linestyle=1
 oplot,[!X.crange],[median(x),median(x)],linestyle=2
 print,xstr+' and '+ystr+' are correlated, R: ',R
 res=robust_linefit(x,y)
 print,'Unit change in '+ystr+' induces ',res(1),' bias in '+xstr
 bias=robust_sigma(y)
 ;bias=true_y-median(y)
 print,'SD of '+ystr+' : ',bias
 effectofbias=res(1)*bias
 print,'Effect of this error in '+ystr+' on '+xstr+' is: ',effectofbias
print,' press a key ...'
klo=get_kbrd()
 return
 end
 
 PRO MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname
 ;-----------------------------------------------------------------------
 ; Set various constants.
 ;-----------------------------------------------------------------------
 RADEG  = 180.0/!PI
 DRADEG = 180.0D/!DPI
 AU = 149.6d+6       ; median Sun-Earth distance     [km]
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
 
 PRO getalldata,file,JD,A,dA,alfa,bpwr,ped,dx,dy,ac,rmse,phasarr
 spawn,"awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$11}' "+file+"  > hejsa"
 data=get_data('hejsa')
 JD=reform(data(0,*))
 A=reform(data(1,*))
 dA=reform(data(2,*))
 alfa=reform(data(3,*))
 bpwr=reform(data(4,*))
 ped=reform(data(5,*))
 dx=reform(data(6,*))
 dy=reform(data(7,*))
 ac=reform(data(8,*))
 rmse=reform(data(9,*))
 phasarr=[]
 for k=0,n_elements(jd)-1,1 do begin
     getphasefromJD,JD(k),phase
     phasarr=[phasarr,phase]
     ;print,jd(k),phase
     endfor
 print,'N: ',n_elements(alfa)
 return
 end
 
 !P.charsize=1.7
 file='CLEM.bootstrapperfitting.txt'
 getalldata,file,JD,A,dA,alfa,bpwr,ped,dx,dy,ac,rmse,phasarr
 file='CLEM.bootstrapperfitting_alsobpwrandac.txt'
 getalldata,file,JD2,A2,dA2,alfa2,bpwr2,ped2,dx2,dy2,ac2,rmse2,phasarr2
 !P.MULTI=[0,1,4]
 ;------------
 godostats,0.31,a,1.72,alfa,'Albedo','Alfa',bias_alfa
 godostats,0.31,a,0,ped,'Albedo','pedestal',bias_ped
 godostats,0.31,a,0,dx,'Albedo','dx',bias_dx
 godostats,0.31,a,0,dy,'Albedo','dy',bias_dy
 print,'---------------------------------------------------'
 ;-------------------------
 !P.MULTI=[0,1,2]
 !P.thick=3
 !P.charsize=1.7
 !P.charthick=2
 gomakehisto,ped,'Pedestal',0.000031,xra
 gooverplot,ped2,0.000031,xra
 gomakehisto,dy,'dy',0.15,xra
 gooverplot,dy2,0.15,xra
 gomakehisto,dx,'dx',0.15,xra
 gooverplot,dx2,0.15,xra
 gomakehisto,rmse,'RMSE',0.007,xra
 gooverplot,rmse2,0.007,xra
 gomakehisto,alfa,'Alfa',0.0018,xra
 gooverplot,alfa2,0.0018,xra
 gomakehisto,a,'Albedo',0.0009,xra
 gooverplot,a2,0.0009,xra
 gomakehisto,da,'d Albedo',0.00006,xra
 gooverplot,da2,0.00006,xra
 ;--------------------------
 end
