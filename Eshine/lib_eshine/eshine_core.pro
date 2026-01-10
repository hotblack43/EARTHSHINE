
;===============================================================================
;
; PRO eshine_core
;
; A code to generate simulated images of the Moon as seen from Earth. The
; Moon is illuminated by Sunshine and Earthshine, where the Earthshine is
; caused by reflection off the Earth.
;
; The viewing geometry, the lunar librations, and the Sun-Earth-Moon distances
; can be set from an ephemeris.
;
; The final image is returned in two versions: image_16bit (an 'ideal' image,
; scaled to simulate a well-exposed 16-bit CCD but stored as floating point)
; and image_I (an 'ideal' image of the Moon's radiance, stored as floating point
; numbers).
;
; Version 16
;
; Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute
;
;===============================================================================


PRO eshine_core, JD, phase_angle, lat_lib, lon_lib, PA_lib,                 $
                 obsname, obssys, Xobs_in, Yobs_in, Zobs_in,                $
                 moon_albedo, moon_BRDF, earth_albedo, earth_BRDF, datalib, $
                 camera_ID, CCDcols, CCDrows, pixelscale,                   $
                 if_filter, filterfact,                                     $
                 if_sky, skylevel,                                          $
                 if_CCDeffects, exptime,                                    $
                 if_librate, if_variable_distances,                         $
                 image_I, image_16bit, image_info


;-----------------------------------------------------------------------
; Set various constants.
;-----------------------------------------------------------------------
RADEG  = 180.0/!PI
DRADEG = 180.0D/!DPI


;-----------------------------------------------------------------------
; Assign image arrays:  image       - work space
;                       image_I     - 'ideal image'
;                       image_16bit - 'ideal image' but scaled to 16 bits
;-----------------------------------------------------------------------
image       = dblarr(CCDcols,CCDrows) * 0.0d0
image_I     = dblarr(CCDcols,CCDrows) * 0.0d0
image_16bit = dblarr(CCDcols,CCDrows) * 0.0d0




;===============================================================================
;=                                                                             =
;=  1. Sun-Earth-Moon geometry incl. libration.                                =
;=     Observer's location.                                                    =
;=     Matrixes to go between coordinate systems.                              =
;=                                                                             =
;===============================================================================

t1 = systime(/seconds)

;------------------------------------------------------------------------
; Moon's and Sun's equatorial coordinates
; Earth-Moon distance
; Sun-Earth distance
; phase angles (elongations)
; Moon's illumination
;------------------------------------------------------------------------
JD = double(JD)
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
Dem = 384400.0D     ; default Earth-Moon distance [km]
if (JD GT 0.0d) then begin
  moonpos, JD, RAmoon, DECmoon, Dem
  sunpos, JD, RAsun, DECsun
  xyz, JD-2400000.0, Xs, Ys, Zs, equinox=2000
  if (if_variable_distances EQ 1) then begin
    Dse = sqrt(Xs^2 + Ys^2 + Zs^2)*AU
    Dem = Dem
  endif else begin
    Dse = AU
    Dem = 384400.0d
  endelse
endif else begin
  RAmoon  = double(phase_angle)
  DECmoon = 0.0d
  RAsun   = 0.0d
  DECsun  = 0.0d
endelse
RAdiff = RAmoon - RAsun
sign = +1
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
illum_frac = (1 + cos(phase_angle_M/DRADEG))/2.0


;--------------------------------------------------------
; Calculate the LHA at Greenwich for the vernal equinox.
; This is used to compute the GEO transformation matrixes.
;--------------------------------------------------------
if (JD GT 0.0) then begin
  ct2lst, LST, 0.0, 0, JD
  GHAaries = 15.0D*LST
endif else begin
  GHAaries = double(phase_angle)
endelse


;------------------------------------------------
; Calculate Moon's libration from the Julian Date.
;------------------------------------------------
if (JD GT 0.0 AND if_librate EQ 1) then begin
  SunMoon_ephemerid, JD, RAs, DECs, DISTs, RAm, DECm, DISTm, lat_lib, lon_lib, PA_lib
endif else begin
  lat_lib = 0.0
  lon_lib = 0.0
  PA_lib  = 0.0
endelse


