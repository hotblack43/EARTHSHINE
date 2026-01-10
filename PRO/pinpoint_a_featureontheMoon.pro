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

PRO determineFLIP,JD,refimFLIPneeded
refimFLIPneeded=0
MOONPOS, jd, ramoon, DECmoon, dis
obsname='MLO'
eq2hor, ramoon, decmoon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
print,'az:',az_moon
if (az_moon gt 180.) then refimFLIPneeded=1
print,'refimFLIPneeded:',refimFLIPneeded
return
end

PRO extracttheJD,obsname,JD
if (strpos(obsname,'ideal') eq -1) then begin
; Aha, it is nota synthetic image - itis an observed image
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
 
 PRO getcoordsfromheader,header,x0,y0,radius
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
 radius=134.327880000
 endif else begin
 radius=float(strmid(header(jdx),15,9))
 endelse
 return
 end
 
 PRO getpixels,lon,lat,IMlonlat,idx;lon,idxlat
 w=1.	; degrees
 idx=where((IMlonlat(*,*,0) gt lon-w and IMlonlat(*,*,0) lt lon+w) and $
          ((IMlonlat(*,*,1) gt lat-w and IMlonlat(*,*,1) lt lat+w)))
 return
 end
 
 ;--------------------------------------------------------------------------
 ; This code will read in a lunar image and call the synth code to make the 
 ; needed reference image for the time of observation. At the same time it 
 ; will determine whether a meridian flip was performed by the telescope and 
 ; flip the reference image if needed.
 ;--------------------------------------------------------------------------
 obsname='/media/Intenso_backup/OBSERVATIONS/DARKCURRENTREDUCED/BBSO_CLEANED/2455938.8971862MOON_VE2_AIR_DCR.fits'
 openr,33,'fils'
 while not eof(33) do begin
 readf,33,obsname
 obs=readfits(obsname,header)
 if (strpos(obsname,'ideal') ne -1) then obs=reverse(obs,1)
 extracttheJD,obsname,JD
 get_lun,qwe
 openw,qwe,'JDtouseforSYNTH'
 printf,qwe,format='(f15.7)',JD
 close,qwe
 free_lun,qwe	; JD now resides in file 'JDtouseforSYNTH'
 ; get the synth code to generate the refim
 spawn,'idl go_get_particular_synthimage.pro'
 modname=''& get_lun,asf & openr,asf,'nameofparticularsynthimage.txt' & readf,asf,modname & close,asf & free_lun,asf & model=readfits(modname)
 refimname=strcompress('lonlatSELimage_JD'+string(JD,format='(f15.7)')+'.fits',/remove_all)
 IMlonlat=readfits(refimname)
 determineFLIP,JD,refimFLIPneeded
 if (refimFLIPneeded eq 0) then begin
 ; since model us always North='UP' and West='Left' (image flips both axis at Meridian flip) we need to flip X on the East of the meridian
    IMlonlat(*,*,0)=reverse(IMlonlat(*,*,0),1)
    IMlonlat(*,*,1)=reverse(IMlonlat(*,*,1),1)
    model=reverse(model,1)
    endif
 if (refimFLIPneeded eq 1) then begin
 ; since model us always North='UP' and West='Left' (image flips both axis at Meridian flip) we need to flip Y on the West of the meridian
     IMlonlat(*,*,0)=reverse(IMlonlat(*,*,0),2)
     IMlonlat(*,*,1)=reverse(IMlonlat(*,*,1),2)
    model=reverse(model,2)
     endif
 getcoordsfromheader,header,x0,y0,radius
 make_circle,x0,y0,radius,obs
 ; shift the observed image
 obs=shift(obs,256-x0,256-y0)
 ntargets=4
 targets=fltarr(ntargets,2)
 targets(0,0)=-68.6 & targets(0,1)=-5.2
 targets(1,0)=59.1  & targets(1,1)=17.0
 targets(2,0)=35.5  & targets(2,1)=-15.2
 targets(3,0)=-11.36  & targets(3,1)=-43.31
     for itarget=0,ntargets-1,1 do begin
	lon=targets(itarget,0)
	lat=targets(itarget,1)
     getpixels,lon,lat,IMlonlat,idx
     obs(idx)=max((obs))	; mark the relevant pixels
	window,xsize=1024,ysize=512
     tvscl,[model/max(model),obs/max(obs)]
     endfor
	im=tvrd() & write_jpeg,strcompress('Model_Obs_spots_'+string(JD,format='(f15.7)')+'.jpeg',/remove_all),im
 endwhile
 close,33
 end
 
