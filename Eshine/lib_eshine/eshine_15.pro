
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
; Version 15
;
; Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute
;
;===============================================================================


PRO eshine_15


;-----------------------------------------------------------------------
; Specify the Earth-Moon-Sun geometry - either by the Julian Date or
; explicitly by the phase angle and libration parameters.
;-----------------------------------------------------------------------
; either give julian date ....
yr  = 2006
mon = 7
day = 31
hr  = 9
mnt = 0
sec = 0.0
JD = julday(mon,day,yr,hr,mnt,sec)
phase_angle = 0.0
lat_lib = 0.0
lon_lib = 0.0
PA_lib  = 0.0
; .... or give phase angle and libration parameters explicitly (and set JD=-1.0)
;JD = -1.0
;phase_angle = 90.0
;lat_lib = 0.0
;lon_lib = 0.0
;PA_lib  = 0.0


;-----------------------------------------------------------------------
; Specify a valid observatory name. If 'MEEQ  X,Y,Z' then the MEEQ
; coordinates should be specified as well.
;-----------------------------------------------------------------------
obsname = 'MSO'
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
endif else if strcmp(obsname,'DMI',/fold_case) then begin
  obssys = 'GEO'
  obslat = 55.6
  obslon = 347.3
  obsalt = 15.0
endif else begin
  obssys = 'GEO'
  observatory, obsname, obs
  obslon = obs.longitude
  obslat = obs.latitude
  obsalt = obs.altitude
endelse
if strcmp(obssys,'GEO',/fold_case) then begin
  Xobs = (6365.0+obsalt/1000.0)*cos(obslat*!DPI/180.0D)*cos(obslon*!DPI/180.0D)
  Yobs = (6365.0+obsalt/1000.0)*cos(obslat*!DPI/180.0D)*sin(obslon*!DPI/180.0D)
  Zobs = (6365.0+obsalt/1000.0)*sin(obslat*!DPI/180.0D)
endif


;-----------------------------------------------------------------------
; Earth and Moon reflectance specifications
;-----------------------------------------------------------------------
moon_albedo  = 1     ; 0=0.0720 (uniform) , 1=Clementine/HIRES 750 nm albedos
moon_BRDF    = 1     ; 0=Lambert (uniform), 1=Hapke -63 (uniform)
earth_albedo = 1     ; 0=0.3000 (uniform),  1=cloud-free Earth
earth_BRDF   = 0     ; 0=Lambert (uniform)
 datalib='/home/pth/SCIENCEPROJECTS/moon/Eshine/data_eshine'
;datalib = 'C:/EarthShine/Simulations/data_eshine'


;-----------------------------------------------------------------------
; Image size & pixel scale
;-----------------------------------------------------------------------
CCDsize = 1025                  ; number of pixels - square CCD
CCDfactor = 3                   ; a factor to change both imsize and pixelscale
imsize = fix(CCDsize/CCDfactor) ; image size in terms of pixels
pixelscale = 2.5*CCDfactor      ; arc seconds per pixel


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
if_poisson    = 0
if_CCDeffects = 0


;-----------------------------------------------------------------------
; Simulated camera settings
;-----------------------------------------------------------------------
exposure_time = 0.15
; camera_ID = 'sxvh9'
camera_ID = 'STL1001E'


;-----------------------------------------------------------------------
; Set the graphics device to 'win', 'X', or 'ps'
;-----------------------------------------------------------------------
if_show = 0               ; see the image of the Moon on screen
; device_str = 'win'
 device_str = 'X'
; device_str = 'ps'


;-----------------------------------------------------------------------
; Various options
;-----------------------------------------------------------------------
if_moon_visible       = 1                 ; =1 to produce a printout
if_librate            = 0                 ; =1 to enable an ephemeris-based libration calculation
if_variable_distances = 0                 ; =1 to enable ephemeris-driven distances


;-----------------------------------------------------------------------
; Make simulation
;-----------------------------------------------------------------------
iframe = 0

JDstart = JD
JDend   = JD + 29.
JDstep  =  1.
for iJD = JDstart,JDend,JDstep do begin

  help,iJD
  print,format='(a,1x,d20.10)', 'JD = ', iJD

  ;--- simulate the lunar observation
  eshine_core, iJD, phase_angle, lat_lib, lon_lib, PA_lib, $
               obsname, obssys, Xobs, Yobs, Zobs, $
               moon_albedo, moon_BRDF, earth_albedo, earth_BRDF, datalib, $
               imsize, pixelscale, $
               if_moon_visible, if_librate, if_variable_distances, $
               image_I, image_16bit, image_info

  ;--- add sky background and a half-filter
   add_telescope_and_filter_effects, image_16bit, filter, image_info.phase_angle_E, imsize, $
                                     filterfact, skylevel, if_sky

  ;--- add CCD effects
  if (if_CCDeffects eq 1) then begin
    generate_CCD, image_16bit, iframe, camera_ID, exposure_time, CCD_out, raw_CCD
    image_16bit = uint(CCD_out)
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
  sxaddpar, header, 'DATE-OBS', datestring, 'Simulated date'
  sxaddpar, header, 'TIME-OBS', UTtimestring, 'Simulated time (UT)'
  sxaddpar, header, 'OBSERVATORY', image_info.obsname, 'This is a simulation'
  sxaddpar, header, 'INSTRUMENT', 'IDEALIZED', 'NO camera is simulated in this image.'
  writefits, strcompress('OUTPUT/IDEAL_alb/ideal_LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all), image_I, header

  ;--- write the 16-bit 'realistic image' to a FITS file
  MKHDR, header, image_16bit
  caldat, iJD, mm, dd, yy, hh, mnt, sec
  convert_to_strings, mm, dd, yy, hh, mnt, sec, secstring, datestring, UTtimestring
  sxaddpar, header, 'TIME-OBS', UTtimestring, 'Simulated time (UT)'
  sxaddpar, header, 'OBSERVATORY', image_info.obsname, 'This is a simulation'
  sxaddpar, header, 'INSTRUMENT', camera_ID, 'This camera is SIMULATED in this image.'
  sxaddpar, header, 'EXPTIME', string(exposure_time), 'This is the SIMULATED exposure time.'
  writefits, strcompress('OUTPUT/LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all), image_16bit, header

  ;--- write an 8-bit 'realistic image' to a JPG file
  image_8bit = bytscl(image_16bit)
  write_jpeg, strcompress('OUTPUT/LunarImg_'+string(iframe,format='(I4.4)')+'.jpg',/remove_all), congrid(image_8bit,imsize,imsize), quality=80

  ;--- write image info to file
  openw,1,strcompress('OUTPUT/LunarImg_'+string(iframe,format='(I4.4)')+'.info',/rem)
  writeu,1,image_info
  close,1

  iframe = iframe + 1

endfor




END