;------------------------------------------------------
; Transformation matrixes amongst MEEQ, EQ, SEL and GEO.
;------------------------------------------------------
ROTmeeq2sel  = CalcTransformMatrix('meeq2sel',  lat_lib, lon_lib, PA_lib, 0.0, 0.0, 0.0)
ROTsel2meeq  = CalcTransformMatrix('sel2meeq',  lat_lib, lon_lib, PA_lib, 0.0, 0.0, 0.0)
ROTmeeq2eq   = CalcTransformMatrix('meeq2eq',  DECmoon, RAmoon, 0.0, Dem, 0.0, 0.0)
ROTeq2meeq   = CalcTransformMatrix('eq2meeq',  DECmoon, RAmoon, 0.0, Dem, 0.0, 0.0)
ROTgeo2eq    = CalcTransformMatrix('geo2eq',  0.0, GHAaries, 0.0, 0.0, 0.0, 0.0)
ROTeq2geo    = CalcTransformMatrix('eq2geo',  0.0, GHAaries, 0.0, 0.0, 0.0, 0.0)
ROTmeeq2geo  = CalcTransformMatrix('meeq2eq',  DECmoon, RAmoon-GHAaries, 0.0, Dem, 0.0, 0.0)
ROTgeo2meeq  = CalcTransformMatrix('eq2meeq',  DECmoon, RAmoon-GHAaries, 0.0, Dem, 0.0, 0.0)

; print, 'LIB: ', lat_lib, lon_lib, PA_lib
; poleSEL = [0.0, 0.0, Rmoon]
; zeroSEL = [Rmoon, 0.0, 0.0]
; print, 'poleSEL  = ', poleSEL[0], poleSEL[1], poleSEL[2]
; print, 'zeroSEL  = ', zeroSEL[0], zeroSEL[1], zeroSEL[2]
; poleMEEQ = ROTsel2meeq ## poleSEL
; zeroMEEQ = ROTsel2meeq ## zeroSEL
; print, 'poleMEEQ = ', poleMEEQ[0], poleMEEQ[1], poleMEEQ[2]
; print, 'zeroMEEQ = ', zeroMEEQ[0], zeroMEEQ[1], zeroMEEQ[2]
; print, ' '
; print, 'PA = ', !RADEG*atan(poleMEEQ[1]/poleMEEQ[2])
; poleSEL = ROTmeeq2sel ## poleMEEQ
; zeroSEL = ROTmeeq2sel ## zeroMEEQ
; print, 'poleSEL  = ', poleSEL[0], poleSEL[1], poleSEL[2]
; print, 'zeroSEL  = ', zeroSEL[0], zeroSEL[1], zeroSEL[2]


;--------------------------------------------------------
; Airmass for the Moon.
;--------------------------------------------------------
if strcmp(obssys,'GEO',/fold_case) AND NOT strcmp(obsname,'Earth''s center',/fold_case) AND NOT strcmp(obsname,'DMI',/fold_case) then begin
  observatory, obsname, obs
  am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, obs.latitude*!dtor, obs.longitude*!dtor)
endif else if strcmp(obsname,'DMI',/fold_case) then begin
  am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, 55.60*!dtor, 347.30*!dtor)
endif else begin
  am = 0.0
endelse


;---------------------------------------------
; Observer's location in MEEQ coordinates [km].
;---------------------------------------------
if (if_variable_distances EQ 1) then begin
  if strcmp(obssys,'MEEQ',/fold_case) then begin
    Xobs = double(Xobs_in)
    Yobs = double(Yobs_in)
    Zobs = double(Zobs_in)
  endif else if strcmp(obssys,'GEO',/fold_case) then begin
    XYZ_MEEQ = ROTgeo2meeq ## [[Xobs_in],[Yobs_in],[Zobs_in],[1]]
    Xobs = XYZ_MEEQ[0]
    Yobs = XYZ_MEEQ[1]
    Zobs = XYZ_MEEQ[2]
    ; print, Xobs, Yobs, Zobs
    ; GHAmoon = GHAaries - RAmoon
    ; LHAmoon = GHAmoon + atan(Yobs_in/Xobs_in)*DRADEG
    ; Xobs = Dem - Rearth*cos(LHAmoon*!dtor)*cos(DECmoon*!dtor)
    ; Yobs = Rearth*sin(LHAmoon*!dtor)
    ; Zobs = Rearth*cos(LHAmoon*!dtor)*sin(DECmoon*!dtor)
    ; print, LHAmoon, DECmoon
    ; print, Xobs, Yobs, Zobs
  endif else begin
    stop, 'ERROR: observer''s location given in unknown coordinates.'
  endelse
