;===============================================================================
 ;
 ; PRO eshine_core_21
 ;
 ; A code to generate simulated images of the Moon as seen from Earth. The
 ; Moon is illuminated by Sunshine and Earthshine, where the Earthshine is
 ; caused by reflection off the Earth.
 ;
 ; The viewing geometry, the lunar librations, and the Sun-Earth-Moon distances
 ; can be set from an ephemeris.
 ;
 ; The generated image is 'ideal' i.e. there are no sky, noise or CCD effects.
 ;
 ; The final image is returned in three versions: image_16bit (the ideal image
 ; stored as floating point, but scaled to simulate a well-exposed 16-bit frame),
 ; image_I (the same, but without scaling), and mask (the ideal image, but
 ; only with sunshine).
 ;
 ; Also returns a map of the Earth showing which regions that contribute to the
 ; earthshine.
 ;
 ; Version 21.3 Allows choice of HIRES Clementine albedo map - scaled or unscaled to Wiley
 ;              and UVVIS (unscaled only), or LRO colour-dependent albedomaps
 ;
 ; Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute
 ;
 ;===============================================================================
 
 
 PRO eshine_core_21, JD, phase_angle, lat_lib, lon_lib, PA_lib,             $
 obsname, obssys, Xobs_in, Yobs_in, Zobs_in,            $
 moon_BRDF, moon_albedo, mix, earth_BRDF, earth_albedo, $
 datalib,                                               $
 if_librate, if_varidist,                               $
 imsize, pixelscale,                                    $
 image_I, image_16bit, image_info, mask,                $
 MAPofEARTH
 
 print,"This is eshine_core_21.pro  ***********************"
 ; Read the filter string
 get_lun,hgjfrte
 openr,hgjfrte,'FILTER.txt'
 filter_str=''
 readf,hgjfrte,filter_str
 close,hgjfrte
 free_lun,hgjfrte
 
 
 ;===============================================================================
 ;
 ; 0. Constants, subroutines, and allocation of arrays.
 ;
 ;===============================================================================
 
 ;-----------------------------------------------------------------------
 ; Modules containing constants and subroutines.
 ;-----------------------------------------------------------------------
 es_constants
 es_geometry
 es_reflection
 
 common Constants, Rearth, Rmoon, AU, meanDse, meanDem, Isun_1AU, pi, RADEG, DRADEG, deg2rad
 
 common phases, phase_angle_M, phase_angle_E
 
 forward_function getPhaseAngleAtEarth, getPhaseAngleAtMoon
 forward_function Lambert, LommelSeeliger, Hapke63, HapkeX, Hapke63_Lambert, $
 HapkeHillierM, HapkeHillierH, HapkeKennellyM1, HapkeKennellyH1
 
 
 ;-----------------------------------------------------------------------
 ; Assign arrays:  image       - work space
 ;                 image_I     - 'ideal image'
 ;                 image_16bit - 'ideal image' but scaled to 16 bits
 ;                 mask        - same as image_I, but without earthshine
 ;                 MAPofEARTH  - Earth map showing contributing areas
 ;-----------------------------------------------------------------------
 image       = dblarr(imsize,imsize) * 0.0d0
 image_I     = dblarr(imsize,imsize) * 0.0d0
 image_16bit = dblarr(imsize,imsize) * 0.0d0
 mask        = dblarr(imsize,imsize) * 0.0d0
 
 MAPofEARTH  = fltarr(360,180)
 
 
 
 
 ;===============================================================================
 ; 1. Reflection properties & orography of Earth and Moon.
 ;===============================================================================
 
 ;-----------------------------------------------------------------------
 ; 1.1 Moon reflectance specifications.
 ;
 ;     The geometric albedo, Ag, is the albedo at zero phase angle
 ;     relative to a Lambertian disc of the same size.
 ;
 ;     The normal albedo, Rn, is the "reflectance factor", REFF=pi*BRDF,
 ;     at a standard viewing geometry: phi=i=30, e=0.
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
 ;     403: Hapke-X              (Rn from LRO colour map)
 ; ......................................................................................
 ; The following are mysterious - do not use until understood
 ;
 ;     311: Hapke-63, Lambert    (BRDF mix, Rn from HIRES 750 basemap)
 ;     312: Hapke-63, Lambert    (BRDF mix, Rn from UVVIS 750 basemap)
 ;     313: Hapke-63, Lambert    (BRDF mix, Rn from LRO )  NOT IMPLEMENTED YET!!!!!
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
 ; (3) For BRDF=311 and 312, the mixing ratio is also specified: 0.0<= mix <= 1.0
 ;
 ;-----------------------------------------------------------------------
 print,'in eshine_core_21 - I have moon_BRDF= ',moon_BRDF
 print,'in eshine_core_21 - I have moon_BRDF mod 10 = ',(moon_BRDF mod 10) 
 print,'in eshine_core_21 - I have moon_BRDF mod 100= ',(moon_BRDF mod 100)
 print,'in eshine_core_21 - I have earth_BRDF= ',earth_BRDF
 ;--- Uniform Moon, default albedo
 if ((moon_BRDF MOD 100) EQ 0 AND moon_albedo LE 0.0d) then begin
     Ag = 0.1248d   ; default geometric albedo
     RNORMmoon = -1.0d + dblarr(1080,540)
     case (moon_BRDF) of
         100: OMEGAmoon = 1.5*Ag + dblarr(1080,540)
         200: OMEGAmoon = 8.0*Ag + dblarr(1080,540)
         300: OMEGAmoon = 0.1879*(Ag/0.1248d) + dblarr(1080,540)
         400: OMEGAmoon = 0.2379*(Ag/0.1248d) + dblarr(1080,540)
         500: OMEGAmoon = 0.3437*(Ag/0.1248d) + dblarr(1080,540)
         600: OMEGAmoon = 0.2887*(Ag/0.1248d) + dblarr(1080,540)
         endcase
     
     ;--- Uniform Moon, user specified albedo
     endif else if (moon_BRDF MOD 100) EQ 0 then begin
     RNORMmoon = moon_albedo + dblarr(1080,540)
