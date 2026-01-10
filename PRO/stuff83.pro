FUNCTION allen_moon_flux,phase_angle
; Calculates the lunar flux at Earth using 
; formulae in Allen Astrophysical Quantities.
; phase_angle is input in degrees
V10=+0.23	
rdelta=0.0026
phase=abs(phase_angle)
phaselaw=0.026*phase+4.0e-9*phase^4
V=5.0*alog10(rdelta)+V10+phaselaw
value=10^(-V/2.5)
return,value
end

FUNCTION allenphaselaw,phase
; phase should be in degrees
value=allen_moon_flux(phase)
value=value/allen_moon_flux(0.0)
return,value
end

 PRO getcoordsfromheader,header,x0,y0,radius,discra
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     x0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     y0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCRA')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCRA not in header. Assigning dummy value'
     discra=134.327880000
     endif else begin
     discra=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),15,9))
     endelse
 return
 end

 PRO gofindradiusandcenter,im_in,x0,y0,radius
 ; Will take an image - im_in- and return estimates of the radius and center coordinates
 ; The code is based on fitting circles to three points on the circle rim.
 im=im_in
 ; detect the edges of the BS
 ;im=laplacian(im,/CENTER)
 im=sobel(im)
 ; im treshold and remove some single pixels
 idx=where(im gt max(im)/4.)
 jdx=where(im le max(im)/4.)
 im(idx)=1
 im(jdx)=0
 ; remove specks
 im=median(im,3)
 ; find good estimates of the circle radius and centre
 ntries=100
 idx=where(im ne 0)
 coords=array_indices(im,idx)
 nels=n_elements(idx)
 openw,49,'trash14.dat'
 for i=0,ntries-1,1 do begin 
     irnd=randomu(seed)*nels
     x1=reform(coords(0,irnd))
     y1=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x2=reform(coords(0,irnd))
     y2=reform(coords(1,irnd))
     irnd=randomu(seed)*nels
     x3=reform(coords(0,irnd))
     y3=reform(coords(1,irnd))
     fitcircle3points,x1,y1,x2,y2,x3,y3,x0,y0,radius
     printf,49,x0,y0,radius
     endfor
 close,49
 data=get_data('trash14.dat')
 x0=median(reform(data(0,*)))
 y0=median(reform(data(1,*)))
 radius=median(reform(data(2,*)))
 return
 end
 PRO gostripthename,str,fitsname
 ;xx=strpos(str,'245')
 ;fitsname=strmid(str,xx,strlen(str)-xx)
 str2=strsplit(str,'/',/extract)
 fitsname=str2(n_elements(str2)-1)
 return
 end
 
 PRO get_filtername,header,name
 ;
 idx=where(strpos(header, 'DMI_COLOR_FILTER') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 name=strmid(str,29,8)
 return
 end
 
 PRO read_header,header,JD,exptime
 string=header(where (strpos(header,'EXPTIME') eq 0))
 exptime=float(strmid(string,9,strlen(string)-9))
 string=header(where (strpos(header,'DATE-OBS') eq 0))
 yy=fix(strmid(string,11,4))
 mm=fix(strmid(string,16,2))
 dd=fix(strmid(string,19,2))
 string=header(where (strpos(header,'TIME-OBS') eq 0))
 hh=fix(strmid(string,11,2))
 mi=fix(strmid(string,14,2))
 ss=float(strmid(string,17,6))
 JD=double(julday(mm,dd,yy,hh,mi,ss))
 return
 end
 
 PRO get_info_from_header,header,str,valout
 if (str eq 'PHSAN_E') then begin
     get_earthphaseangle,header,valout
     return
     endif
 if (str eq 'ACT') then begin
     get_cycletime,header,valout
     return
     endif
 if (str eq 'UNSTTEMP') then begin
     get_temperature,header,valout
     return
     endif
 if (str eq 'DMI_ACT_EXP') then begin
     get_measuredexptime,header,valout
     return
     endif
 if (str eq 'DMI_COLOR_FILTER') then begin
     get_filtername,header,valout
     return
     endif
 if (str eq 'FRAME') then begin
     get_time,header,valout
     return
     endif
 return
 end
 
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 PRO get_earthphaseangle,header,earthphaseangle
 idx=where(strpos(header, 'PHSAN_E') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 earthphaseangle=float(strmid(str,16,15))
 return
 end
 
 PRO get_cycletime,header,acttime
 idx=where(strpos(header, 'ACT') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 acttime=float(strmid(str,16,15))
 return
 end
 
 PRO get_temperature,header,temperature
 idx=where(strpos(header, 'UNSTTEMP') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 temperature=float(strmid(str,16,15))
 return
 end
 
 PRO get_measuredexptime,header,measuredtexp
 idx=where(strpos(header, 'DMI_ACT_EXP') ne -1)
 str='999'
 measuredtexp=911
 if (idx(0) ne -1) then begin
     str=header(idx(0))
     bit=strmid(str,24,8)
     measuredtexp=999
     if (strmid(bit,0,3) ne 'Not') then measuredtexp=float(strmid(str,24,8))
     endif
 return
 end
 
 PRO get_times,h,act,exptime
 get_info_from_header,h,'DMI_ACT_EXP',act
 get_EXPOSURE,h,exptime
 end
 
 PRO getbasicfilename,namein,basicfilename
 print,namein
 basicfilename=strmid(namein,strpos(namein,'.')-7)
 ;basicfilename=strmid(namein,strpos(namein,'2455'))
 return
 end
 
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
 PRO printthesenicely,ww,jd,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20,x21,x22,x23,str
 array=[jd,x1,x2,x3,x4,x5,x6,x7,x8,x9,x10,x11,x12,x13,x14,x15,x16,x17,x18,x19,x20,x21,x22,x23]
 idx=where(finite(array) ne 1)
 if (idx(0) ne -1) then array(idx)=911.999
 fmt2='(f15.7,23(1x,g20.14),1x,a)'
 print,format=fmt2,array,str
 printf,ww,format=fmt2,array,str
 return
 end
 
 PRO get_mask,x0,y0,radius,mask
 ; build a 1/0 mask that is a circle (center x0,y0) and radius r with 0's outside radius and 1's inside
 common sizes,l
 nx=l(0) & ny=l(1) & mask=fltarr(nx,ny)
 for i=0,nx-1,1 do begin
     for j=0,ny-1,1 do begin
         rad=sqrt((i-x0)^2+(j-y0)^2)
         if (rad ge radius) then mask (i,j)=0 else mask(i,j)=1.0
         endfor
     endfor
 return
 end
 PRO gostripthename,str,fitsname
 ;xx=strpos(str,'245')
 ;fitsname=strmid(str,xx,strlen(str)-xx)
 str2=strsplit(str,'/',/extract)
 fitsname=str2(n_elements(str2)-1)
 return
 end
 
 PRO get_filtername,header,name
 ;
 idx=where(strpos(header, 'DMI_COLOR_FILTER') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 name=strmid(str,29,8)
 return
 end
 
 PRO read_header,header,JD,exptime
 string=header(where (strpos(header,'EXPTIME') eq 0))
 exptime=float(strmid(string,9,strlen(string)-9))
 string=header(where (strpos(header,'DATE-OBS') eq 0))
 yy=fix(strmid(string,11,4))
 mm=fix(strmid(string,16,2))
 dd=fix(strmid(string,19,2))
 string=header(where (strpos(header,'TIME-OBS') eq 0))
 hh=fix(strmid(string,11,2))
 mi=fix(strmid(string,14,2))
 ss=float(strmid(string,17,6))
 JD=double(julday(mm,dd,yy,hh,mi,ss))
 return
 end
 
 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end
 
 PRO get_cycletime,header,acttime
 idx=where(strpos(header, 'ACT') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 acttime=float(strmid(str,16,15))
 return
 end
 
 PRO get_temperature,header,temperature
 idx=where(strpos(header, 'UNSTTEMP') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 temperature=float(strmid(str,16,15))
 return
 end
 
 PRO get_measuredexptime,header,measuredtexp
 idx=where(strpos(header, 'DMI_ACT_EXP') ne -1)
 str='999'
 measuredtexp=911
 if (idx(0) ne -1) then begin
     str=header(idx(0))
     bit=strmid(str,24,8)
     measuredtexp=999
     if (strmid(bit,0,3) ne 'Not') then measuredtexp=float(strmid(str,24,8))
     endif
 return
 end
 
 PRO get_times,h,act,exptime
 get_info_from_header,h,'DMI_ACT_EXP',act
 get_EXPOSURE,h,exptime
 end
 
 PRO getbasicfilename,namein,basicfilename
 basicfilename=strmid(namein,strpos(namein,'.')-7)
 return
 end
 
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
 PRO findafittedlinearsurface,im,mask,thesurface
 l=size(im,/dimensions)
 common xsandYs,X,Y
 ;----------------------------------------
 offset=mean(im(0:10,0:10))
 thesurface=findgen(512,512)*0.0
 mim=im
 get_lun,wxy
 openw,wxy,'masked.dat'
 for i=0,511,1 do begin
     for j=0,511,1 do begin
         ;if (mim(i,j) ne 0.0) then begin
         if ((i le 10 or i gt 500) and (j le 10 or j ge 500)) then begin
             printf,wxy,i,j,mim(i,j)
             ;print,i,j,mim(i,j)
             endif
         endfor
     endfor
 close,wxy
 free_lun,wxy
 data=get_data('masked.dat')
 res=sfit(data,/IRREGULAR,1,kx=coeffs)
 print,coeffs
 thesurface=coeffs(0,0)+coeffs(1,0)*y+coeffs(0,1)*x+coeffs(1,1)*x*y
 ;thesurface=thesurface+offset
 return
 end
 
 PRO bestBSspotfinder,im,cg_x,cg_y
 ; find the coordinates of a spot near the brightest part of the BS
 l=size(im,/dimensions)
 smooim=median(im,5)
 idx=where(smooim eq max(smooim))
 coo=array_indices(smooim,idx)
 cg_x=coo(0)
 cg_y=coo(1)
 if (cg_x lt 0 or cg_x gt l(0) or cg_y lt 0 or cg_y gt l(1)) then stop
 return
 end
 
 PRO gofindDSandBSinboxes,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS,iflag
 ; determine if BS is to the right or the left of the center
 ; iflag = 1 means position 1
 ; iflag = 2 means position 2
 if (iflag eq 1) then ipos=4./5.
 if (iflag eq 2) then ipos=2./3.
 BS=911.999
 DS=911.999
 if ((cg_x-w ge 0 and cg_x+w le 511 and cg_y-w ge 0 and cg_y+w le 511) and (x0-radius*ipos-w ge 0 and x0-radius*ipos+w le 511 and y0-w ge 0 and y0+w le 511)) then begin
     if (cg_x gt x0) then begin
         ; BS is to the right
         BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
         DS=median(im(x0-radius*ipos-w:x0-radius*ipos+w,y0-w:y0+w))
         endif
     if (cg_x lt x0) then begin
         ; BS is to the left
         BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
         DS=median(im(x0+radius*ipos-w:x0+radius*ipos+w,y0-w:y0+w))
         endif
     endif
 return
 end
 
 PRO gogeteverythingelse,im1_in,im2_in,BS,TOT,DS23,DS45,itype
 common circle,cg_x,cg_y,x0,y0,radius
 common JDnight,numnight,basename,albedo
 im1=im1_in
 im2=im2_in
 if_removelinear=1
 if (if_removelinear eq 1) then begin
     get_mask,x0,y0,radius,mask
     findafittedlinearsurface,im1,mask,thesurface
     im1=im1-thesurface
     findafittedlinearsurface,im2,mask,thesurface
     im2=im2-thesurface
     endif
 ;
 w=11
 iflag=2
 gofindDSandBSinboxes,im1,im2,x0,y0,radius,cg_x,cg_y,w,BS,DS23,iflag
 iflag=1
 gofindDSandBSinboxes,im1,im2,x0,y0,radius,cg_x,cg_y,w,BS,DS45,iflag
 TOT=total(im1,/double)
 ; get the albedo out of the previously constructed file "results_FFM_onrealimages_JDJDJDJD.dat"
 albedo=9.911
 if (itype eq 5) then begin
     wantname=strcompress('results_FFM_onrealimages_'+string(numnight)+'.dat',/remove_all)
     JD=strmid(basename,0,13)
     str='grep '+JD+' '+wantname+" | awk '{print $1,$15}' > alb.dat"
     spawn,str
     h=file_info('alb.dat')
     if (h.size ne 0) then begin
         a=get_data('alb.dat')
         albedo=a(1)
         endif
     endif
 return
 end
 
 PRO getbasicinfo,filename,jd,filtername,exptime,am
 common ims,im
 print,'in getbasicinfo: ',filename
 im=readfits(filename,header)
 get_info_from_header,header,'FRAME',JD
 get_filtername,header,filtername
 filtername=strcompress('_'+filtername+'_',/remove_all)
 get_times,header,act,exptime
 mlo_airmass,jd,am
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
distance=dis/Rearth
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
; return Sun-Moon-Earth angle (amgle at Moon) in degrees
MOONPHASE,jd(0),phase_angle_M,alt_moon,alt_sun,obsname
phase=phase_angle_M
return
end