endif else begin
  Xobs = double(Dem)
  Yobs = double(0.0)
  Zobs = double(0.0)
endelse


;-------------------------------------------
; More transformation matrixes:  MEEQ<->IMEQ
;-------------------------------------------
ROTmeeq2imeq = CalcTransformMatrix('meeq2imeq', 0.0, 0.0, 0.0, Xobs, Yobs, Zobs)
ROTimeq2meeq = CalcTransformMatrix('imeq2meeq', 0.0, 0.0, 0.0, Xobs, Yobs, Zobs)


;-------------------------
; Directional unit vectors
;-------------------------
earthpos_EQ = [0.0 , 0.0 , 0.0]
moonpos_EQ  = Dem*[cos(DECmoon/DRADEG)*cos(RAmoon/DRADEG) , cos(DECmoon/DRADEG)*sin(RAmoon/DRADEG) , sin(DECmoon/DRADEG)]
sunpos_EQ   = Dse*[cos(DECsun/DRADEG)*cos(RAsun/DRADEG) , cos(DECsun/DRADEG)*sin(RAsun/DRADEG) , sin(DECsun/DRADEG)]
earthpos_MEEQ = [Dem , 0.0 , 0.0]
moonpos_MEEQ  = [0.0 , 0.0 , 0.0]
sunpos_MEEQ   = ROTeq2meeq ## [[sunpos_EQ[0]],[sunpos_EQ[1]],[sunpos_EQ[2]],[1]]
sunpos_MEEQ   = sunpos_MEEQ[0:2]
;
earth2moondir_EQ = moonpos_EQ/Dem
earth2sundir_EQ  = sunpos_EQ/Dse
moon2sundir_MEEQ   = sunpos_MEEQ[0:2]/sqrt(sunpos_MEEQ[0]^2+sunpos_MEEQ[1]^2+sunpos_MEEQ[2]^2)
moon2earthdir_MEEQ = [1.0 , 0.0 , 0.0]
earth2sundir_MEEQ  = (sunpos_MEEQ - earthpos_MEEQ) / norm(sunpos_MEEQ-earthpos_MEEQ,/double)
observdir = [Xobs , Yobs , Zobs] / sqrt(Xobs^2+Yobs^2+Zobs^2)




;===============================================================================
;=                                                                             =
;=  2.1 Reflection properties of Earth and Moon.                               =
;=                                                                             =
;===============================================================================

t2 = systime(/seconds)

;-----------------------------------------------------------------------
; Moon reflectivity:
; given in terms of normal albedo PNORM, i.e. the reflectivity at the
; standard viewing geometry (phi=i=30, e=0)
;-----------------------------------------------------------------------
if (moon_albedo EQ 0) then begin
  ; 0 -> uniform reflectivity 0.0720
  PNORMmoon = fltarr(1080,540) + 0.0720
endif else if (moon_albedo EQ 1) then begin
  ; 1 -> Clementine/HIRES 750 nm reflectivity
  X = read_ascii(datalib+'/'+'HIRES_750_3ppd.alb',data_start=0)
  PNORMmoon = float(X.field0001)
  ; Nbins = 300
  ; hist = histogram(REFLmoon,min=0.0,max=0.30,nbins=Nbins)
  ; plot, (0.30/299.0)*findgen(Nbins), hist, xrange=[0.0,0.30], yrange=[0,15000], xstyle=1, ystyle=1, thick=2.0, xtitle='normalized reflectivity', ytitle='number of pixels', title='distribution of normalized reflectivity', charsize=1.4, charthick=1.2
  ; stop
endif


;-----------------------------------------------------------------------
; Earth reflectivity:
; given in terms of hemispheric albedo RHO
;-----------------------------------------------------------------------
if (earth_albedo EQ 0) then begin
  ; 0 -> uniform albedo 0.300
  RHOearth = fltarr(360,180) + 0.300