print,'Only if you mean it!!!!'
stop
     case (moon_BRDF) of
         100: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*Lambert(1.0d, 30.0d/DRADEG, 0.0d))
         200: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*LommelSeeliger(1.0d, 30.0d/DRADEG, 0.0d))
         300: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*Hapke63(1.0d, 30.0d/DRADEG, 0.0d, 30.0d/DRADEG))
         400: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*HapkeX(30.0d/DRADEG, 0.0d, 30.0d/DRADEG, ssalbedo=1.0))
         500: stop, 'ERROR: not implemented yet'
         600: stop, 'ERROR: not implemented yet'
         endcase
     endif
 ;--- Non-uniform Moon albedo specified with either Clementine (2 versions) or LRO maps
 ifwantscaled=1
 ; first the HIRES maps
 if ((moon_BRDF MOD 10) EQ 1 and ifwantscaled ne 1) then begin
	print,'Setting up HIRES_750_3ppd.alb'
     X = read_ascii(datalib+'/'+'HIRES_750_3ppd.alb',data_start=0)
     RNORMmoon = double(X.field1)
     endif
 if ((moon_BRDF MOD 10) EQ 1 and ifwantscaled eq 1) then begin
     ; 1 -> Clementine/HIRES 750 nm reflectivity SCALED to conserve mean value and dampen SD to 90%
	print,'Setting up SPECIAL.HIRES_750_3ppd_scaled_to_WIldey.alb'
     X = read_ascii(datalib+'/'+'SPECIAL.HIRES_750_3ppd_scaled_to_WIldey.alb',data_start=0)
     RNORMmoon = double(X.field1)
     endif
 ; then the UVVIS maps - only unscaled is available
 if ((moon_BRDF MOD 10) EQ 2) then begin
	print,'Setting up UVVIS_750_3ppd.alb'
     X = read_ascii(datalib+'/'+'UVVIS_750_3ppd.alb',data_start=0)
     RNORMmoon = double(X.field1)
     endif
 if ((moon_BRDF MOD 10) EQ 3) then begin
     ; LRO colour-dependent maps
	print,'Setting up for LRO maps'
     if (filter_str eq 'B' or filter_str eq '_B_') then RNORMmoon=reform(readfits('Eshine/LRO_interpolated_B_464.fits'))
     if (filter_str eq 'V' or filter_str eq '_V_') then RNORMmoon=reform(readfits('Eshine/LRO_interpolated_V.fits'))
     if (filter_str eq 'VE1' or filter_str eq '_VE1_') then RNORMmoon=reform(readfits('Eshine/LRO_interpolated_VE1_569.fits'))
     if (filter_str eq 'VE2' or filter_str eq '_VE2_') then RNORMmoon=reform(readfits('Eshine/LRO_interpolated_VE2_742.fits'))
     if (filter_str eq 'IRCUT' or filter_str eq '_IRCUT_') then RNORMmoon=reform(readfits('Eshine/LRO_interpolated_IRCUT_560.fits'))
     endif
 if (moon_BRDF MOD 100) NE 0 then begin
     case (moon_BRDF) of
         301: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*Hapke63(1.0d, 30.0d/DRADEG, 0.0d, 30.0d/DRADEG))
         302: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*Hapke63(1.0d, 30.0d/DRADEG, 0.0d, 30.0d/DRADEG))
         303: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*Hapke63(1.0d, 30.0d/DRADEG, 0.0d, 30.0d/DRADEG))

         401: OMEGAmoon = RNORMmoon 
;        401: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*HapkeX(30.0d/DRADEG, 0.0d, 30.0d/DRADEG, ssalbedo=1.00))
         402: OMEGAmoon = RNORMmoon 
;        402: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*HapkeX(30.0d/DRADEG, 0.0d, 30.0d/DRADEG, ssalbedo=1.00))
         403: OMEGAmoon = RNORMmoon 
