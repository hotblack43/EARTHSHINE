FUNCTION getfluxfrompatch,im_in,lon,lat
im=im_in
idx=where(lon gt 30 and lon lt 60 and lat gt -10 and lat lt 10)
value1=mean(im(idx))
jdx=where(lon gt -60 and lon lt -30 and lat gt -10 and lat lt 10)
value2=mean(im(jdx))
if (value1 gt value2) then begin
	im(idx)=max(im)
	value=value1
endif
if (value2 gt value1) then begin
	im(jdx)=max(im)
	value=value2
endif
;tvscl,im
return,value
end

PRO get_JD_from_filename,str,JDstr
 idx=strpos(str,'245')
 JDstr=strmid(str,idx,15)
 return
 end
 
 PRO MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
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
 
 PRO gofind_k,fname,JD,instmag,am
 common fnames,fnames
 obsname='mlo'
 ; Langley plot method
 idx=sort(JD)
 JD=JD(idx)
 instmag=instmag(idx)
 am=am(idx)
 ;
 uniqJD=long(JD)
 uniqJD=uniqJD(uniq(uniqJD))
 print,'-------------------------------------'
 openw,22,fname+'_nightly_ext.dat'
 for k=0,n_elements(uniqJD)-1,1 do begin
     idx=where(long(JD) eq uniqJD(k))
     res2=ladfit(am(idx),jd(idx))
     if (res2(1) gt 0) then sstr='setting'
     if (res2(1) lt 0) then sstr='rising'
     if (n_elements(idx) ge 4) then begin
         ; get info from JD
         MOONPHASE,mean(JD(idx),/double),az_moon,phase_angle_M,alt_moon,alt_sun,obsname
         res=robust_linefit(am(idx)+randomn(seed,n_elements(idx))*0.00001,instmag(idx),sig,sigs);,/BISECT)
if (res(1) gt 0 and abs(sigs/res(1)) lt 1./3.) then begin
         print,fname,uniqJD(k),' k= ',res(1),' +/- ',sigs(0),' ',sstr
         printf,77,fname,uniqJD(k),' k= ',res(1),' +/- ',sigs(0),' ',sstr
         fname_number=where(fnames eq fname)
         if (sstr eq 'rising') then sstr_number=1
         if (sstr eq 'setting') then sstr_number=0
         printf,78,format='(i3,1x,i10,2(1x,f9.5),1x,i2)',fname_number,uniqJD(k),res(1),sigs(0),sstr_number
         printf,79,format='(a8,a3,i10,a3,f9.5,a3,f9.5,a3,a,a3)',fname,' & ',uniqJD(k),' & ',res(1),' & ',sigs(0),' & ',sstr,' \\'
         printf,80,format='(i3,i10,2(1x,f9.3),1x,i2)',fname_number,uniqJD(k),phase_angle_M,res(0),sstr_number
         printf,22,res(1),sigs(0)
         yhat=res(0)+res(1)*am(idx)
         oplot,am(idx),yhat,color=fsc_color('red')
         oplot,am(idx),instmag(idx),color=fsc_color('red'),psym=6
	xyouts,mean(am(idx)),mean(instmag(idx))+0.1,uniqJD(k),orientation=-25
endif
         print,'-------------------------------------'
         endif
     endfor
 close,22
 data=get_data(fname+'_nightly_ext.dat')
 k=reform(data(0,*))
 err=reform(data(1,*))
 wmn=total(data(0,*)*(1./data(1,*)^2))/total(1./data(1,*)^2)
 wmnerr=total(data(1,*)*(1./data(1,*)^2))/total(1./data(1,*)^2)
 print,fname,' Mean k: ',mean(k),' median: ',median(k), ' weighted mean: ',wmn, ' +/- ',wmnerr
 print,'min/max k: ',min(k),max(k)
 return
 end
 
 
 PRO get_am_fromJD,JD,am
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the airmass
 moonpos, JD, RAmoon, DECmoon
 am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
 return
 end
 
 PRO get_filter_from_JD,JD,filterstr,filternumber
 filternames=['B','V','VE1','VE2','IRCUT'] 
 filternumbers=indgen(n_elements(filternames))
 file='JD_and_filter.txt'
 spawn,"grep "+string(JD,format='(f15.7)')+" "+file+" > hkjgvghjkv"
 openr,22,'hkjgvghjkv'
 str=''
 readf,22,str
 close,22
 bits=strsplit(str,' ',/extract)
 JDfound=double(bits(0))
 filterstr=bits(1)
 if (JD ne JDfound) then stop
 filternumber=filternumbers(where(filternames eq filterstr))
 return
 end
 
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 
 ;---------------------------------------------------
 common fnames,fnames
 if_want_lonlatpositiononBS=1
 nstring=''
 if (if_want_lonlatpositiononBS eq 1) then nstring='_lonlatpatch'
 fnames=['B','V','VE1','IRCUT','VE2']
 openw,79,'extinction_coefficients_from_BS'+nstring+'.tex'
 printf,79,'   Filter &   JD      &   k       & $\sigma$k & set/rise\\\hline'
 openw,78,'extinction_coefficients_from_BS'+nstring+'.dat'
 openw,77,'extinction_coefficients_from_BS'+nstring+'.txt'
 openw,80,'exoatmosphericBS.txt'
 for ifilter=0,4,1 do begin
     fname=fnames(ifilter)
     openr,1,'cubeLIST.onlygoodones'
     datanew=[]
     while not eof(1) do begin
         str=''
         readf,1,str
         if (strpos(str,'_'+fname+'_') ne -1) then begin
         print,str
         get_JD_from_filename,str,JD
         JD=double(JD)
         cube=readfits(str,h,/silent)
         im=reform(cube(*,*,0))
         lon=reform(cube(*,*,5))
         lat=reform(cube(*,*,6))
         get_EXPOSURE,h,exptime
         if (if_want_lonlatpositiononBS ne 1) then totflux=total(im,/double)/exptime 
         if (if_want_lonlatpositiononBS eq 1) then totflux=getfluxfrompatch(im,lon,lat)/exptime 
         instmag=-2.5*alog10(totflux)
         get_am_fromJD,JD,amitem
         datanew=[[datanew],[JD,instmag,amitem]]
	  endif
         endwhile
     close,1
     data=datanew
     JD=reform(data(0,*))
     instmag=reform(data(1,*))
     am=reform(data(2,*))
     plot,am,instmag,xtitle='Airmass',ytitle='Instr. mag',title=fname,psym=7,xstyle=3,ystyle=3
     gofind_k,fname,JD,instmag,am
     endfor
 close,77
 close,78
 close,79
 close,80
 end