endif else if (earth_albedo EQ 1) then begin
  ; 1 -> cloud-free Earth
  X = read_ascii(datalib+'/'+'Earth.1d.map',data_start=0)
  indx0 = where(X.field001 EQ 0,count0)   ; water
  indx1 = where(X.field001 EQ 1,count1)   ; ice
  indx2 = where(X.field001 EQ 2,count2)   ; land
  indx3 = where(X.field001 EQ 3,count3)   ; land
  indx4 = where(X.field001 EQ 4,count4)   ; land
  indx5 = where(X.field001 EQ 5,count5)   ; land
  indx6 = where(X.field001 EQ 6,count6)   ; land
  indx7 = where(X.field001 EQ 7,count7)   ; ice
  indx  = where(X.field001 LT 0 OR X.field001 GT 7, count)
  if (count GT 0) then stop,'ERROR: in the input file Earth.1d.map'
  RHOearth = fltarr(360,180)
  if (count0 GT 0) then RHOearth[indx0] = 0.100   ; water
  if (count1 GT 0) then RHOearth[indx1] = 0.900   ; ice
  if (count2 GT 0) then RHOearth[indx2] = 0.650   ; land
  if (count3 GT 0) then RHOearth[indx3] = 0.650   ; land
  if (count4 GT 0) then RHOearth[indx4] = 0.650   ; land
  if (count5 GT 0) then RHOearth[indx5] = 0.650   ; land
  if (count6 GT 0) then RHOearth[indx6] = 0.650   ; land
  if (count7 GT 0) then RHOearth[indx7] = 0.900   ; ice
endif else if (earth_albedo EQ 2) then begin
  ; 2 -> time-varying but spatially uniform albedo
  RHOearth = fltarr(360,180) + 0.300 + 0.03*sin(JD/1.0d0*2.0*!pi)
  print,' JD, ALBearth:', JD, mean(RHOearth)
endif


;-----------------------------------------------------------------------
; Moon BRDF parameters:
; Get the parameter OMEGA from the normal albedo PNORM.
; The relation between these two depend on the type of BRDF assumed.
;-----------------------------------------------------------------------
if (moon_BRDF EQ 0) then begin
  ; 0 -> Lambert
  OMEGAmoon = PNORMmoon/(cos(30/DRADEG)/!DPI)
endif else if (moon_BRDF EQ 1) then begin
  ; 1 -> Hapke -63
  B = 2.0 - (tan(30/DRADEG)/(2*0.6)) * (1.0 - exp(-0.6/tan(30/DRADEG))) * (3.0 - exp(-0.6/tan(30/DRADEG)))
  S = (2.0/(3*!DPI)) * ( (sin(30/DRADEG) + (!DPI-30/DRADEG)*cos(30/DRADEG))/!DPI + 0.1*(1.0 - 0.5*cos(30/DRADEG))^2 )
  g30 = B*S  ; 0.228068
  LS30 = cos(30/DRADEG) / (cos(30/DRADEG) + cos(0.0/DRADEG))   ; 0.464102
  OMEGAmoon = PNORMmoon/(g30*LS30)
endif


;-----------------------------------------------------------------------
; Earth BRDF parameters
; Get the single-scattering albedo OMEGA from the hemispheric albedo RHO.
; The relation between these two depend on the type of BRDF assumed.
;-----------------------------------------------------------------------
if (earth_BRDF EQ 0) then begin
  ; 0 -> Lambert (uniform)
  BRDFearth = intarr(360,180)
  OMEGAearth  = RHOearth
endif else if (earth_BRDF EQ 1) then begin
  ; 1 -> Hapke-type BRDFs for a cloud-free Earth according to Ford et al.
  X = read_ascii(datalib+'/'+'Earth.1d.map',data_start=0)
  BRDFearth = fix(X.field001)
endif




;===============================================================================
;=                                                                             =
;=  2.2 Topographic shadowing of the sunshine.                                 =
;=                                                                             =
;===============================================================================


