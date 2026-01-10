 PRO get_temperature,header,temperature
 idx=where(strpos(header, 'UNSTTEMP') ne -1)
 str='-911'
 if (idx(0) ne -1) then str=header(idx(0))
 temperature=float(strmid(str,16,15))
 return
 end

PRO get_sunmoonangle,jd,angle
;COMPILE_OPT idl2, HIDDEN
; returns the angle between Sun and Moon as seen from Earth
angle=1
MOONPOS, jd, ra_moon, dec_moon, dis
obsname='MLO'
eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
; Where is the Sun in the local sky?
        SUNPOS, jd, ra_sun, dec_sun
        eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  OBSNAME=obsname
; what is the angular distance between Moon and SUn?
u=0     ; radians
gcirc,u,ra_moon*!dtor, dec_moon*!dtor,ra_sun*!dtor, dec_sun*!dtor,dis
angle=abs(dis/!pi*180.)
if (ra_sun gt ra_moon) then angle=-angle
return
end

PRO get_time,header,dectime
;COMPILE_OPT idl2, HIDDEN
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
 
 PRO get_airmass,jd,am
;COMPILE_OPT idl2, HIDDEN
 ;
 ; Calculates the airmass of the observed Moon as seen from MLO
 ;
 ; INPUT:
 ;   jd  -   julian day
 ; OUTPUT:
 ;   am  -   the required airmass
 ;
 
 lat=19.5362d0
 lon=+155.5763d0	; sign is + because airmass takes WEST longitude
 MOONPOS,jd,ra,dec
 eq2hor,ra,dec,jd,alt,az,lon=lon,lat=lat
 ra=degrad(ra)
 dec=degrad(dec)
 lat=degrad(lat)
 lon=degrad(lon)
 am = airmass(jd,ra,dec,lat,lon)
 return
 end
 
 PRO get_filtername,header,name
;COMPILE_OPT idl2, HIDDEN
 ;
 idx=where(strpos(header, 'DMI_COLOR_FILTER') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 name=strmid(str,29,8)
 return
 end
 
 PRO get_EXPOSURE,h,exptime
;COMPILE_OPT idl2, HIDDEN
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 ;------------------------------------------------------------------------------
 ; Code to extract fluxes (cts/s) from MOON frames
 ;------------------------------------------------------------------------------
;COMPILE_OPT idl2, HIDDEN
 !P.CHARSIZE=1.3
 JDstr=''
 openr,38,'name.txt' & readf,38,JDstr & close,38
 pathname=strcompress('/data/pth/DATA/ANDOR/BIASSUBTRACTEDALIGNEDSUM/'+JDstr+'/',/remove_all)
 ;pathname=strcompress('/media/SAMSUNG/BIASSUBTRACTEDALIGNEDSUM/'+JDstr+'/',/remove_all)
 print,'looking in: ',pathname
 openw,65,'JDname.txt' & printf,65,JDstr & close,65
 files=file_search(pathname,"*MOON*",count=n)
 ; strip out various types of filenames
 idx=where(strpos(files,'DITHER') eq -1)
 files=files(idx)
 n=n_elements(files)
 print,'Found ',n,' files.'
 openw,44,strcompress(JDstr+'_fluxes.dat',/remove_all)
 for i=0,n-1,1 do begin
	print,files(i)
     im=readfits(files(i),h,/silent)
	help,im
;    im=im-397.0
     l=size(im)
     filtername='BLANK'
     exptime=0.0
     get_EXPOSURE,h,exptime
             tot=total(im,/double)
             if (tot/exptime lt 0) then begin
		print,'exptime,tot,filename:',exptime,tot,files(i)
		endif
     get_filtername,h,filtername
     get_time,h,dectime
     get_temperature,h,temperature
	print,'T: ',temperature
     print,'dectime:',dectime
     jd=dectime
     get_sunmoonangle,jd,angle
     get_airmass,jd,am
     print,'jd,am: ',jd,am
     if (max(im) gt 10000 and max(im) lt 50000.0 and am lt 1e5 and temperature eq 999) then begin
         filtername=strcompress('_'+filtername+'_',/remove_all)
         if (l(0) eq 2) then begin
             fmtstr='(f15.1,1x,f19.2,1x,1x,f17.7,1x,f9.2,1x,a)'
             printf,44,format=fmtstr,tot/exptime,am,jd,angle,filtername
             endif
         if (l(0) eq 3) then begin
             for j=0,l(3)-1,1 do begin
                 iiiim=im(*,*,j)
		 tt=total(iiiim,/double)
                 printf,44,format=fmtstr,tt/exptime,am,jd,angle,filtername
                 endfor
             endif
         endif
     endfor
 close,44
 print,'Go and plot it ...'
 print,'with plot_LAMP_fluxes.pro '
 print,' data are in file '+strcompress(JDstr+'_fluxes.dat',/remove_all)
 end
