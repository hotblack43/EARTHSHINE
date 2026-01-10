PRO find_model_radius,im,radius
row=total(im,1)
help,row
for i=0,510,1 do begin
if (row(i) eq 0 and row(i+1) gt 0.0) then guess1=256-i
endfor
for i=511,1,-1 do begin
if (row(i) eq 0 and row(i-1) gt 0.0) then guess2=i-256
endfor
print,guess1,guess2
radius=mean([guess1,guess2])
return
end

;===============================================================================
;
; ESHINE SIMULATION SIMPLE USER INTERFACE
;
; Assemble the following information and run the simulation:
;
; - Julian date or phase angle + libration parameters.
; - Observer's location
; - Moon albedos and BRDFs
; - Earth albedos and BRDFs
; - Filter properties.
; - Poisson or not
; - Run mode
;
; Version 277 - special version of eshine_16 that reads some input from files
;               e.g. the name of the Filter and whether to use Clementine or 
;               LRO lunar albedo
; Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute
;
;===============================================================================


PRO eshine_16_particularsynthimage_277
;compile_opt idl2, hidden
common phases,phase_angle_M, phase_angle_E
common E_albedo,single_scattering

MAPofEARTH=fltarr(360,180)
;------------------------------------------------------------
; get the switch for the lunar albedo map - Clementine or LRO
if_want_LRO=0
if_want_LRO=get_data('DOyouWantLROorClementine.txt')
print,'I see that you COMMAND if_want_LRO=',if_want_LRO
;-----------------------------------------------------------------------
; Specify the Earth-Moon-Sun geometry - either by the Julian Date or
; explicitly by the phase angle and libration parameters.
;-----------------------------------------------------------------------
; either give julian date ....
yr  = 2011
mon = 7
day = 11
hr  = 4
mnt = 11
sec = 5
JD = julday(mon,day,yr,hr,mnt,sec)
JD = 2455769.0908d0	; for use in th e83 files
JD = 2455917.0d0	; rainbow angle day
JD = 2455859.1365256d0
JD = systime(/julian)
; or read JD from a file
filnavn=get_data('JDtouseforSYNTH_117')
JD=filnavn(0)
;lat_lib = 0.0
;lon_lib = 0.0
;PA_lib  = 0.0
; .... or give phase angle and libration parameters explicitly (and set JD=-1.0)
;JD = -1.0
;phase_angle = 90.0
;lat_lib = 0.0
;lon_lib = 0.0
;PA_lib  = 0.0


;-----------------------------------------------------------------------
; Specify a valid observatory name. If 'MEEQ  X,Y,Z' then the MEEQ
;-----------------------------------------------------------------------
;obsname = 'MSO'
obsname='Earth''s center'
obsname = 'mlo'
print,' Observatory name : ',obsname
if strcmp(obsname,'MEEQ  X,Y,Z',/fold_case) then begin
  obssys = 'MEEQ'
  Xobs = 384400.0
  Yobs = 0.0
  Zobs = 0.0
endif else if strcmp(obsname,'Earth''s center',/fold_case) then begin
  obssys = 'GEO'
  obslat = 0.0
  obslon = 0.0
  obsalt = -6365000.0
print,obssys
endif else if strcmp(obsname,'DMI',/fold_case) then begin
  obssys = 'GEO'
  obslat = 55.6
  obslon = 347.3
  obsalt = 15.0
endif else begin
  obssys = 'GEO'
  observatory, obsname, obs
  obslon = -obs.longitude
  obslat = obs.latitude
  obsalt = obs.altitude
endelse
	print,'These values used for obsname,lon,lat: ',obsname,obslon,obslat
if strcmp(obssys,'GEO',/fold_case) then begin
  arg1=6365.0+obsalt/1000.0	; to speed up calculation
  arg2=obslat*!DPI/180.0D	; ...
  arg3=obslon*!DPI/180.0D	; ...
  arg4=cos(arg2)
  Xobs = (arg1)*arg4*cos(arg3)
  Yobs = (arg1)*arg4*sin(arg3)
  Zobs = (arg1)*sin(arg2)
endif


;-----------------------------------------------------------------------
; Earth and Moon reflectance specifications
;-----------------------------------------------------------------------
hapkeG=0.8
hapket=0.1
moon_albedo  = 1     ; 0=0.0720 (uniform) , 1=Clementine/HIRES 750 nm albedos
moon_BRDF    = 1     ; 0=Lambert (uniform), 1=Hapke -63 (uniform)
earth_albedo = 0     ; 0=0.3000 (uniform),  1=cloud-free Earth
earth_BRDF   = 0     ; 0=Lambert (uniform)

filnavn=get_data('single_scattering_albedo.dat')
earth_albedo_uniform_value=filnavn(0)
single_scattering=earth_albedo_uniform_value
print,'Single-scattering albedo is set to: ',single_scattering
; datalib='/home/pth/SCIENCEPROJECTS/EARTHSHINE/Eshine/data_eshine'
; datalib = 'C:/EarthShine/Simulations/data_eshine'
; datalib ='C:\Documents and Settings\Daddyo\Skrivebord\ASTRO\Eshine\data_eshine'
datalib='./Eshine/data_eshine'


; Image size & pixel scale
;-----------------------------------------------------------------------
CCDsize = 512		; number of pixels - square CCD
CCDfactor = 1                   ; a factor to change both imsize and pixelscale
imsize = fix(CCDsize/CCDfactor) ; image size in terms of pixels
pixelscale = 6.67*CCDfactor      ; arc seconds per pixel. Our telescope has 6.7"/pixel


;-----------------------------------------------------------------------
; Filters
;-----------------------------------------------------------------------
filter = 0                ; half-filter / no half-filter
filterfact = 10000        ; filter factor


