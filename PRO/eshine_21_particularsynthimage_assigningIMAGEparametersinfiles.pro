;===============================================================================
; ESHINE SIMULATION SIMPLE USER INTERFACE
;
; Assemble the following information and run the simulation:
;
; - Julian date or phase angle + libration parameters.
; - Observer's location
; - Moon BRDFs
; - Earth BRDFs
; - Sky background
; - Camera properties and settings
; - CCD effects
; - Filter effects
; - Poisson or not
; - Run mode
;
; Version 21b
;
; like Version 21 but the user can assign such things as plate scale and image dimensions in input files
;
; Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute
;
;===============================================================================


PRO eshine_21_particularsynthimage_assigningIMAGEparametersinfiles
common phases, phase_angle_M, phase_angle_E

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
JD = 2456003.1602996d0
; or read JD from a file
filnavn=get_data('usethisJD')
JD=filnavn(0)
print,format='(a,1x,f15.7)','I am being told JD=',JD
; lat_lib = 0.0
; lon_lib = 0.0
; PA_lib  = 0.0
; .... or give phase angle and libration parameters explicitly (and set JD=-1.0)
;JD = -1.0
;phase_angle = 150.0   ; at Earth
; lat_lib = 0.0
; lon_lib = 0.0
; PA_lib  = 0.0
;-----------------------------------------------------------------------
; Moon reflectance specifications.
;
; The geometric albedo, Ag, is the albedo at zero phase angle
; relative to a Lambertian disc of the same size.
;
; The normal albedo, Rn, is the "reflectance factor", REFF=pi*BRDF,
; at a standard viewing geometry: phi=i=30, e=0.
;
; (1) Specify BRDF:
;
;     100: Lambert              (uniform surface, default: Ag=0.1248)
;     200: Lommel-Seeliger      (uniform surface, default: Ag=0.1248)
;     300: Hapke-63             (uniform surface, default: Ag=0.1248)
;     400: Hapke-X              (uniform surface, default: Ag=0.1248)
;     500: HapkeMare            (uniform surface, default: Ag=0.1248)
;     600: HapkeHigh            (uniform surface, default: Ag=0.1248)
;
;     301: Hapke-63             (Rn from HIRES 750 basemap)
;     302: Hapke-63             (Rn from UVVIS 750 basemap)
;     303: Hapke-63             (Rn from LRO colourmap)
;     401: Hapke-X              (Rn from HIRES 750 basemap)
;     402: Hapke-X              (Rn from UVVIS 750 basemap)
;     403: Hapke-X              (Rn from LRO colourmap)
;
;     311: Hapke-63, Lambert    (BRDF mix, Rn from HIRES 750 basemap)
;     312: Hapke-63, Lambert    (BRDF mix, Rn from UVVIS 750 basemap)
;
;     561: HapkeMare, HapkeHigh (BRDF mix from the HIRES 750 basemap, Rn from the BRDF)
;     562: HapkeMare, HapkeHigh (BRDF mix from the UVVIS 750 basemap, Rn from the BRDF)
;     563: HapkeMare, HapkeHigh (BRDF mix from the HIRES 750 basemap, Rn from the HIRES 750 basemap)
;     564: HapkeMare, HapkeHigh (BRDF mix from the UVVIS 750 basemap, Rn from the UVVIS 750 basemap)
;
; (2) For a uniform Moon, optionally specify the normal albedo Rn.
;     This gives the single-scattering albedo, w0, of the BRDF.
;     Default (when moon_albedo<0) is geometric albedo Ag=0.1248.
;
; (3) For BRDF=311 and 312, specify the mixing ratio: 0.0<= mix <= 1.0
;
;-----------------------------------------------------------------------
;if (userswitch314 eq 1 and albedoswitch eq 1) then moon_BRDF    = 301 ; use Hapke-63 (see above) with HIRES (scale in core)
;if (userswitch314 eq 1 and albedoswitch eq 2) then moon_BRDF    = 302 ; use Hapke-63 (see above) with UVVIS
;if (userswitch314 eq 1 and albedoswitch eq 3) then moon_BRDF    = 303 ; use Hapke-63 (see above) with LRO
;if (userswitch314 eq 2 and albedoswitch eq 1) then moon_BRDF    = 401 ; use Hapke-X (see above) with HIRES (scale in core)
;if (userswitch314 eq 2 and albedoswitch eq 2) then moon_BRDF    = 402 ; use Hapke-X (see above) with UVVIS
;if (userswitch314 eq 2 and albedoswitch eq 3) then moon_BRDF    = 403 ; use Hapke-X (see above) with LRO

