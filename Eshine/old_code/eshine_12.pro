
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
; Version 12
;
;===============================================================================


PRO eshine_12



;-----------------------------------------------------------------------
; Specify the Earth-Moon-Sun geometry - either by the Julian Date or
; explicitly by the phase angle and libration parameters.
;-----------------------------------------------------------------------
; either give julian date ....
yr  = 2004
mon = 5
day = 31
hr  = 21
mnt = 0
sec = 0.0
JD = julday(mon,day,yr,hr,mnt,sec)
phase_angle = 0.0
lat_lib = 0.0
lon_lib = 0.0
PA_lib  = 0.0
; .... or give phase angle and libration parameters explicitly (and set JD=-1.0)
; JD = -1.0
; phase_angle = 180.0
; lat_lib = 0.0
; lon_lib = 0.0
; PA_lib  = 0.0


;-----------------------------------------------------------------------
; Observatory
;-----------------------------------------------------------------------
obsname = 'LaPalma'
if strcmp(obsname,'Earth''s center',/fold_case) then begin
  obslat = 0.0
  obslon = 0.0
  obsalt = -6365000.0
endif else if strcmp(obsname,'DMI',/fold_case) then begin
  obslat = 55.6
  obslon = 347.3
  obsalt = 15.0
endif else begin
  observatory, obsname, obs
  obslon = obs.longitude
  obslat = obs.latitude
  obsalt = obs.altitude
endelse
;--- conversion to GEO (geographic rectangular coordinates [km])
obssys = 'GEO'
Xobs = (6365.0+obsalt/1000.0)*cos(obslat*!DPI/180.0D)*cos(obslon*!DPI/180.0D)
Yobs = (6365.0+obsalt/1000.0)*cos(obslat*!DPI/180.0D)*sin(obslon*!DPI/180.0D)
Zobs = (6365.0+obsalt/1000.0)*sin(obslat*!DPI/180.0D)


;-----------------------------------------------------------------------
; Moon reflectance properties
;-----------------------------------------------------------------------
moon_albedo  = 1     ; 0=0.0720 (uniform) , 1=Clementine/HIRES 750 nm albedos
moon_BRDF    = 1     ; 0=Lambert (uniform), 1=Hapke -63 (uniform)


;-----------------------------------------------------------------------
; Earth reflectance properties
;-----------------------------------------------------------------------
earth_albedo = 0     ; 0=0.3000 (uniform) ,  1=cloud-free Earth,  2=time-dependent globally uniform albedo variation
earth_BRDF   = 0     ; 0=Lambert (uniform)


;-----------------------------------------------------------------------
; CCD & filter
;-----------------------------------------------------------------------
CCDsize = 1025            ; number of pixels - square CCD
CCDfactor = 1.0           ; a factor to change the CCD size and pixelscale
filter = 0                ; half-filter / no half-filter
filterfact = 10000        ; filter factor


;-----------------------------------------------------------------------
; Degrading effects
;-----------------------------------------------------------------------
if_poisson    = 0
if_sky        = 0
if_CCDeffects = 0


;-----------------------------------------------------------------------
; Set the graphics device to 'win', 'X', or 'ps'
;-----------------------------------------------------------------------
if_show = 1               ; see the image of the Moon on screen
device_str='win'
; device_str='X'
; device_str='ps'


;-----------------------------------------------------------------------
; Various options
;-----------------------------------------------------------------------
if_moon_visible       = 1                 ; =1 to produce a printout
if_librate            = 1                 ; =1 to enable an ephemeris-based libration calculation
if_variable_distances = 1                 ; =1 to enable ephemeris-driven distances


;-----------------------------------------------------------------------
; Make simulation
;-----------------------------------------------------------------------
iframe = 0

JDstart = JD
JDend   = JD + 0.000001
JDstep  =  2.0/24.0
for iJD = JDstart,JDend,JDstep do begin

  print, 'JD = ', iJD

  ;--- simulate the lunar observation
  eshine_core, iJD, phase_angle, lat_lib, lon_lib, PA_lib, $
               obsname, obssys, Xobs, Yobs, Zobs, $
               moon_albedo, moon_BRDF, earth_albedo, earth_BRDF, $
               CCDsize, CCDfactor, filter, filterfact, $
               if_poisson, if_sky, if_CCDeffects, $
               if_moon_visible, if_librate, if_variable_distances, $
               image_I, image_16bit, image_info

  ; if (icount EQ 0) AND (device_str NE 'ps') then begin
  ;   window, 0, xpos=0, ypos=0, xsize=imsize, ysize=imsize
  ;   tvscl, alog10(image_I+0.01)
  ; endif

  ;--- show image on screen
  imsize = fix(CCDsize/CCDfactor)
  if (if_show EQ 1) AND (device_str NE 'ps') then begin
    window, 0, xpos=0, ypos=0, xsize=imsize, ysize=imsize
    tvscl, image_16bit
  endif

  ;--- write 16-bit image to FITS or TIFF files, or an 8-bit image to a JPEG file
  writefits, strcompress('LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all), image_16bit
  ; write_tiff, strcompress('LunarSim'+string(iframe,format='(I4.4)')+'.tif',/remove_all), image_16bit, /SHORT
  image_8bit = bytscl(image_16bit)
  write_jpeg, strcompress('LunarImg_'+string(iframe,format='(I4.4)')+'.jpg',/remove_all), congrid(image_8bit,imsize,imsize), quality=80

  iframe = iframe + 1

endfor




END
