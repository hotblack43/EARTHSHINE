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
; Version 16
;
; Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute
;
;===============================================================================


PRO eshine_16

common phases,phase_angle_M, phase_angle_E
common E_albedo,single_scattering


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
JD = 2455769.0908d0
;phase_angle = 0.0
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
; coordinates should be specified as well.
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
  obslon = obs.longitude
  obslat = obs.latitude
  obsalt = obs.altitude
endelse
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
moon_albedo  = 1     ; 0=0.0720 (uniform) , 1=Clementine/HIRES 750 nm albedos
moon_BRDF    = 1     ; 0=Lambert (uniform), 1=Hapke -63 (uniform)
earth_albedo = 0     ; 0=0.3000 (uniform),  1=cloud-free Earth
single_scattering = 1.0; 0.303 ; used only if earth_albedo = 0
earth_BRDF   = 0     ; 0=Lambert (uniform)
; datalib='/home/pth/SCIENCEPROJECTS/EARTHSHINE/Eshine/data_eshine'
; datalib = 'C:/EarthShine/Simulations/data_eshine'
; datalib ='C:\Documents and Settings\Daddyo\Skrivebord\ASTRO\Eshine\data_eshine'
datalib='./Eshine/data_eshine'


;-----------------------------------------------------------------------
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
;device_str = 'win'
device_str = 'X'
; device_str = 'ps'


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
JDstart = JD
JDend   = JD 
JDstep  =  1./24.0d0/4.
for iJD = JDstart,JDend,JDstep do begin

;PRO eshine_core, JD, phase_angle, lat_lib, lon_lib, PA_lib,                 $
;                 obsname, obssys, Xobs_in, Yobs_in, Zobs_in,                $
;                 moon_albedo, moon_BRDF, earth_albedo, earth_albedo_uniform_value, $
;                 earth_BRDF, datalib, imsize, pixelscale,                   $
;                 if_moon_visible, if_librate, if_variable_distances,        $
;                 image_I, image_16bit, image_info


  ;--- simulate the lunar observation
  eshine_core, iJD, phase_angle, lat_lib, lon_lib, PA_lib, $
               obsname, obssys, Xobs, Yobs, Zobs, $
               moon_albedo, moon_BRDF, earth_albedo, dummyholder, earth_BRDF, datalib, $
               imsize, pixelscale, $
               if_moon_visible, if_librate, if_variable_distances, $
               image_I, image_16bit, image_info

  ; perform very simple photometry on ideal image
; get_pixel_ratio,image_I,ratio
 ratio=-911
  print,format='(a,3(1x,d20.10))',' iJD,phase_angle_E,ratio = ',iJD,phase_angle_E,ratio
  printf,83,format='(a,3(1x,d20.10))',' iJD,phase_angle_E,ratio = ',iJD,phase_angle_E,ratio

  ;--- add sky background and a half-filter
   add_telescope_and_filter_effects, image_16bit, filter, image_info.phase_angle_E, imsize, $
                                     filterfact, skylevel, if_sky

  ;--- add CCD effects
  if (if_CCDeffects eq 1) then begin
    generate_CCD, image_16bit, iframe, camera_ID,exposure_time, CCD_out, raw_CCD
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
  sxaddpar, header, 'JULIAN',string(double(IJD),format='(d20.8)'), ' JULIAN DAY'
  sxaddpar, header, 'Mphase',string(double(phase_angle_M),format='(d20.8)'), ' Moon phase angle'
  sxaddpar, header, 'DATE-OBS', datestring, 'Simulated date'
  sxaddpar, header, 'TIME-OBS', UTtimestring, 'Simulated time (UT)'
  sxaddpar, header, 'OBSERVATORY', image_info.obsname, 'This is a simulation'
  sxaddpar, header, 'INSTRUMENT', 'IDEALIZED', 'NO camera is simulated in this image.'
  writefits, strcompress('OUTPUT/IDEAL/ideal_LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all), image_I, header
	print,'Wrote to OUTPUT/IDEAL/'

  ;--- write the 16-bit 'realistic image' to a FITS file
  MKHDR, header, image_16bit
  caldat, iJD, mm, dd, yy, hh, mnt, sec
  convert_to_strings, mm, dd, yy, hh, mnt, sec, secstring, datestring, UTtimestring
  sxaddpar, header, 'JULIAN',string(double(IJD),format='(d20.8)'), ' JULIAN DAY'
  sxaddpar, header, 'TIME-OBS', UTtimestring, 'Simulated time (UT)'
  sxaddpar, header, 'OBSERVATORY', image_info.obsname, 'This is a simulation'
  sxaddpar, header, 'INSTRUMENT', camera_ID, 'This camera is SIMULATED in this image.'
  sxaddpar, header, 'EXPTIME', string(exposure_time), 'This is the SIMULATED exposure time.'
  writefits, strcompress('OUTPUT/LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all), image_16bit, header
	print,'Wrote to OUTPUT/'

  ;--- write an 8-bit 'realistic image' to a JPG file
  image_8bit = bytscl(image_16bit)
  write_jpeg, strcompress('OUTPUT/JPEGS/LunarImg_'+string(iframe,format='(I4.4)')+'.jpg',/remove_all), congrid(image_8bit,imsize,imsize), quality=80

  ;--- write image info to file
  openw,1,strcompress('OUTPUT/INFO/LunarImg_'+string(iframe,format='(I4.4)')+'.info',/rem)
  writeu,1,image_info
  printf,1,image_info
  close,1

  iframe = iframe + 1

endfor

close,83


END
