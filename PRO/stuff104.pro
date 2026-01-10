PRO    getskyreferencepatch,model,obs,radius,idxpatch,skypatch
; Purpose is to calculate the mean fluxlevel in a patch of sky near the DS
; Use the model image to find the relative positions of disc centre and centre of gravity
 l=size(obs)
 if (l(0) ne 2) then stop
 meshgrid,l(1),l(2),x,y
 im=obs
 cg_x=total(x*model)/total(model)
 cg_y=total(y*model)/total(model)
;
        xr=findgen(l(1))
        yc=findgen(l(2))
     X = XR # (YC*0 + 1)      ;       eqn. 1
     Y = (XR*0 + 1) # YC      ;       eqn. 2
     r=sqrt((x-256)^2+(y-256)^2)
 if (cg_x lt 256) then begin	; BS is to the left of disc center
 idxpatch=where(r gt radius+15 and r lt radius+15+30 and y gt 256-radius/3. and y lt 256+radius/3. and x gt 256)
 endif
 if (cg_x gt 256) then begin	; BS is to the right of disc center
 idxpatch=where(r gt radius+15 and r lt radius+15+30 and y gt 256-radius/3. and y lt 256+radius/3. and x lt 256)
 endif
 im_patch=obs(idxpatch)
skypatch=avg(im_patch)
print,'Average sky patch, on DS, value: ',skypatch,' +/- ',stddev(obs(idxpatch))/sqrt(n_elements(idxpatch))
return
end

PRO extracttheJD,obsname,JD
 if (strpos(obsname,'ideal') eq -1) then begin
     ; Aha, it is not a synthetic image - it is an observed image
     idx=strpos(obsname,'/',/reverse_search)
     str=strmid(obsname,idx+1,15)
     JD=double(str); strlen(obsname))
     endif
 if (strpos(obsname,'ideal') ne -1) then begin
     im=readfits(obsname,header,/silent)
     idx=strpos(header,'JULIAN')
     str=header(where(idx ne -1))
     jd=double(strmid(str,15,15))
     endif
 return
 end
 
 PRO get_eshine_model,JD,im,header
 JDnumstr=string(JD,format="(f15.7)")
 SCAnumstr='0p310'
 fname=strcompress('OUTPUT/IDEAL/ideal_LunarImg_SCA_'+SCAnumstr+'_JD_'+JDnumstr+'.fit',/remove_all)
 if (file_exist(fname) eq 1) then begin
     print,'Ideal image file exists - loading ...'
     im=readfits(fname,header,/silent)
     endif else begin
     print,'Ideal image file must be created ...'
     get_lun,qwe
     openw,qwe,'JDtouseforSYNTH'
     printf,qwe,format='(f15.7)',JD
     close,qwe
     free_lun,qwe
     spawn,'idl go_get_particular_synthimage.pro'
     modname=''
     get_lun,asf 
     openr,asf,'nameofparticularsynthimage.txt' 
     readf,asf,modname 
     close,asf 
     free_lun,asf 
     im=readfits(modname,header,/silent)
     endelse
 return
 end
 
PRO get_airmass,jd,am
;
; Calculates the airmass of the observed Moon as seen from MLO
;
; INPUT:
;   jd  -   julian day
; OUTPUT:
;   am  -   the required airmass
;
    lat=19.5d0
    lon=155.12d0
    MOONPOS,jd,ra,dec
    eq2hor,ra,dec,jd,alt,az,lon=lon,lat=lat
    ra=degrad(ra)
    dec=degrad(dec)
    lat=degrad(lat)
    lon=degrad(lon)
    am = airmass(jd,ra,dec,lat,lon)
    return
end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

PRO getqflag,observed_image,q_flag
 ; use a binary code system for setting flags for various quality problems
 maxcounts=53000.0
 mincounts=10000.0
 maxstrip=50
 q_flag=0
 ; check image for OK fluxes
 if (max(observed_image) gt maxcounts) then q_flag=q_flag+1
 if (max(observed_image) lt mincounts) then q_flag=q_flag+2
 if (mean(observed_image) lt 0.0) then q_flag=q_flag+4
 ; check image for 'dragging'
 strip=avg(observed_image(*,0:20),1)
 if (max(strip) gt maxstrip) then q_flag=q_flag+8
 ;---------------------------
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

 PRO get_monphase,header,monphase
 idx=where(strpos(header, 'MPHASE') ne -1)
 str='999'
 if (idx(0) ne -1) then str=header(idx(0))
 monphase=float(strmid(str,13,13))
 return
 end