moon_BRDF=fix((get_data('moon_BRDF.txt'))(0))
print,'I read moon_BRDF: ',moon_BRDF
earth_BRDF=fix((get_data('earth_BRDF.txt'))(0))
print,'I read earth_BRDF: ',earth_BRDF

moon_albedo  = -1.0
moon_mix     = -1.0


;-----------------------------------------------------------------------
; Earth reflectance specifications.
;
; (1) Specify BRDF:
;
;     100: Lambert              (uniform surface, default: As=0.300)
;     200: Lommel-Seeliger      (uniform surface, default: As=0.300)
;
;     101: Lambert              (w0 from the Ford et al. map)
;     102: Lambert              (uniform surface, 1% time-variation, default; <As>=0.300)
;
; (2) For uniform Earth, optionally specify the Bond albedo As.
;     This gives the single-scattering albedo, w0, of the BRDF.
;     Default (when earth_albedo<0) is Bond albedo As=0.300.
;
;-----------------------------------------------------------------------
;earth_BRDF   = 100
earth_albedo = -1.0
  dummy=get_data('single_scattering_albedo.dat')
  single_scattering = dummy(0)
;earth_BRDF   = 100
;earth_BRDF   = 200
earth_albedo = single_scattering
print,'Read in earth_albedo: ',earth_albedo

; datalib='/home/pth/SCIENCEPROJECTS/EARTHSHINE/Eshine/data_eshine'
; datalib = 'C:/EarthShine/Simulations/data_eshine'
; datalib ='C:\Documents and Settings\Daddyo\Skrivebord\ASTRO\Eshine\data_eshine'
datalib='./Eshine/data_eshine'


;-----------------------------------------------------------------------
; Various options
;-----------------------------------------------------------------------
if_librate  = 1  ; =1 to enable an ephemeris-based libration calculation
if_varidist = 1  ; =1 to enable ephemeris-driven distances

;-----------------------------------------------------------------------
; Specify a valid observatory name. If 'MEEQ  X,Y,Z' then the MEEQ
; coordinates should be specified as well.
;-----------------------------------------------------------------------
;obsname='Earth''s center'
obsname = 'mlo'
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
  obslon = -obs.longitude
  obslat = obs.latitude
  obsalt = obs.altitude
endelse

if strcmp(obssys,'GEO',/fold_case) then begin
  arg1=6365.0+obsalt/1000.0 ; to speed up calculation
  arg2=obslat*!DPI/180.0D   ; ...
  arg3=obslon*!DPI/180.0D   ; ...
  arg4=cos(arg2)
  Xobs = (arg1)*arg4*cos(arg3)
  Yobs = (arg1)*arg4*sin(arg3)
  Zobs = (arg1)*sin(arg2)
endif

print,'obsname,lon,lat: ',obsname,obslon,obslat
openw,38,'observatory.dat'
printf,38,obsname,obslon,obslat
close,38


;-----------------------------------------------------------------------
; Sky and CCD effects
;-----------------------------------------------------------------------
if_sky   = 0
skylevel = 10.0       ; must be balanced against the 'raw image flux levels'


;-----------------------------------------------------------------------
; Image size & pixel scale
;-----------------------------------------------------------------------
;CCDsize = 512     ; number of pixels - square CCD
CCDsize=(get_data('file_CCDsize.dat'))(0)
CCDfactor = 1                   ; a factor to change both imsize and pixelscale
imsize = fix(CCDsize/CCDfactor) ; image size in terms of pixels
platescale=(get_data('file_platescale.dat'))(0)
pixelscale = platescale*CCDfactor      ; arc seconds per pixel. Our telescope has 6.7"/pixel
;pixelscale = 6.67*CCDfactor      ; arc seconds per pixel. Our telescope has 6.7"/pixel