;-----------------------------------------------------------------------
; Sky and CCD effects
;-----------------------------------------------------------------------
skylevel = 10.0       ; must be balanced against the 'raw image flux levels'
;
if_sky        = 0
if_CCDeffects = 0


;-----------------------------------------------------------------------
; Simulated camera settings
;-----------------------------------------------------------------------
exposure_time = 0.15
; camera_ID = 'sxvh9'
; camera_ID = 'STL1001E'
camera_ID = 'eshine_16'


;-----------------------------------------------------------------------
; Set the graphics device to 'win', 'X', or 'ps'
;-----------------------------------------------------------------------
if_show = 0               ; see the image of the Moon on screen
device_str = 'win'
device_str = 'X'
device_str = 'ps'


;-----------------------------------------------------------------------
; Various options
;-----------------------------------------------------------------------
if_moon_visible 	= 1  ; =1 to produce a printout
if_librate       	= 1  ; =1 to enable an ephemeris-based libration calculation
if_variable_distances = 1    ; =1 to enable ephemeris-driven distances


;-----------------------------------------------------------------------
; Make simulation
;-----------------------------------------------------------------------
iframe = 0
openw,83,'photometry.dat'
;
JDstart = JD
JDend   = JDstart
JDstep  =  1.0d0
;
;JDstart = JD+20
;JDend   = JDstart+28. 
;JDstep  =  1./3.
for iJD = JDstart,JDend,JDstep do begin


  ;--- simulate the lunar observation
  eshine_core_41, iJD, phase_angle, lat_lib, lon_lib, PA_lib, $
               obsname, obssys, Xobs, Yobs, Zobs, $
               moon_albedo, moon_BRDF, earth_albedo, earth_albedo_uniform_value, hapkeG, $
               hapket,earth_BRDF, datalib, imsize, pixelscale, $
               if_moon_visible, if_librate, if_variable_distances, $
               image_I, image_16bit, image_info, mask, MAPofEARTH

  ; perform very simple photometry on ideal image
; get_pixel_ratio,image_I,ratio
 ratio=-911
  print,format='(a,3(1x,d20.10))',' iJD,phase_angle_E,ratio = ',iJD,phase_angle_E,ratio
  printf,83,format='(a,3(1x,d20.10))',' iJD,phase_angle_E,ratio = ',iJD,phase_angle_E,ratio

  ;--- add sky background and a half-filter

  ;--- add CCD effects
  if (if_CCDeffects eq 1) then begin
    generate_CCD, image_16bit, iframe, camera_ID,exposure_time, CCD_out, raw_CCD
    image_16bit = uint(CCD_out+superbias)
  endif else begin
    image_16bit = uint(image_16bit)
  endelse

  ;--- show image on screen
  if (if_show EQ 1) AND (device_str NE 'ps') then begin
    window, 0, xpos=0, ypos=0, xsize=imsize, ysize=imsize
    tvscl, image_16bit
  endif

  ;--- write the floating point 'ideal image' to a FITS file
  MKHDR, header, image_I
  caldat, iJD, mm, dd, yy, hh, mnt, sec
  convert_to_strings, mm, dd, yy, hh, mnt, sec, secstring, datestring, UTtimestring
  sxaddpar, header, 'JULIAN',string(double(IJD),format='(d20.8)'), ' JULIAN DAY'
  sxaddpar, header, 'Mphase',string(double(phase_angle_M),format='(d20.8)'), ' Moon phase angle'
  sxaddpar, header, 'DATE-OBS', datestring, 'Simulated date'
  sxaddpar, header, 'TIME-OBS', UTtimestring, 'Simulated time (UT)'
  sxaddpar, header, 'OBSERVATORY', image_info.obsname, 'This is a simulation'
  sxaddpar, header, 'INSTRUMENT', 'IDEALIZED', 'NO camera is simulated in this image.'
  out_ideal_name=strcompress('OUTPUT/IDEAL/ideal_LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all)
  find_model_radius,image_I,radius
  sxaddpar, header, 'RADIUS',radius, 'Radius estimated from model image'
SCAnum=fix(1000*single_scattering)
if (SCAnum le 9) then SCAnumstr='0p00'+string(SCAnum)
if (SCAnum le 99 and SCAnum gt 9) then SCAnumstr='0p0'+string(SCAnum)
if (SCAnum le 999 and SCAnum gt 99) then SCAnumstr='0p'+string(SCAnum)
JDnumstr=string(JD,format="(f15.7)")
  ;--- write the 16-bit 'realistic image' to a FITS file
  MKHDR, header, image_16bit
  caldat, iJD, mm, dd, yy, hh, mnt, sec
  convert_to_strings, mm, dd, yy, hh, mnt, sec, secstring, datestring, UTtimestring
  sxaddpar, header, 'JULIAN',string(double(IJD),format='(d20.8)'), ' JULIAN DAY'
  sxaddpar, header, 'TIME-OBS', UTtimestring, 'Simulated time (UT)'
  sxaddpar, header, 'OBSERVATORY', image_info.obsname, 'This is a simulation'
  sxaddpar, header, 'INSTRUMENT', camera_ID, 'This camera is SIMULATED in this image.'
  sxaddpar, header, 'EXPTIME', string(exposure_time), 'This is the SIMULATED exposure time.'
; write out scaled image
; writefits, 'ItellYOUwantTHISimage.fits', image_I/max(image_I)*55000.0d0, header
; write out image not scaled
  writefits, 'ItellYOUwantTHISimage.fits', image_I*1.0d0, header
 namnam=strcompress('OUTPUT/IDEAL/ideal_image_JD'+string(iJD,format='(f15.7)')+'.fits',/remove_all)
 writefits,namnam,image_I*1.0d0, header


  iframe = iframe + 1

endfor

close,83


END
