 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 exptime=exptime(0)
 return
 end

PRO getALLobservation,filtername,obslist
; subroutine finds all observation files for a given filter type
; set the extinction
if (filtername eq '_B_') then k=0.15
if (filtername eq '_V_') then k=0.10
if (filtername eq '_VE1_') then k=0.07
if (filtername eq '_VE2_') then k=0.05
if (filtername eq '_IRCUT_') then k=0.07
         obsname='mlo'
         observatory,obsname,obs_struct
ic=0
spawn,'grep '+filtername+' list.txt > listousenowandsearselater.txt'
openr,55,'listousenowandsearselater.txt'	; ie same file as used in fit_ideal_profiles_v3.pro
while not eof(55) do begin
str=''
readf,55,str
; check for right filter
idx=strpos(str,filtername)
if (idx(0) ne -1) then begin
; now get the total flux
; first get the image
im=readfits(str,h,/silent)
; get the JD from the filename
jd=double(strmid(str,strpos(str,'24'),15))
; get the lunar phase
MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,'mlo'
; then get the exposure time
get_EXPOSURE,h,exp_time
; the get the flux
totflux=total(im,/double)/exp_time
; get the airmass
         moonpos, JD, RAmoon, DECmoon
         eq2hor, ramoon, decmoon, jd, alt_moon, az, ha,  OBSNAME='mlo'
         am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, obs_struct.latitude*!dtor, obs_struct.longitude*!dtor)
; then get the magnitude
mag=8.8-2.5*alog10(totflux)
; corrc et for extinction
mag=mag-k*am
if (ic eq 0) then obslist=[jd,az_moon,phase_angle_M,alt_moon,alt_sun,exp_time,mag,am]
if (ic gt 0) then obslist=[[obslist],[jd,az_moon,phase_angle_M,alt_moon,alt_sun,exp_time,mag,am]]
ic=ic+1
endif
endwhile
close,55
return
end

 
 PRO MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
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
 
 PRO getALLmodel_INFO,imodeltype,JDpresentinOBS,list
 obsname='mlo'
 if (imodeltype eq 0) then files=$
file_search('/data/pth/UNIVERSALSETOFMODELS/H-X_Clemnoscale/ideal_2*.fits',count=n)
 if (imodeltype eq 1) then files=$
file_search('/data/pth/UNIVERSALSETOFMODELS/newH-63_Clemnoscale/ideal_2*.fits',count=n)
 ic=0
 for i=0,n-1,1 do begin
     print,'I have this model file: ',files(i)
; extract the JD from the ideal-model filename
     JD=double(strmid(files(i),strpos(files(i),'24'),15))
     jd=jd(0)
     if (product(JDpresentinOBS-jd) eq 0) then begin	; 3 minutes is close enough
     im=readfits(files(i),h,/silent)
; that is, if we already have a model with that JD
     MOONPHASE,jd,az_moon,phase_angle_M,alt_moon,alt_sun,obsname
     totmag=-2.5*alog10(total(im(*,*,0)))-8.-17.
     if (ic eq 0) then list=[jd,az_moon,phase_angle_M,alt_moon,alt_sun,totmag]
     if (ic gt 0) then list=[[list],[jd,az_moon,phase_angle_M,alt_moon,alt_sun,totmag]]
     ic=ic+1
     endif else begin
; OK, it seems we have to calculate such a model
;for k=0,n_elements(JDpresentinOBS)-1,1 do begin
;print,format='(3(1x,f15.7))',JDpresentinOBS(k),jd,JDpresentinOBS(k)-jd
;endfor
print,'a file was not found'
print,format='(a,f15.7,a)','The required JD is: ',jd,' and somehow you should produce it.'
print,'i:',i
print,'size of files found:',n_elements(files)
;;stop
     endelse
     endfor
 return
 end
 
 
 
 
 ;----------------------------------------------------------------------------
 ; Code to help constrain range of reflectance modelsa nd albedo maps scalings
 ;----------------------------------------------------------------------------
 ; Method: extracts totalfæluxes (converted to mags) from observed images
 ;         and same from models found in 
 ;         /data/pth/UNIVERSALSETOFMODELS/H-X_Clemnoscal... and
 ;         /data/pth/UNIVERSALSETOFMODELS/newH-63_Clemnos.... and so on
 ;----------------------------------------------------------------------------
 !P.CHARSIZE=1.3
 !P.THICK=3
 !x.THICK=2
 !y.THICK=2
filtertypes=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
 nmodeltypes=2	; number of subdirectories with stored models
 modelname=['Hapke-X, no Clem scaling','new Hapke 63, no Clem scaling']
 colornames=['black','red','orange','green']
 devtype='x'
 devtype='ps'
 if (devtype eq 'x') then colornames(0)='white'
for ifilter=0,4,1 do begin
 filtertype=filtertypes(ifilter)	; the required filter name - NOTE: must have _ and _ in name
; Get the observations
 getALLobservation,filtertype,obslist
; NOTE: obslist contains: [jd,az_moon,phase_angle_M,alt_moon,alt_sun,exp_time,mag,am]
 JDpresentinOBS=reform(obslist(0,*))	
 observedPhase=reform(obslist(2,*))
 observedMags=reform(obslist(6,*))
; Get and plot models, observations
 for imodeltype=0,nmodeltypes-1,1 do begin
     openw,33,'userswitch314.txt'
          printf,33,imodeltype+1
     close,33
;
     getALLmodel_INFO,imodeltype,JDpresentinOBS,list
     ; the 'list' contains: jd,az_moon,phase_angle_M,alt_moon,alt_sun,totmag
     if (imodeltype eq 0) then begin
         plot,xrange=[-160,160],/nodata,xstyle=3,ystyle=3,yrange=[-14,-19],list(2,*),list(5,*),psym=7,$
         xtitle='Lunar Phase [FM=0]',ytitle='-2.5*log!d10!n(flux)',$
         title=filtertype
         oplot,list(2,*),list(5,*),psym=7,color=fsc_color(colornames(imodeltype))
     endif else begin
         oplot,list(2,*),list(5,*),psym=7,color=fsc_color(colornames(imodeltype))
     endelse
     xyouts,/normal,0.2,0.9-0.03*imodeltype,modelname(imodeltype),color=fsc_color(colornames(imodeltype))
     endfor	; end of imodeltype loop
; overplot the observations
 offset=(mean(list(5,*))-mean(observedMags))
     oplot,observedPhase,observedMags+offset,psym=1,color=fsc_color('blue')
     xyouts,/normal,0.2,0.9-0.03*imodeltype,'Observation',color=fsc_color('blue')
 endfor	; end of ifilter loop
 end
 
 