;---------------------------------------------
; Moon's topography from Clementine/LIDAR data.
;---------------------------------------------
; X = read_ascii(datalib+'\'+'clem_topogrid2.dat',data_start=0)
; TOPOmoon = X.field0001




;===============================================================================
;=                                                                             =
;=  2.3 Sunshine incident on the Earth-Moon system.                            =
;=                                                                             =
;===============================================================================


;------------------------------------------------
; Compute the sunshine incident on Earth and Moon.
;------------------------------------------------
Isun_1AU = 1368.0
Isun     = Isun_1AU*(AU/Dse)^2




;===============================================================================
;=                                                                             =
;=  3. For a given Sun-Earth-Moon geometry, determine the sunshine             =
;=     reflected off the Earth in the direction of the Moon. This              =
;=     reflected light forms the earthshine incident on the Moon.              =
;=                                                                             =
;===============================================================================

t3 = systime(/seconds)

;--------------------------------------------
; Compute the earthshine incident on the Moon.
; Work in equatorial (EQ) coordinates.
;--------------------------------------------
Iearth = 0.0d

for idec=0,179 do begin
for ira=0,359 do begin

  ; position on Earth in equatorial declination and right ascension, and in geographic lat and long
  dec = double(idec-89.5)
  ra  = double(ira+0.5)
  lat = dec
  lon = ra - GHAaries
  ilat = idec
  ilon = floor((lon+360) MOD 360)

  ; surface normal and area (m2) of the grid box (in EQ)
  surfnormal = [1.0*cos(ra/DRADEG)*cos(dec/DRADEG) , 1.0*sin(ra/DRADEG)*cos(dec/DRADEG) , 1.0*sin(dec/DRADEG)]
  surfarea = cos(dec/DRADEG) * (Rearth*1000.0D)^2 * (1.0/DRADEG) * (1.0/DRADEG)

  ; direction to the Sun (in EQ)
  sundir = earth2sundir_EQ

  ; direction to the Moon (in EQ)
  ; moondir = [cos((phase_angle_E)/DRADEG) , sin((phase_angle_E)/DRADEG) , 0.0]
  moondir = earth2moondir_EQ

  ; get AoI and AoR from scalar products with the surface normal
  AoI = acos(surfnormal##transpose(sundir))
  AoR = acos(surfnormal##transpose(moondir))
  phi = acos(sundir##transpose(moondir))

  ; BRDF for the sunshine incident on the Earth
  if (BRDFearth[ilon,ilat] EQ 0) then begin
    ;--- Lambert ---
    if (AoI LE !DPI/2) AND (AoR LE !DPI/2) then begin
      BRDFse = OMEGAearth[ilon,ilat]/!DPI
    endif else begin
      BRDFse = 0.0
    endelse
  endif else begin
    stop,'ERROR: only Lambert reflection has been implemented for Earth.'
  endelse

  Iearth = Iearth + BRDFse*Isun*cos(AoI)*surfarea*cos(AoR)*1.0/(Dem*Dem*1.0e6)

endfor
endfor

Iearth = Iearth[0]

print, 'Isun, Iearth = ', Isun, Iearth




;===============================================================================
;=                                                                             =
;=  4. Form the image pixel by pixel by adding the contributions from the      =
;=     Moon and any other light in the field of view. Each pixel collects      =
;=     light in a certain direction, and the light sources contributing        =
;=     to the pixel value are found by a simple form of ray tracing.           =
;=                                                                             =
;===============================================================================

t4 = systime(/seconds)

;----------------------------------------------------------------------------
; For each pixel, compute the incident light.
; Each pixel receives light from a certain solid angle in a certain direction.
;----------------------------------------------------------------------------
; Nabox_lon = intarr(CCDcols,CCDrows) * 0
; Nabox_lat = intarr(CCDcols,CCDrows) * 0

; subpixel positions with respect to pixel center
; Nsubpix = 9
; dy = pixelscale*[1,0,-1,1,0,-1,1,0,-1]/(3600.0*DRADEG*3.0)
; dz = pixelscale*[1,1,1,0,0,0,-1,-1,-1]/(3600.0*DRADEG*3.0)
Nsubpix = 25
dy = pixelscale*[2,1,0,-1,-2,2,1,0,-1,-2,2,1,0,-1,-2,2,1,0,-1,-2,2,1,0,-1,-2]/(3600.0*DRADEG*5.0)
dz = pixelscale*[2,2,2,2,2,1,1,1,1,1,0,0,0,0,0,-1,-1,-1,-1,-1,-2,-2,-2,-2,-2]/(3600.0*DRADEG*5.0)

limb = Rmoon^2 / ((Xobs^2+Yobs^2+Zobs^2) - Rmoon^2)

for iy=0,CCDcols-1 do begin
for iz=0,CCDrows-1 do begin

  ; pixel locations in radians - measured from image center: Y=left, Z=up
  im_y = pixelscale*((double(iy)-(CCDcols-1)/2.0d)/3600.0)/DRADEG
  im_z = pixelscale*((double(iz)-(CCDrows-1)/2.0d)/3600.0)/DRADEG

  ; check whether pixel {iy,iz} maps to the Moon
  mu2  = tan(im_y)^2 + tan(im_z)^2
  if (mu2 LT limb) then begin
    hitMoon = 1
  endif else begin
    hitMoon = 0
  endelse

  ; if the ray from the center of pixel {iy,iz} hits the Moon
  if hitMoon then begin

    ; mapping of pixels onto lunar surface in IMEQ coordinates,
    HL = (1.0D/(double(1.0)+mu2)) * ( Rmoon^2 - (Xobs^2+Yobs^2+Zobs^2)*mu2/(double(1.0)+mu2) )
    t = sqrt(Xobs^2+Yobs^2+Zobs^2)/(double(1.0)+mu2) - sqrt(HL)
    xIMEQ = t
    yIMEQ = t*tan(-im_y)
    zIMEQ = t*tan(im_z)

    ; conversion from IMEQ to MEEQ coordinates
    xyzMEEQ = ROTimeq2meeq ## [[xIMEQ],[yIMEQ],[zIMEQ],[1]]
    xMEEQ = xyzMEEQ[0]
    yMEEQ = xyzMEEQ[1]
    zMEEQ = xyzMEEQ[2]
    ; xMEEQ = Dem - t
    ; yMEEQ = t*tan(im_y)
    ; zMEEQ = t*tan(im_z)
    rMEEQ = sqrt(xMEEQ^2 + yMEEQ^2 + zMEEQ^2)
    latMEEQ = DRADEG*atan(zMEEQ/sqrt(xMEEQ^2 + yMEEQ^2))
    lonMEEQ = DRADEG*atan(yMEEQ,xMEEQ)

    ; conversion from MEEQ to SEL coordinates
    xyzSEL = ROTmeeq2sel ## [[xMEEQ],[yMEEQ],[zMEEQ]]
    xSEL = xyzSEL[0]
    ySEL = xyzSEL[1]
    zSEL = xyzSEL[2]
    rSEL = sqrt(xSEL^2 + ySEL^2 + zSEL^2)
    latSEL = DRADEG*atan(zSEL/sqrt(xSEL^2 + ySEL^2))
    lonSEL = DRADEG*atan(ySEL,xSEL)
    if (rMEEQ-rSEL) GT 0.0001 then stop,'ERROR: in conversion between MEEQ and SEL.'

    ; lunar surface normal (in MEEQ)
    surfnormal = [1.0*cos(lonMEEQ/DRADEG)*cos(latMEEQ/DRADEG) , 1.0*sin(lonMEEQ/DRADEG)*cos(latMEEQ/DRADEG) , 1.0*sin(latMEEQ/DRADEG)]

    ; direction to the sun (in MEEQ)
    ; sundir = [cos(phase_angle_M/DRADEG) , sin(phase_angle_M/DRADEG) , 0.0]
    ; sundir = moon2sundir_MEEQ

    ; direction to the earth (in MEEQ)
    ; earthdir = moon2earthdir_MEEQ

    ; direction to the observer (in MEEQ)
    ; observdir = [Xobs , Yobs , Zobs] / sqrt(Xobs^2+Yobs^2+Zobs^2)

    ; get AoIs, AoIe, and AoR from scalar products with the lunar surface normal
    AoIs = acos(surfnormal##transpose(moon2sundir_MEEQ))
    AoIe = acos(surfnormal##transpose(moon2earthdir_MEEQ))
    AoR  = acos(surfnormal##transpose(observdir))
    phi  = abs( acos(moon2sundir_MEEQ##transpose(observdir)) )

    ;--- compute an average over a pixel by the use of subpixels
    mu2  = tan(im_y+dy)^2 + tan(im_z+dz)^2
    hitMoon_subpix = (mu2 LT limb)
    indx = where(hitMoon_subpix EQ 1,count)
    HL = (1.0D/(double(1.0)+mu2[indx])) * ( Rmoon^2 - (Xobs^2+Yobs^2+Zobs^2)*mu2[indx]/(double(1.0)+mu2[indx]) )
    t = sqrt(Xobs^2+Yobs^2+Zobs^2)/(double(1.0)+mu2[indx]) - sqrt(HL)
    xIMEQ = t
    yIMEQ = t*tan(-(im_y+dy[indx]))
    zIMEQ = t*tan(im_z+dz[indx])
    ;
    ones = dblarr(count) + 1.0d
    xyzMEEQ = ROTimeq2meeq ## [[xIMEQ],[yIMEQ],[zIMEQ],[ones]]
    xMEEQ = xyzMEEQ[*,0]
    yMEEQ = xyzMEEQ[*,1]
    zMEEQ = xyzMEEQ[*,2]
    xyzSEL = ROTmeeq2sel ## [[xMEEQ],[yMEEQ],[zMEEQ]]
    xSEL = xyzSEL[*,0]
    ySEL = xyzSEL[*,1]
    zSEL = xyzSEL[*,2]
    latSEL = DRADEG*atan(zSEL/sqrt(xSEL^2 + ySEL^2))
    lonSEL = DRADEG*atan(ySEL,xSEL)
    ;
    ii = floor(3*(latSEL+90.0))
    jj = floor(3*((360.0+lonSEL) MOD 360))
    OMEGA = (float(count)/float(Nsubpix)) * mean(OMEGAmoon[jj,ii])
    ;
    ; ilat_min = floor(3*(min([latSEL])+90.0))
    ; ilat_max = floor(3*(max([latSEL])+90.0))
    ; ilon_min = floor(3*(min([lonSEL])+360.0))
    ; ilon_max = floor(3*(max([lonSEL])+360.0))
    ; Nlats = ilat_max - ilat_min + 1
    ; Nlons = ilon_max - ilon_min + 1
    ; ilat_indx = (ilat_min + indgen(Nlats)) ## (intarr(Nlons)+1)
    ; ilon_indx = ((ilon_min + indgen(Nlons)) MOD 1080) # (intarr(Nlats)+1)
    ; ilat_indx = reform(ilat_indx,Nlats*Nlons,/overwrite)
    ; ilon_indx = reform(ilon_indx,Nlats*Nlons,/overwrite)
    ; OMEGA = (float(count)/float(Nsubpix)) * mean(OMEGAmoon[ilon_indx,ilat_indx])
    ;
    ; ii = intarr(count)
    ; jj = intarr(count)
    ; for isubpix=0,count-1 do begin
    ;   xyzMEEQ = ROTimeq2meeq ## [[xIMEQ[isubpix]],[yIMEQ[isubpix]],[zIMEQ[isubpix]],[1.0d]]
    ;   xMEEQ = xyzMEEQ[0]
    ;   yMEEQ = xyzMEEQ[1]
    ;   zMEEQ = xyzMEEQ[2]
    ;   xyzSEL = ROTmeeq2sel ## [[xMEEQ],[yMEEQ],[zMEEQ]]
    ;   xSEL = xyzSEL[0]
    ;   ySEL = xyzSEL[1]
    ;   zSEL = xyzSEL[2]
    ;   latSEL = DRADEG*atan(zSEL/sqrt(xSEL^2 + ySEL^2))
    ;   lonSEL = DRADEG*atan(ySEL,xSEL)
    ;   ii[isubpix] = floor(3*(latSEL+90.0))
    ;   jj[isubpix] = floor(3*((360.0+lonSEL) MOD 360))
    ; endfor
    ; OMEGA = (float(count)/float(Nsubpix)) * mean(OMEGAmoon[jj,ii])

    ;--- compute an approximate average over a pixel by direct computation of the
    ;--- width of the pixel in SEL latitudes and longitudes
    ; res0 = 360.0*xIMEQ*tan(pixelscale/(3600.0*DRADEG)) / (2*!DPI*Rmoon)
    ; dlat = (res0/cos(AoR))*cos(lonSEL/DRADEG)
    ; dlon = res0/cos(AoR)
    ; Nabox_lat = max([1,round(dlat/0.3333333D)])
    ; Nabox_lon = max([1,round(dlon/0.3333333D)])
    ; ; Nabox_lat = 1
    ; ; Nabox_lon = 1
    ; ;
    ; ii = floor(3*(latSEL+90.0))
    ; jj = floor(3*((360.0+lonSEL) MOD 360))
    ; if Nabox_lon GE 5 then begin
    ;   jj = [jj-2,jj-1,jj,(jj+1) MOD 1080,(jj+2) MOD 1080]
    ; endif else if Nabox_lon GE 2 then begin
    ;   jj = [jj-1,jj,(jj+1) MOD 1080]
    ; endif
    ; ii_min = max([ii-Nabox_lat/2,0])
    ; ii_max = min([ii+Nabox_lat/2,539])
    ; OMEGA = mean(OMEGAmoon[jj,ii_min:ii_max])

    ; Hapke -63 phase function for the sunshine incident on the Moon
    g = 0.6
    if (phi EQ 0.0D) then begin
      B = 2.0
    endif else if (phi GT 0.0D AND phi LT (!DPI/2.0-0.00001)) then begin
      B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
    endif else if (phi GE (!DPI/2.0-0.00001)) then begin
      B = 1.0
    endif
    t = 0.1
    S = (2.0/(3*!DPI)) * ( (sin(phi) + (!DPI-phi)*cos(phi))/!DPI + t*(1.0 - 0.5*cos(phi))^2 )
    fphHapke63 = B*S

    ; BRDF for the sunshine incident on the Moon and reflected in the direction of the observer
    if (moon_BRDF EQ 0) then begin
      ; Lambert
      if (AoIs LE !DPI/2) AND (AoR LE !DPI/2) then begin
        BRDFsm = OMEGA/!DPI
      endif else begin
        BRDFsm = 0.0
      endelse
    endif else if (moon_BRDF EQ 1) then begin
      ; Hapke -63
      if (AoIs LT !DPI/2) AND (AoR LT !DPI/2) then begin
        BRDFsm =  OMEGA * fphHapke63 * 1.0/(cos(AoIs)+cos(AoR))
      endif else begin
        BRDFsm = 0.0
      endelse
    endif

    ; BRDF for the earthshine incident on the Moon and reflected in the direction of the observer
    if (moon_BRDF EQ 0) then begin
      ; Lambert
      if (AoIe LE !DPI/2) AND (AoR LE !DPI/2) then begin
        BRDFem = OMEGA/!DPI
      endif else begin
        BRDFem = 0.0
      endelse
    endif else if (moon_BRDF EQ 1) then begin
      ; Hapke -63
      if (AoIe LT !DPI/2) AND (AoR LT !DPI/2) then begin
        BRDFem =  OMEGA * 2.0 * 0.2372 * 1.0/(cos(AoIe)+cos(AoR))
      endif else begin
        BRDFem = 0.0
      endelse
    endif

    ; form the image by adding the two components of the moonshine
    image[iy,iz] = double(BRDFsm*Isun*cos(AoIs)) + double(BRDFem*Iearth*cos(AoIe))

  endif

endfor
endfor

indx = where(image LT 0.0d,count)
if (count GT 0) then stop,'ERROR: ray-tracing produced negative intensities.'




;===============================================================================
;=                                                                             =
;=  5. Two versions of the image are generated:                                =
;=                                                                             =
;=        image_I      -  the actual radiances from the Moon, without sky,     =
;=                        filter effects, Poisson noise, or CCD effects.       =
;=                                                                             =
;=        image_16bit  -  the detected radiances, degraded by the effects      =
;=                        above, scaled to simulate a well-exposed 16 bit      =
;=                        frame.                                               =
;=                                                                             =
;===============================================================================

t5 = systime(/seconds)

;-----------------------------------------------------------------------
; The 'ideal' image of the object
;-----------------------------------------------------------------------
image_I = image


;-----------------------------------------------------------------------
; Scale to 90% of 16 bits.
;-----------------------------------------------------------------------
maxval = 0.90*65535.0d0
image = maxval*image/max(image)


;-----------------------------------------------------------------------
; Store the final 16 bit 'ideal' image.
;-----------------------------------------------------------------------
image_16bit = image




;===============================================================================
;=                                                                             =
;=  6. Gather image information.                                               =
;=                                                                             =
;===============================================================================

t6 = systime(/seconds)

;-----------------------------------
; Create the image information array.
;-----------------------------------
Nchars = strlen(obsname)
if (Nchars LT 15) then begin
  fill = ''
  for ii=Nchars,15-1 do fill = fill + ' '
endif

image_info = {info, JD:JD,                                                                        $
                    obsname:obsname+fill, Xobs:Xobs, Yobs:Yobs, Zobs:Zobs,                        $
                    camera_ID:camera_ID, CCDcols:CCDcols, CCDrows:CCDrows, pixelscale:pixelscale, $
                    exptime:exptime,                                                              $
                    RAmoon:RAmoon, DECmoon:DECmoon, Dem:Dem,                                      $
                    RAsun:RAsun, DECsun:DECsun, Dse:Dse,                                          $
                    lat_lib:lat_lib, lon_lib:lon_lib, PA_lib:PA_lib,                              $
                    phase_angle_E:phase_angle_E, phase_angle_M:phase_angle_M,                     $
                    Isun:Isun, Iearth:Iearth }




print, '1: ' + string(t2-t1,format='(F6.2)') + ' s'
print, '2: ' + string(t3-t2,format='(F6.2)') + ' s'
print, '3: ' + string(t4-t3,format='(F6.2)') + ' s'
print, '4: ' + string(t5-t4,format='(F6.2)') + ' s'
print, '5: ' + string(t6-t5,format='(F6.2)') + ' s'




END