PRO getbestrotationangle,obs,model,bestrotangle,bestrotatedmodel
 maxcorr=-1e33
 bestrotangle=0.0
 get_lun,qws
 openw,qws,'rots.datt'
 for rotangle=-40.,20.,1. do begin
     rotmodel=ROT(model,rotangle, /INTERP)
     r=correlate(obs,rotmodel)
     printf,qws,rotangle,r
     if (r gt maxcorr) then begin
         maxcorr=r
         bestrotangle=rotangle
         bestrotatedmodel=rotmodel
         endif
     endfor
 close,qws & free_lun,qws
 print,'Found best rotated model at angle: ',bestrotangle
 return
 end
 
 PRO gocorrelatemodelwithobs,model,obs,bestrotangle,bestrotatedmodel
 get_lun,hjk
 openw,hjk,'corrs.dat'
 for ix=-4,4,1 do begin
     for iy=-4,4,1 do begin
         modl=shift(model,ix,iy)
         r=correlate(obs,modl)
         printf,hjk,r,ix,iy
         endfor
     endfor
 close,hjk
 free_lun,hjk
 data=get_data('corrs.dat')
 r=reform(data(0,*))
 ix=reform(data(1,*))
 iy=reform(data(2,*))
 idx=where(r eq max(r))
 best_ix=ix(idx(0))
 best_iy=iy(idx(0))
 model=shift(model,best_ix,best_iy)
 print,'SHifted model by:',best_ix,best_iy
 ; also allow for rotation
 bestrotangle=0.0
 bestrotatedmodel=model
 if_want_rotate=0
 if (if_want_rotate eq 1) then getbestrotationangle,obs,model,bestrotangle,bestrotatedmodel
 return
 end
 
 PRO make_circle,x0,y0,r,im_in
 x0=x0(0)
 y0=y0(0)
 r=r(0)
 angle=findgen(6000)/6000.*360.0
 x=fix(x0+r*cos(angle*!dtor))
 y=fix(y0+r*sin(angle*!dtor))
 im_in(x,y)=max(im_in)
 return
 end
 
 PRO determineFLIP,JD,refimFLIPneeded,az_moon
 refimFLIPneeded=0
 MOONPOS, jd, ramoon, DECmoon, dis
 obsname='MLO'
 eq2hor, ramoon, decmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
 print,'az:',az_moon
 if (az_moon gt 180.) then refimFLIPneeded=1
 print,'refimFLIPneeded:',refimFLIPneeded
 return
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
 
 PRO getpixels2,IMlonlat,idx,tname
;    targets(0,0)=-68.6 & targets(0,1)=-5.2	; Grimaldi
;    targets(1,0)=58.1  & targets(1,1)=16.5	; Crisium
;    targets(2,0)=35.5  & targets(2,1)=-15.2	; Nectaris
;    targets(3,0)=-11.36  & targets(3,1)=-43.31	; Tycho
 if (tname eq 'Grimaldi') then begin
     wlon=2.9	; degrees
     wlat=4.2	; degrees
     lon=-68.6+0.5 & lat=-15.	; select patch South of Grimaldi
     idx=where((IMlonlat(*,*,0) gt lon-wlon and IMlonlat(*,*,0) lt lon+wlon) and $
     ((IMlonlat(*,*,1) gt lat-wlat and IMlonlat(*,*,1) lt lat+wlat)))
 endif
 if (tname eq 'Crisium') then begin
     w=3.5	; degrees
     lon=58.1 & lat=16.5
     idx=where((IMlonlat(*,*,0) gt lon-w and IMlonlat(*,*,0) lt lon+w) and $
     ((IMlonlat(*,*,1) gt lat-w and IMlonlat(*,*,1) lt lat+w)))
 endif
 return
 end
