
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
; Version 14
;
;===============================================================================


PRO eshine_14


common camera_information,exposure_time,camera_ID,phase_angle_E

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
; JD = -1.0
; phase_angle = 180.0
; lat_lib = 0.0
; lon_lib = 0.0
; PA_lib  = 0.0


;-----------------------------------------------------------------------
; Observatory
;-----------------------------------------------------------------------
obsname = 'MSO'
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
CCDfactor = 2           ; a factor to change the CCD size and pixelscale
filter = 0                ; half-filter / no half-filter
filterfact = 10000        ; filter factor
;-----------------------------------------------------------------------
; Set various factors describing image size
;-----------------------------------------------------------------------
pixelscale  = 3.5*CCDfactor         ; arc seconds per pixel (small factor => small pixels)
imsize = fix(CCDsize/CCDfactor) ; image size in terms of pixels (small factor => more pixels)
;-----------------------------------------------------------------------
; Degrading effects
;-----------------------------------------------------------------------
if_poisson    = 0	; should be left at 0 from now on (OMIT eventually)
if_sky        = 1
skylevel = 10	; must be balanced against the 'raw image flux levels'
if_CCDeffects = 1

;-----------------------------------------------------------------------
; Simulated camera settings
;-----------------------------------------------------------------------
exposure_time=0.15
;camera_ID='sxvh9'
camera_ID='STL1001E'

;-----------------------------------------------------------------------
; Set the graphics device to 'win', 'X', or 'ps'
;-----------------------------------------------------------------------
if_show = 0               ; see the image of the Moon on screen
device_str='win'
;device_str='X'
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
JDend   = JD + 2.d0
JDstep  =  1./24.
for iJD = JDstart,JDend,JDstep do begin

  print,format='(a,1x,d20.10)', 'JD = ', iJD

  ;--- simulate the lunar observation
  eshine_core, iJD, phase_angle, lat_lib, lon_lib, PA_lib, $
               obsname, obssys, Xobs, Yobs, Zobs, $
               moon_albedo, moon_BRDF, earth_albedo, earth_BRDF, $
           ;    CCDsize, CCDfactor, filter, filterfact, $
           ;    if_poisson, if_sky, if_CCDeffects, $
               if_moon_visible, if_librate, if_variable_distances, $
               image, image_16bit, image_info, iframe, $
               pixelscale, imsize

;---add realstic effects such as a sky background, a half-filter

 add_telescope_and_filter_effects,image_16bit,filter,phase_angle_E,imsize, $
	filterfact, skylevel, if_sky

;---add CCD effects if desired
if (if_CCDeffects eq 1) then begin
  generate_CCD,image_16bit,iframe,camera_ID,exposure_time,CCD_out,raw_CCD
  image_16bit = UINT(CCD_out)
endif

  ;--- show image on screen

  if (if_show EQ 1) AND (device_str NE 'ps') then begin
    window, 0, xpos=0, ypos=0, xsize=imsize, ysize=imsize
    tvscl, image_16bit
  endif

  ;--- write 16-bit image to FITS or TIFF files, or an 8-bit image to a JPEG file
       MKHDR, header, image_16bit
        caldat,ijd,mm,dd,yy,hh,min,sec
	convert_to_strings,mm,dd,yy,hh,min,sec,secstring,datestring,UTtimestring
       sxaddpar, header, 'TIME-OBS',UTtimestring,'Simulated time (UT)'
       sxaddpar, header, 'OBSERVATORY',obsname,'This is a simulation'
       sxaddpar, header, 'INSTRUMENT',camera_ID,'This camera is SIMULATED in this image.'
       sxaddpar, header, 'EXPTIME',string(exposure_time),'This is the SIMULATED exposure time.'

  writefits, strcompress('OUTPUT/LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all), image_16bit,header

; write the floating point 'ideal image' to disk
       MKHDR, header, image
        caldat,ijd,mm,dd,yy,hh,min,sec
	convert_to_strings,mm,dd,yy,hh,min,sec,secstring,datestring,UTtimestring
       sxaddpar, header, 'DATE-OBS',datestring,'Simulated date'
       sxaddpar, header, 'TIME-OBS',UTtimestring,'Simulated time (UT)'
       sxaddpar, header, 'OBSERVATORY',obsname,'This is a simulation'
       sxaddpar, header, 'INSTRUMENT','IDEALIZED','NO camera is simulated in this image.'
  writefits, strcompress('OUTPUT/ideal_LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all), image,header

; also generate a JPG version (OMIT?)
  image_8bit = bytscl(image_16bit)
  write_jpeg, strcompress('OUTPUT/JPEGS/LunarImg_'+string(iframe,format='(I4.4)')+'.jpg',/remove_all), congrid(image_8bit,imsize,imsize), quality=80

  iframe = iframe + 1

endfor




END