;        403: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*HapkeX(30.0d/DRADEG, 0.0d, 30.0d/DRADEG, ssalbedo=1.00))
         311: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*Hapke63_Lambert(1.0d, 30.0d/DRADEG, 0.0d, 30.0d/DRADEG, mix))
         312: OMEGAmoon = RNORMmoon / (cos(30.0d/DRADEG) * !dpi*Hapke63_Lambert(1.0d, 30.0d/DRADEG, 0.0d, 30.0d/DRADEG, mix))
         561: OMEGAmoon = 0.0d*dblarr(1080,540)  ; not used
         562: OMEGAmoon = 0.0d*dblarr(1080,540)  ; not used
         563: OMEGAmoon = 0.0d*dblarr(1080,540)  ; not used
         564: OMEGAmoon = 0.0d*dblarr(1080,540)  ; not used
         endcase
     endif

print,'mean RNORMOON OMEGAMOON: ',mean(RNORMmoon),mean(OMEGAmoon)

 ;-----------------------------------------------------------------------
 ; 1.2 Earth reflectance specifications.
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
 
 ;--- Uniform Earth
 if ((earth_BRDF MOD 100) EQ 0) then begin
     if (earth_albedo LT 0.0d) then begin
         ;if (earth_albedo LE 0.0d) then begin
         As = 0.300          ; default Bond albedo
         endif else begin
         As = earth_albedo   ; user specified Bond albedo
         endelse
     case (earth_BRDF) of
         100: OMEGAearth = As + dblarr(360,180)
         200: OMEGAearth = As*1.5d/(1.0d - alog(2.0d)) + dblarr(360,180)
         endcase
     endif
 
 ;--- Non-uniform Earth
 if (earth_BRDF EQ 101) then begin
     ;----
     ; I thought reading from a binary file would speed up the code - it appears it did not
     ; fetch_terrestrial_albedo_map,indx0,indx1,indx2,indx3,indx4,indx5,indx6,indx7,indx,    $
     ;      count0,count1,count2,count3,count4,count5,count6,count7,count
     ;----
     ;  X = read_ascii(datalib+'\'+'Earth.1d.map',data_start=0)
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
     OMEGAearth = fltarr(360,180)
     if (count0 GT 0) then OMEGAearth[indx0] = 0.100   ; water
     if (count1 GT 0) then OMEGAearth[indx1] = 0.900   ; ice
     if (count2 GT 0) then OMEGAearth[indx2] = 0.650   ; land
     if (count3 GT 0) then OMEGAearth[indx3] = 0.650   ; land
     if (count4 GT 0) then OMEGAearth[indx4] = 0.650   ; land
     if (count5 GT 0) then OMEGAearth[indx5] = 0.650   ; land
     if (count6 GT 0) then OMEGAearth[indx6] = 0.650   ; land
     if (count7 GT 0) then OMEGAearth[indx7] = 0.900   ; ice
     endif
 
 ;--- Uniform, time-varying Earth
 if (earth_BRDF EQ 102) then begin
     OMEGAearth = fltarr(360,180) + 0.300 + 0.03*sin(JD/1.0d0*2.0*!pi)
     print,' JD, ALBearth:', JD, mean(OMEGAearth)
     endif
 
 ;--- Flip the Earth map north to south, and shift 180 degrees in longitud.
 OMEGAearth = reverse(OMEGAearth,2)
 OMEGAearth = shift(OMEGAearth,180)
 
 
 ;-----------------------------------------------------------------------
 ; 1.3 Topographic shadowing of the sunshine.
 ;     Moon's topography from Clementine/LIDAR data.
 ;-----------------------------------------------------------------------
 ; X = read_ascii(datalib+'\'+'clem_topogrid2.dat',data_start=0)
 ; TOPOmoon = X.field1
 
 
 
 
 ;===============================================================================
 ; 2. Sun-Earth-Moon geometry incl. libration.
 ;    Observer's location.
 ;    Matrixes to go between coordinate systems.
 ;===============================================================================
 
 ;-----------------------------------------------------------------------
 ; - Earth's and Sun's equatorial (EQ) coordinates
 ; - Earth-Moon distance
 ; - Sun-Earth distance
 ; - Earth's and Moon's direction in space: GST (GHAaries) for the Earth
 ;   and libration parameters for the Moon.
 ;-----------------------------------------------------------------------
 JD = double(JD)
 
 ;--- if ephemeris
 if (JD GT 0.0d) then begin
     moonpos, JD, RAmoon, DECmoon, Dem
     sunpos, JD, RAsun, DECsun
     xyz, JD-2400000.0, Xs, Ys, Zs, equinox=2000
     if (if_varidist EQ 1) then begin
         Dse = sqrt(Xs^2 + Ys^2 + Zs^2)*AU
         Dem = Dem
         endif else begin
         Dse = meanDse
         Dem = meanDem
         endelse
     ct2lst, GHA, 0.0, 0, JD
     GHAaries = 15.0D*GHA
     if (if_librate EQ 1) then begin
         SunMoon_ephemerid, JD, RAs, DECs, DISTs, RAm, DECm, DISTm, lat_lib, lon_lib, PA_lib
         endif else begin
         lat_lib = 0.0d
         lon_lib = 0.0d
         PA_lib  = 0.0d
         endelse
     
     ;--- else if user specified coordinates
     endif else begin
     RAmoon   = double(phase_angle)
     DECmoon  = 0.0d
     RAsun    = 0.0d
     DECsun   = 0.0d
     Dse      = meanDse
     Dem      = meanDem
     GHAaries = 0.0d
     lat_lib  = 0.0d
     lon_lib  = 0.0d
     PA_lib   = 0.0d
     endelse
 
 
 ;-----------------------------------------------------------------------
 ; Phase angles at Earth and at Moon.
 ;-----------------------------------------------------------------------
 phase_angle_E = getPhaseAngleAtEarth(RAmoon, DECmoon, RAsun, DECsun)
 phase_angle_M = getPhaseAngleAtMoon(Dem, RAmoon, DECmoon, Dse, RAsun, DECsun)
 illum_frac = (1.0 + cos(phase_angle_M/DRADEG))/2.0
 
 
 ;-----------------------------------------------------------------------
 ; Transformation matrixes amongst MEEQ, EQ, SEL and GEO.
 ;-----------------------------------------------------------------------
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
 
 
 ;-----------------------------------------------------------------------
 ; Airmass for the Moon.
 ;-----------------------------------------------------------------------
 ;if strcmp(obssys,'GEO',/fold_case) AND NOT strcmp(obsname,'Earth''s center',/fold_case) AND NOT strcmp(obsname,'DMI',/fold_case) then begin
 ;  observatory, obsname, obs
 ;  am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, obs.latitude*!dtor, obs.longitude*!dtor)
 ;endif else if strcmp(obsname,'DMI',/fold_case) then begin
 ;  am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, 55.60*!dtor, 347.30*!dtor)
 ;endif else begin
 ;  am = 0.0
 ;endelse
 
 
 ;-----------------------------------------------------------------------
 ; Observer's location in MEEQ coordinates [km].
 ;-----------------------------------------------------------------------
 if (if_varidist EQ 1) then begin
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
 
 
 ;-----------------------------------------------------------------------
 ; More transformation matrixes:  MEEQ<->IMEQ
 ;-----------------------------------------------------------------------
 ROTmeeq2imeq = calctransformmatrix('meeq2imeq', 0.0, 0.0, 0.0, Xobs, Yobs, Zobs)
 ROTimeq2meeq = calctransformmatrix('imeq2meeq', 0.0, 0.0, 0.0, Xobs, Yobs, Zobs)
 
 
 ;-----------------------------------------------------------------------
 ; Positional vectors
 ;-----------------------------------------------------------------------
 earthpos_EQ   = [0.0d , 0.0d , 0.0d]
 moonpos_EQ    = Dem*[cos(DECmoon*deg2rad)*cos(RAmoon*deg2rad), cos(DECmoon*deg2rad)*sin(RAmoon*deg2rad), sin(DECmoon*deg2rad)]
 sunpos_EQ     = Dse*[cos(DECsun*deg2rad)*cos(RAsun*deg2rad), cos(DECsun*deg2rad)*sin(RAsun*deg2rad), sin(DECsun*deg2rad)]
 
 earthpos_MEEQ = [Dem , 0.0 , 0.0]
 moonpos_MEEQ  = [0.0 , 0.0 , 0.0]
 sunpos_MEEQ   = ROTeq2meeq ## [[sunpos_EQ[0]],[sunpos_EQ[1]],[sunpos_EQ[2]],[1]]
 sunpos_MEEQ   = sunpos_MEEQ[0:2]
 
 
 ;-----------------------------------------------------------------------
 ; Unit directional vectors
 ;-----------------------------------------------------------------------
 earth2moondir_EQ   = moonpos_EQ/Dem
 earth2sundir_EQ    = sunpos_EQ/Dse
 moon2sundir_MEEQ   = sunpos_MEEQ[0:2]/sqrt(sunpos_MEEQ[0]^2+sunpos_MEEQ[1]^2+sunpos_MEEQ[2]^2)
 moon2earthdir_MEEQ = [1.0 , 0.0 , 0.0]
 earth2sundir_MEEQ  = (sunpos_MEEQ - earthpos_MEEQ) / norm(sunpos_MEEQ-earthpos_MEEQ,/double)
 observdir          = [Xobs , Yobs , Zobs] / sqrt(Xobs^2+Yobs^2+Zobs^2)
 
 
 
 
 ;===============================================================================
 ; 3. Sunshine incident on the Earth-Moon system.
 ;===============================================================================
 
 ;------------------------------------------------
 ; Compute the sunshine incident on Earth and Moon.
 ;------------------------------------------------
 Isun = Isun_1AU*(AU/Dse)^2
 
 
 
 
 ;===============================================================================
 ; 4. Determine the sunshine reflected off the Earth in the direction of the Moon.
 ;    This reflected light forms the earthshine incident on the Moon.
 ;===============================================================================
 
 ;--------------------------------------------
 ; Compute the earthshine incident on the Moon.
 ; Work in equatorial (EQ) coordinates.
 ;--------------------------------------------
 Iearth = 0.0d
 
 ; direction to the Sun (in EQ)
 sundir = earth2sundir_EQ
 
 ; direction to the Moon (in EQ)
 moondir = earth2moondir_EQ
 
 ; Sun-Earth-Moon phase angle
 phi = acos(sundir##transpose(moondir))
 
 for idec=0,179 do begin
     for ira=0,359 do begin
         
         ; position on Earth in equatorial declination and right ascension, and in geographic lat and long
         dec = double(idec-89.5)
         ra  = double(ira+0.5)
         lat = dec
         lon = ra - GHAaries
         ilat = idec
         ilon = floor((lon+360) MOD 360)
         
         ; lon = 180.0d0 - (ra - GHAaries)
         ; lon = ((lon + 360.0d0 + 180.0d0) MOD 360.0d0) - 180.0d0
         ; ilon = floor(lon) + 180
         ; if (ilon LT 0 OR ilon GT 359) then print, 'WARNING WARNING WARNING WARNING'
         
         ; surface normal and area (m2) of the grid box (in EQ)
         surfnormal = [1.0*cos(ra/DRADEG)*cos(dec/DRADEG) , 1.0*sin(ra/DRADEG)*cos(dec/DRADEG) , 1.0*sin(dec/DRADEG)]
         surfarea = cos(dec/DRADEG) * (Rearth*1000.0D)^2 * (1.0/DRADEG) * (1.0/DRADEG)
         
         ; get AoI and AoR from scalar products with the surface normal
         AoI = acos(surfnormal##transpose(sundir))
         AoR = acos(surfnormal##transpose(moondir))
         
         ;--- Grid boxes illuminated by the Sun, and seen from the Earth.
         if (AoI LE !DPI/2) AND (AoR LE !DPI/2) then begin
             OMEGA = OMEGAearth[ilon,ilat]
             endif else begin
             OMEGA = 0.0d
             endelse
         
         ;--- BRDF for the sunshine incident on the Earth.
         if (earth_BRDF EQ 100 OR earth_BRDF EQ 101 OR earth_BRDF EQ 102) then begin
             BRDFse = Lambert(OMEGA, AoI, AoR)
             endif else if (earth_BRDF EQ 200) then begin
             BRDFse = LommelSeeliger(OMEGA, AoI, AoR)
             endif else begin
             stop,'ERROR: invalid BRDF for Earth.'
             endelse
         
         ; Collect the contributions from all grid boxes:
         ; BRDF*(Esun)*(projected area of grid box)*(solid angle of a square meter) [W/m2]
         thing =  BRDFse * Isun*cos(AoI) * surfarea*cos(AoR) * 1.0d/(Dem*Dem*1.0d6)
         Iearth = Iearth + thing
         MAPofEARTH(ilon,ilat)=thing
         
         endfor
     endfor
 
 Iearth = Iearth[0]
 
 mphase,jd,k
 print,format='(a,f20.5,1x,2(f20.7,1x),2(f10.5,1x))', 'JD, Isun, Iearth, ph_M, ph_E = ', JD, Isun, Iearth, phase_angle_M, phase_angle_E
 
 
 
 
 ;===============================================================================
 ; 5. Form the image pixel by pixel by adding the contributions from the
 ;    Moon and any other light in the field of view. Each pixel collects
 ;    light in a certain direction, and the light sources contributing
 ;    to the pixel value are found by a simple form of ray tracing.
 ;===============================================================================
 
 ;----------------------------------------------------------------------------
 ; For each image pixel, compute the incident light.
 ; Each pixel receives light from a certain solid angle in a certain direction.
 ;----------------------------------------------------------------------------
 ; Nabox_lon = intarr(imsize,imsize) * 0
 ; Nabox_lat = intarr(imsize,imsize) * 0
 
 lonlatSELimage=fltarr(imsize,imsize,2)  ; array to hold lunar lon and lat
 theta_i_and_r_and_phi=fltarr(imsize,imsize,2)   ; array to hold theta_i and theta_r
help,imsize 
 for iy=-imsize/2,imsize/2 do begin
     for iz=-imsize/2,imsize/2 do begin
         
         ; pixel locations in radians - measured from image center: Y=left, Z=up
         im_y = pixelscale*(double(iy)/3600.0)/DRADEG
         im_z = pixelscale*(double(iz)/3600.0)/DRADEG
         
         ; mapping of pixels onto lunar surface in IMEQ coordinates,
         ; followed by conversion to MEEQ and SEL coordinates
         mu2  = tan(im_y)^2 + tan(im_z)^2
         limb = Rmoon^2 / ((Xobs^2+Yobs^2+Zobs^2) - Rmoon^2)
         if mu2 LT limb then begin
             hitMoon = 1
             HL = (1.0D/(double(1.0)+mu2)) * ( Rmoon^2 - (Xobs^2+Yobs^2+Zobs^2)*mu2/(double(1.0)+mu2) )
             t = sqrt(Xobs^2+Yobs^2+Zobs^2)/(double(1.0)+mu2) - sqrt(HL)
             xIMEQ = t
             yIMEQ = t*tan(-im_y)
             zIMEQ = t*tan(im_z)
             ;
             ; IMEQ to MEEQ coordinates
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
             ;
             ; MEEQ to SEL coordinates
             xyzSEL = ROTmeeq2sel ## [[xMEEQ],[yMEEQ],[zMEEQ]]
             xSEL = xyzSEL[0]
             ySEL = xyzSEL[1]
             zSEL = xyzSEL[2]
             rSEL = sqrt(xSEL^2 + ySEL^2 + zSEL^2)
             latSEL = DRADEG*atan(zSEL/sqrt(xSEL^2 + ySEL^2))
             lonSEL = DRADEG*atan(ySEL,xSEL)
             if (rMEEQ-rSEL) GT 0.0001 then stop,'ERROR: in conversion between MEEQ and SEL.'
             endif else begin
             hitMoon = 0
             latMEEQ = !VALUES.F_NaN
             lonMEEQ = !VALUES.F_NaN
             endelse
         
         ; generate map of selenographic coordinates
         if (iy+imsize/2 ge 0 and iy+imsize/2 lt imsize and iz+imsize/2 ge 0 and iz+imsize/2 lt imsize) then begin
             if(hitMoon) then begin
                 lonlatSELimage(iy+imsize/2, iz+imsize/2,0)=lonSEL
                 lonlatSELimage(iy+imsize/2,  iz+imsize/2,1)=latSEL
                 endif else begin
                 lonlatSELimage(iy+imsize/2, iz+imsize/2,0)=-999
                 lonlatSELimage(iy+imsize/2, iz+imsize/2,1)=-999
                 endelse
             endif
         
         
         ; if the ray from pixel {iy,iz} hits the Moon
         if hitMoon then begin
             
             ; lunar surface normal (in MEEQ)
             surfnormal    = [1.0*cos(lonMEEQ/DRADEG)*cos(latMEEQ/DRADEG) , 1.0*sin(lonMEEQ/DRADEG)*cos(latMEEQ/DRADEG) , 1.0*sin(latMEEQ/DRADEG)]
             surfarea_proj = (4.0*!dpi*Dem*Dem*1.0d6) * ((!dpi/180.0d)*pixelscale/3600.0d)^2/(4.0*!dpi)
             
             ; direction to the sun (in MEEQ)
             ; sundir = [cos(phase_angle_M/DRADEG) , sin(phase_angle_M/DRADEG) , 0.0]
             sundir = moon2sundir_MEEQ
             
             ; direction to the earth (in MEEQ)
             earthdir = [1.0 , 0.0 , 0.0]
             
             ; direction to the observer (in MEEQ)
             observdir = [Xobs , Yobs , Zobs] / sqrt(Xobs^2+Yobs^2+Zobs^2)
             
             ; get AoIs, AoIe, and AoR from scalar products with the lunar surface normal
             AoIs = acos(surfnormal##transpose(sundir))
             AoIe = acos(surfnormal##transpose(earthdir))
             AoR  = acos(surfnormal##transpose(observdir))
             phi  = abs( acos(sundir##transpose(observdir)) )
             phie = abs( acos(earthdir##transpose(observdir)) )
             
             ; approximate width of pixel in SEL latitudes and longitudes
             res0 = 360.0*xIMEQ*tan(pixelscale/(3600.0*DRADEG)) / (2*!DPI*Rmoon)
             dlat = (res0/cos(AoR))*cos(lonSEL/DRADEG)
             dlon = res0/cos(AoR)
             Nabox_lat = max([1,round(dlat/0.3333333D)])
             Nabox_lon = max([1,round(dlon/0.3333333D)])
             
             ; mean OMEGA within the pixel field of view
             ; Nabox_lat = 1
             ; Nabox_lon = 1
             ii = floor(3*(latSEL+90.0))
             jj = floor(3*((360.0+lonSEL) MOD 360))
             if Nabox_lon GE 5 then begin
                 jj = [jj-2,jj-1,jj,(jj+1) MOD 1080,(jj+2) MOD 1080]
                 endif else if Nabox_lon GE 2 then begin
                 jj = [jj-1,jj,(jj+1) MOD 1080]
                 endif
             ii_min = max([ii-Nabox_lat/2,0])
             ii_max = min([ii+Nabox_lat/2,539])
             RNORM = median(RNORMmoon[jj,ii_min:ii_max])
             OMEGA = min([1.0d,median(OMEGAmoon[jj,ii_min:ii_max])])
             ; OMEGA = min([1.0d,mean(OMEGAmoon[jj,ii_min:ii_max])])
             
             ; BRDF for the sunshine incident on the Moon and reflected in the direction of the observer
             if (moon_BRDF EQ 100) then begin
                 BRDFsm = Lambert(OMEGA, AoIs, AoR)
                 endif else if (moon_BRDF EQ 200) then begin
                 BRDFsm = LommelSeeliger(OMEGA, AoIs, AoR)
                 endif else if (moon_BRDF EQ 300 OR moon_BRDF EQ 301 OR moon_BRDF EQ 302 or moon_BRDF eq 303) then begin
                 BRDFsm = Hapke63(OMEGA, AoIs, AoR, phi)
                 endif else if (moon_BRDF EQ 400 OR moon_BRDF EQ 401 OR moon_BRDF EQ 402 or moon_BRDF eq 403) then begin
                 BRDFsm = HapkeX(AoIs, AoR, phi, ssalbedo=OMEGA)
                 endif else if (moon_BRDF EQ 500) then begin
                 color = 2
                 BRDFsm = HapkeKennellyM1(color, AoIs, AoR, phi, ssalbedo=OMEGA)
                 endif else if (moon_BRDF EQ 600) then begin
                 color = 2
                 BRDFsm = HapkeKennellyH1(color, AoIs, AoR, phi, ssalbedo=OMEGA)
                 endif else if (moon_BRDF EQ 311 OR moon_BRDF EQ 312) then begin
                 BRDFsm = Hapke63_Lambert(OMEGA, AoIs, AoR, phi, mix)
                 endif else if (moon_BRDF EQ 561 OR moon_BRDF EQ 562) then begin
                 mix = 1.0 - (RNORM - 0.05)/0.07
                 mix = max([mix,0.0])
                 mix = min([mix,1.0])
                 color = 2
                 BRDFsm = mix*HapkeKennellyM1(color, AoIs, AoR, phi) + (1.0-mix)*HapkeKennellyH1(color, AoIs, AoR, phi)
                 endif else if (moon_BRDF EQ 563 OR moon_BRDF EQ 564) then begin
                 mix = 1.0 - (RNORM - 0.05)/0.07
                 mix = max([mix,0.0])
                 mix = min([mix,1.0])
                 color = 2
                 normBRDF = mix*HapkeKennellyM1(color, 30.0d/DRADEG, 0.0d, 30.0d/DRADEG) + (1.0-mix)*HapkeKennellyH1(color, 30.0d/DRADEG, 0.0d, 30.0d/DRADEG)
                 factor = RNORM / (!dpi*cos(30.0d/DRADEG)*normBRDF)
                 BRDFsm = mix*HapkeKennellyM1(color, AoIs, AoR, phi, factor=factor) + (1.0-mix)*HapkeKennellyH1(color, AoIs, AoR, phi, factor=factor)
                 endif
             
             ; BRDF for the earthshine incident on the Moon and reflected in the direction of the observer
             if (moon_BRDF EQ 100) then begin
                 BRDFem = Lambert(OMEGA, AoIe, AoR)
                 endif else if (moon_BRDF EQ 200) then begin
                 BRDFem = LommelSeeliger(OMEGA, AoIe, AoR)
                 endif else if (moon_BRDF EQ 300 OR moon_BRDF EQ 301 OR moon_BRDF EQ 302 or moon_BRDF eq 303) then begin
                 BRDFem = Hapke63(OMEGA, AoIe, AoR, phie)
                 endif else if (moon_BRDF EQ 400 OR moon_BRDF EQ 401 OR moon_BRDF EQ 402 or moon_BRDF eq 403) then begin
                 BRDFem = HapkeX(AoIe, AoR, phie, ssalbedo=OMEGA)
                 endif else if (moon_BRDF EQ 500) then begin
                 color = 2
                 BRDFem = HapkeKennellyM1(color, AoIe, AoR, phie, ssalbedo=OMEGA)
                 endif else if (moon_BRDF EQ 600) then begin
                 color = 2
                 BRDFem = HapkeKennellyH1(color, AoIe, AoR, phie, ssalbedo=OMEGA)
                 endif else if (moon_BRDF EQ 311 OR moon_BRDF EQ 312) then begin
                 BRDFem = Hapke63_Lambert(OMEGA, AoIe, AoR, phie, mix)
                 endif else if (moon_BRDF EQ 561 OR moon_BRDF EQ 562) then begin
                 mix = 1.0 - (RNORM - 0.05)/0.07
                 mix = min([max([mix,0.0]),1.0])
                 color = 2
                 BRDFem = mix*HapkeKennellyM1(color, AoIe, AoR, phie) + (1.0-mix)*HapkeKennellyH1(color, AoIe, AoR, phie)
                 endif else if (moon_BRDF EQ 563 OR moon_BRDF EQ 564) then begin
                 mix = 1.0 - (RNORM - 0.05)/0.07
                 mix = min([max([mix,0.0]),1.0])
                 color = 2
                 normBRDF = mix*HapkeKennellyM1(color, 30.0d/DRADEG, 0.0d, 30.0d/DRADEG) + (1.0-mix)*HapkeKennellyH1(color, 30.0d/DRADEG, 0.0d, 30.0d/DRADEG)
                 factor = RNORM / (!dpi*cos(30.0d/DRADEG)*normBRDF)
                 BRDFem = mix*HapkeKennellyM1(color, AoIe, AoR, phie, factor=factor) + (1.0-mix)*HapkeKennellyH1(color, AoIe, AoR, phie, factor=factor)
                 endif
             
             ; Form the image by adding the two components of the moonshine.
             ; BRDF*(E)*(projected area of the part of the Moon visible within one pixel)*(solid angle of 1 m2) [W/m2/pixel]
             image[imsize/2+iy,imsize/2+iz] = (double(BRDFsm*Isun*cos(AoIs)) + double(BRDFem*Iearth*cos(AoIe))) * surfarea_proj * 1.0d/(Dem*Dem*1.0d6) ; [W/m2/pixel]
             ; Generate a 'mask' that contains only the sunlit part of the Moon.
             mask[imsize/2+iy,imsize/2+iz] = double(BRDFsm*Isun*cos(AoIs)) * surfarea_proj * 1.0d/(Dem*Dem*1.0d6)
             
             endif
         
         endfor
     endfor
 
 indx = where(image LT 0.0d,count)
 if (count GT 0) then stop,'ERROR: ray-tracing produced negative intensities.'
 
 Imoon = total(image_I)
 
 
;tvscl,image 
 
 
 ;===============================================================================
 ; 6. Store two versions of the generated image:
 ;
 ;      image_I      -  the actual radiances from the Moon, without sky, filters,
 ;                      Poisson noise, or CCD effects.
 ;      image_16bit  -  the same ideal image, still floating-point but now scaled
 ;                      to simulate a well-exposed 16-bit CCD frame
 ;===============================================================================
 
 ;-----------------------------------------------------------------------
 ; The 'ideal image' of the object
 ;-----------------------------------------------------------------------
 image_I = image
 
 
 ;-----------------------------------------------------------------------
 ; The 'ideal image' of the object, but scaled to 90% of 16 bits
 ;-----------------------------------------------------------------------
 maxval = 0.90*65535.0d0
 image_16bit = maxval*image/max(image)
 
 writefits,'image_403.fits',image_16bit
 
 
 ;===============================================================================
 ; 7. Gather image information.
 ;===============================================================================
 
 ;-----------------------------------
 ; Create the image information array.
 ;-----------------------------------
 Nchars = strlen(obsname)
 if (Nchars LT 15) then begin
     fill = ''
     for ii=Nchars,15-1 do fill = fill + ' '
     endif
 
 image_info = {info, JD:JD,                                                    $
 obsname:obsname+fill, Xobs:Xobs, Yobs:Yobs, Zobs:Zobs,    $
 pixelscale:pixelscale,                                    $
 RAmoon:RAmoon, DECmoon:DECmoon, Dem:Dem,                  $
 RAsun:RAsun, DECsun:DECsun, Dse:Dse,                      $
 GHAaries:GHAaries,                                        $
 lat_lib:lat_lib, lon_lib:lon_lib, PA_lib:PA_lib,          $
 phase_angle_E:phase_angle_E, phase_angle_M:phase_angle_M, $
 Isun:Isun, Iearth:Iearth, Imoon:Imoon }
 
 ; generate a FITS header, instead of the INFO file structure
 donotuse=readfits('dummyimagetogetheaderfrom.fits',header55)
 
 sxaddpar, header55, 'OBSNAME', OBSNAME, 'Simulated Obseravtory'
 sxaddpar, header55, 'Xobs', Xobs, ' ... '
 sxaddpar, header55, 'Yobs', Yobs, ' ... '
 sxaddpar, header55, 'Zobs', Zobs, ' ... '
 sxaddpar, header55, 'p-scale', pixelscale, ' arcsec/pixel '
 sxaddpar, header55, 'RAm', RAmoon, ' Moon RA '
 sxaddpar, header55, 'DECm', DECmoon, ' Moon Decliniation '
 sxaddpar, header55, 'Dem', Dem, ' Moon-Earth distance'
 sxaddpar, header55, 'RAs', RAsun, ' Sun RA '
 sxaddpar, header55, 'DECs', DECsun, ' Sun Decliniation '
 sxaddpar, header55, 'Dse', Dse, ' Sun-Earth distance'
 sxaddpar, header55, 'lat_lib', lat_lib, ' latitude libration'
 sxaddpar, header55, 'lon_lib', lon_lib, ' longitude libration'
 sxaddpar, header55, 'PA_lib', PA_lib, ' Position Angle libration'
 sxaddpar, header55, 'Isun', Isun , ' Sun intensity'
 sxaddpar, header55, 'Iearth', Iearth, ' Earthshine intensity'
 ; write it out
 writefits,'lonlatpairItellYOUwantTHISimage.fits',lonlatSELimage,header55
 get_lun,chj
 openw,chj,'Iearth.now'
 printf,chj,Iearth
 close,chj
 free_lun,chj
 return
 END
