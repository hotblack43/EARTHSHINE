 PRO getpointerstotable,lonsky,latsky,ilon,ilat
 common sukminkwoon,iflagSMK,lon,lat,ZL
 dlon=lon-lonsky
 dlat=lat-latsky
 ilon=where(abs(dlon) eq min(abs(dlon)))
 ilat=where(abs(dlat) eq min(abs(dlat)))
 ilon=ilon(0)
 ilat=ilat(0)
 return
 end
 
 PRO generaterandompointsonasphere,n,lon,lat
 z=randomu(seed,n)*2-1.0
 phi=randomu(seed,n)*2.*!pi
 ;
 lon=phi/!dtor
 lat=asin(z)/!dtor
;map_set,/mollweide
;oplot,lon,lat,psym=7
 ;
 return
 end
 
 FUNCTION finddist,lon1,lat1,lon2,lat2
 ; use GCIRC to find distance
 u=0	; ie everything in radians
 ra1=lon1*!dtor
 ra2=lon2*!dtor
 dec1=lat1*!dtor
 dec2=lat2*!dtor
 gcirc,u,ra1,dec1,ra2,dec2,value
 value=value/!dtor
 return,value
 end
 
 PRO mc_integrate_ZL,helilon_in,eclipticlat_in,sum
 ; perform integreation as a summation over radnomly selected points
 common sukminkwoon,iflagSMK,lon,lat,ZL
 helilon=helilon_in
 if (helilon gt 180) then helilon=360-helilon
 eclipticlat=eclipticlat_in
 nlon=n_elements(lon)
 nlat=n_elements(lat)
 ;................................
 sum=0.0d0
 mask=ZL*0.0
 openw,47,'distances.dat'
 ; there are 3282.80635 square degrees per steradian
 f=3.
 nMC=3282.80635*f
 generaterandompointsonasphere,nMC,lonsky,latsky
 ic=0
 for ipt=0,nMC-1,1 do begin
     dist=finddist(helilon,eclipticlat,lonsky(ipt),latsky(ipt))
     if (dist le 90) then begin
        alpha=90.-dist
;       sum=sum+(4.0d0*!pi/nMC)*sin(alpha*!dtor);*cos(alpha*!dtor)
        getpointerstotable,lonsky(ipt),latsky(ipt),ilon,ilat
        sum=sum+ZL(ilon,ilat)*(4.0d0*!pi/nMC)*sin(alpha*!dtor);*cos(alpha*!dtor)
	ic=ic+1
        endif
     endfor
 close,47
 return
 end
 
 
 PRO integrate_ZL,helilon_in,eclipticlat_in,sum
 common sukminkwoon,iflagSMK,lon,lat,ZL
 helilon=helilon_in
 if (helilon gt 180) then helilon=360-helilon
 eclipticlat=eclipticlat_in
 nlon=n_elements(lon)
 nlat=n_elements(lat)
 ;................................
 sum=0.0d0
 mask=zl*0.0
 openw,47,'distances.dat'
 ic=0
 for ilon=0,nlon-1,1 do begin
     for ilat=0,nlat-1,1 do begin
         dist=finddist(helilon,eclipticlat,lon(ilon),lat(ilat))
         printf,47,helilon-lon(ilon),eclipticlat-lat(ilat),dist
         if (dist le 90) then begin
             alpha=90.-dist
             contribution=(2.*2.*cos(alpha*!dtor))/(3282.80635)
;            sum=sum+contribution*sin(alpha*!dtor)
             sum=sum+zl(ilon,ilat)*contribution*sin(alpha*!dtor);*cos(alpha*!dtor)
	ic=ic+1
             endif
         endfor
     endfor
 close,47
 ; normalize the integral to
 ; there are 3282.80635 square degrees per steradian
;sum=sum/(2.*!pi*3282.80635)	; last numbers are fudge factors
; note factor sto convert 1/deg.sq to 1/sr and normalization of 'uniform sources case' and a small fudge.
 return
 end
 
 common sukminkwoon,iflagSMK,lon,lat,ZL
 iflagSMK=1
 zflag=1
 ; set up the tables
 jd=systime(/julian,/utc)
 get_zodiacal_smk,jd,zdflux
 ZL(where(ZL le 0))=max(ZL)
 ; use symmetry to expand the array
 zl=[reverse([[reverse(zl,2)],[zl]],1),[[reverse(zl,2)],[zl]]]
 zl=zl(*,[findgen(45),findgen(92-46)+46])
 lon=[-reverse(lon),lon]
 lat=[-reverse(lat),lat]
 lat=[lat(0:44),lat(46:91)]
 ; give the ecliptic coordinates of the zenith considered from a pixel on the Moon's DS edge
 eclipticlat_in=10.0
 sum_MC=0.0
 sum=0.0
 ic=0
 openw,68,'hemispheric_wewighted_sum.dat'
 for helilon_in=-180,180,15  do begin
     integrate_ZL,helilon_in,eclipticlat_in,tenthmagstarsseen
     mc_integrate_ZL,helilon_in,eclipticlat_in,tenthmagstarsseen_MC
     printf,68,helilon_in,eclipticlat_in,tenthmagstarsseen_MC,tenthmagstarsseen
     print,helilon_in,eclipticlat_in,tenthmagstarsseen_MC,tenthmagstarsseen
     sum=sum+tenthmagstarsseen
     sum_MC=sum_MC+tenthmagstarsseen_MC
     ic=ic+1
     endfor
 close,68
 print,'Mean sum for MK: ',sum_MC/float(ic)
 print,'Mean sum integr: ',sum/float(ic)
 data=get_data('hemispheric_wewighted_sum.dat')
 plot,yrange=[0,3500],data(0,*),data(2,*),xtitle='!7k!3-!7k!3!dO!n',ytitle='Hemispheric integral'
 oplot,data(0,*),data(3,*),color=fsc_color('red')
 end