;-----------------------------------------------------------------------
; Filters
;-----------------------------------------------------------------------
filter = 0                ; half-filter / no half-filter
filterfact = 10000        ; filter factor


;-----------------------------------------------------------------------
; CCD effects
;-----------------------------------------------------------------------
if_CCDeffects = 0


;-----------------------------------------------------------------------
; Simulated camera settings
;-----------------------------------------------------------------------
; camera_ID = 'sxvh9'
; camera_ID = 'STL1001E'
camera_ID = 'eshine_21_particularsynthimage_assigningIMAGEparametersinfiles'
exposure_time = 0.15


;-----------------------------------------------------------------------
; Set the graphics device to 'win', 'X', or 'ps'
;-----------------------------------------------------------------------
if_show = 0               ; see the image of the Moon on screen
device_str = 'win'
device_str = 'X'
device_str = 'ps'


;-----------------------------------------------------------------------
; Make simulation
;-----------------------------------------------------------------------
iframe = 0

openw,83,'photometry.dat'

JDstart = JD
JDend   = JDstart
JDstep  = 1.0d0

for iJD = JDstart,JDend,JDstep do begin

  ;--- simulate the lunar observation
  JD = double(iJD)
  print,format='(a,1x,f15.7)','In the loop of eshine_21 we have iJD=',iJD
  eshine_core_21, JD, phase_angle, lat_lib, lon_lib, PA_lib,             $
                  obsname, obssys, Xobs, Yobs, Zobs,                     $
                  moon_BRDF, moon_albedo, mix, earth_BRDF, earth_albedo, $
                  datalib,                                               $
                  if_librate, if_varidist,                               $
                  imsize, pixelscale,                                    $
                  image_I, image_16bit, image_info, mask,                $
                  MAPofEARTH


  ; perform very simple photometry on ideal image
  ; get_pixel_ratio,image_I,ratio
  ratio=-911
  print,format='(a,3(1x,d20.10),2x,f10.1)',' iJD,phase_angle_E,ratio = ',iJD,phase_angle_E,ratio,total(image_I)
  printf,83,format='(a,3(1x,d20.10),2x,f10.1)',' iJD,phase_angle_E,ratio = ',iJD,phase_angle_E,ratio,total(image_I)

  ;--- add sky background and a half-filter
  ;add_telescope_and_filter_effects, image_16bit, filter, image_info.phase_angle_E, imsize,  filterfact, skylevel, if_sky

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
  MKHDR, hedr, image_I
  caldat, iJD, mm, dd, yy, hh, mnt, sec
  convert_to_strings, mm, dd, yy, hh, mnt, sec, secstring, datestring, UTtimestring

  sxaddpar, hedr, 'DATE-OBS', datestring, 'Simulated date'
  sxaddpar, hedr, 'TIME-OBS', UTtimestring, 'Simulated time (UT)'
  sxaddpar, hedr, 'JULIAN',string(double(IJD),format='(d20.8)'), ' JULIAN DAY'
  sxaddpar, hedr, 'Mphase',string(double(phase_angle_M),format='(d20.8)'), ' Moon phase angle'
  sxaddpar, hedr, 'OBSERVATORY', image_info.obsname, 'This is a simulation'
  sxaddpar, hedr, 'EXPTIME', string(exposure_time), 'This is the SIMULATED exposure time.'
  sxaddpar, hedr, 'INSTRUMENT', camera_ID, 'IDL code used to generate image.'
  sxaddpar, hedr, 'moon_BRDF', moon_BRDF, 'Type of lunar BRDF model'
  sxaddpar, hedr, 'libration', if_librate, 'Is libration on or off?'
  sxaddpar, hedr, 'vardist', if_varidist, 'Is variable E-M distance on or off?'
  sxaddpar, hedr, 'earth_BRDF', earth_BRDF, 'Type of terrestrial BRDF model'
  sxaddpar, hedr, 'ALBEDO', single_scattering, 'Single scattering albedo used on Earth model.'

  writefits, strcompress('OUTPUT/IDEAL/ideal_LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all), image_I, hedr
  SCAnumstr=string(single_scattering,format='(f6.3)')
  s=string(single_scattering,format='(f6.3)')
  strput,s,'p',2
  SCAnumstr=s
  JDnumstr=string(JD,format="(f20.6)")
  writefits, strcompress('OUTPUT/IDEAL/ideal_LunarImg_SCA_'+SCAnumstr+'_JD_'+JDnumstr+'.fit',/remove_all), image_I, hedr
    print,'image_I - MIN ne 0:',min(image_I(where(image_I ne 0)))
    print,'Wrote to OUTPUT/IDEAL/'

  ;--- write the 16-bit 'realistic image' to a FITS file
  MKHDR, hedr, image_16bit
  caldat, iJD, mm, dd, yy, hh, mnt, sec
  convert_to_strings, mm, dd, yy, hh, mnt, sec, secstring, datestring, UTtimestring

  sxaddpar, hedr, 'DATE-OBS', datestring, 'Simulated date'
  sxaddpar, hedr, 'TIME-OBS', UTtimestring, 'Simulated time (UT)'
  sxaddpar, hedr, 'JULIAN',string(double(IJD),format='(d20.8)'), ' JULIAN DAY'
  sxaddpar, hedr, 'Mphase',string(double(phase_angle_M),format='(d20.8)'), ' Moon phase angle'
  sxaddpar, hedr, 'OBSERVATORY', image_info.obsname, 'This is a simulation'
  sxaddpar, hedr, 'EXPTIME', string(exposure_time), 'This is the SIMULATED exposure time.'
  sxaddpar, hedr, 'INSTRUMENT', camera_ID, 'IDL code used to generate image.'
  sxaddpar, hedr, 'moon_BRDF', moon_BRDF, 'Type of lunar BRDF model'
  sxaddpar, hedr, 'libration', if_librate, 'Is libration on or off?'
  sxaddpar, hedr, 'vardist', if_varidist, 'Is variable E-M distance on or off?'
  sxaddpar, hedr, 'earth_BRDF', earth_BRDF, 'Type of terrestrial BRDF model'
  sxaddpar, hedr, 'ALBEDO', single_scattering, 'Single scattering albedo used on Earth model.'

  writefits, strcompress('OUTPUT/LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all), image_I/max(image_I)*60000.0d0, hedr
  writefits, strcompress('OUTPUT/SunMask_LunarImg_'+string(iframe,format='(I4.4)')+'.fit',/remove_all), mask
    print,'image_16bit - MIN ne 0:',min(image_16bit(where(image_16bit ne 0)))
    print,'Wrote to OUTPUT/'

  ;--- write an 8-bit 'realistic image' to a JPG file
  image_8bit = bytscl(image_16bit)
  write_jpeg, strcompress('OUTPUT/JPEGS/LunarImg_'+string(iframe,format='(I4.4)')+'.jpg',/remove_all), congrid(image_8bit,imsize,imsize), quality=80
  write_jpeg, strcompress('OUTPUT/JPEGS/MAPofEARTH_'+string(iframe,format='(I4.4)')+'.jpg',/remove_all), bytscl(MAPofEARTH), quality=100

  ;--- write image info to file
  openw,1,strcompress('OUTPUT/INFO/LunarImg_'+string(iframe,format='(I4.4)')+'.info',/rem)
  writeu,1,image_info
  printf,1,image_info
  close,1

  writefits, 'ItellYOUwantTHISimage.fits', image_I*1.0d0, hedr

  iframe = iframe + 1

endfor

close,83

; some info:

print,'if_librate ',if_librate
print,'if_varidist ',if_varidist
print,'Observatory name : ',obsname
print,'JD start:',JDstart


END
