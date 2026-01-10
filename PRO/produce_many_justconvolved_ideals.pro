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

PRO getname,jd,nameout
jdstr=string(jd,format='(f15.7)')
nameout=strcompress('/data/pth/IDEALCONVOLVED/idealconv1p86_'+jdstr+'.fits',/remove_all)
return
end

PRO getname2,jd,nameout
jdstr=string(jd,format='(f15.7)')
;nameout=strcompress('/data/pth/IDEAL_g0p6_t0p1/ideal_'+jdstr+'.fits',/remove_all)
;nameout=strcompress('/data/pth/IDEAL_g0p6_t0p2/ideal_'+jdstr+'.fits',/remove_all)
;nameout=strcompress('/data/pth/IDEAL_g0p8_t0p2/ideal_'+jdstr+'.fits',/remove_all)
nameout=strcompress('/data/pth/IDEAL_g0p8_t0p1/ideal_'+jdstr+'.fits',/remove_all)
return
end

PRO get_one_synethic_image,JD,im1,h
; Generate one FITS images of the Moon for the given JD with albedo 0.3
get_lun,hjkl
openw,hjkl,'JDtouseforSYNTH_117'
printf,hjkl,format='(f15.7)',JD
close,hjkl
free_lun,hjkl
; set up albedo 0
get_lun,hjkl
openw,hjkl,'single_scattering_albedo.dat'
printf,hjkl,0.3
close,hjkl
free_lun,hjkl
;...get the image
spawn,'idl go_get_particular_synthimage_117.pro'
im1=readfits('ItellYOUwantTHISimage.fits',/silent,h)
return
end


for JD=julday(1,1,2012,0,0,0),julday(2,1,2012,0,0,0),0.3765434d0 do begin
get_one_synethic_image,JD,im,h
im=im/max(im)*50000.0d0
getname2,jd,nameout2
writefits,nameout2,im
;--------------------------
;writefits,'imagetofold.fits',im
;str='./justconvolve imagetofold.fits out.fits 1.76'
;spawn,str
;--------------------------
writefits,'imout.fits',im,h
str=' ./syntheticmoon imout.fits out.fits 1.86 100 '+string(long(randomu(seed)*10000.))
spawn,str
;--------------------------
out=readfits('out.fits',/silent)
;tvscl,hist_equal(out)
getname,jd,nameout
MOONPHASE,jd,phase_angle_M,alt_moon,alt_sun,obsname
print,jd,phase_angle_M
if (phase_angle_M gt 0) then out=reverse(out,1)
writefits,nameout,out,h
endfor
end
