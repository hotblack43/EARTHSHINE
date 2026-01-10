;===============================================================================
;
; FUNCTION CalcTransformMatrix
;
; Compute transformation matrixes for conversion between coordinate systems.
;
; SEL  :  Rectangular selenographic coordinates
; MEEQ :  Moon-centred Earth-directed Equatorial system
; EMEQ :  Earth-centred Moon-directed Equatorial system
; IMEQ :  Image-centred Moon-directed Equatorial system
; GEO  :  Rectangular geographic coordinates
; EQ   ;  Rectangular equatorial coordinates
;
; Ver. 2007-03-28
;
;===============================================================================

FUNCTION  CalcTransformMatrix, transform, lat, lon, phi, Xorig, Yorig, Zorig


transform = strcompress(transform,/rem)

DRADEG = 180.0D/!DPI
RADEG  = 180.0/!PI

if strcmp(transform,'meeq2sel',/fold_case) then begin

  Rz = dblarr(3,3)
  Ry = dblarr(3,3)
  Rx = dblarr(3,3)

  lat = double(lat)
  lon = double(lon)
  phi = double(phi)

  thetaZ = lon/DRADEG
  thetaY = -lat/DRADEG
  thetaX = -phi/DRADEG

  ; the following steps transform SEL axes into MEEQ axes
  ; assume initially that SEL and MEEQ Z-axes coincide

  ; rotation around the original Z-axis
  Rz[*,0] = [ cos(thetaZ) ,-sin(thetaZ) ,   0.0D   ]
  Rz[*,1] = [ sin(thetaZ) , cos(thetaZ) ,   0.0D   ]
  Rz[*,2] = [    0.0D     ,    0.0D     ,   1.0D   ]

  ; rotation around the new Y-axis (observe the rotation direction)
  Ry[*,0] = [ cos(thetaY) ,   0.0D   , sin(thetaY) ]
  Ry[*,1] = [    0.0D     ,   1.0D   ,     0.0D    ]
  Ry[*,2] = [-sin(thetaY) ,   0.0D   , cos(thetaY) ]

  ; rotation around the new X-axis
  Rx[*,0] = [   1.0D   ,    0.0D     ,   0.0D      ]
  Rx[*,1] = [   0.0D   , cos(thetaX) ,-sin(thetaX) ]
  Rx[*,2] = [   0.0D   , sin(thetaX) , cos(thetaX) ]

  R = ((Rz ## Ry) ## Rx)

endif else if strcmp(transform,'sel2meeq',/fold_case) then begin

  Rz = dblarr(3,3)
  Ry = dblarr(3,3)
  Rx = dblarr(3,3)

  lat = double(lat)
  lon = double(lon)
  phi = double(phi)

  thetaZ = -lon/DRADEG
  thetaY = lat/DRADEG
  thetaX = phi/DRADEG

  ; the following steps transform MEEQ axes into SEL axes

  ; rotation around the X-axis
  Rx[*,0] = [   1.0D   ,    0.0D     ,   0.0D      ]
  Rx[*,1] = [   0.0D   , cos(thetaX) ,-sin(thetaX) ]
  Rx[*,2] = [   0.0D   , sin(thetaX) , cos(thetaX) ]

  ; rotation around the Y-axis (observe the rotation direction)
  Ry[*,0] = [ cos(thetaY) ,   0.0D   , sin(thetaY) ]
  Ry[*,1] = [    0.0D     ,   1.0D   ,     0.0D    ]
  Ry[*,2] = [-sin(thetaY) ,   0.0D   , cos(thetaY) ]

  ; rotation around the Z-axis
  Rz[*,0] = [ cos(thetaZ) ,-sin(thetaZ) ,   0.0D   ]
  Rz[*,1] = [ sin(thetaZ) , cos(thetaZ) ,   0.0D   ]
  Rz[*,2] = [    0.0D     ,    0.0D     ,   1.0D   ]

  R = ((Rx ## Ry) ## Rz)

endif else if strcmp(transform,'meeq2emeq',/fold_case) OR strcmp(transform,'emeq2meeq',/fold_case) then begin

  T  = dblarr(4,4)
  Rz = dblarr(4,4)
  R  = dblarr(4,4)

  Dx = double(Xorig)
  Dy = 0.0D
  Dz = 0.0D

  ; the following steps transform EMEQ axes into MEEQ axes or vice versa

  ; translation in MEEQ/EMEQ coordinates
  T[*,0] = [  1.0D ,  0.0D ,  0.0D  ,  Dx  ]
  T[*,1] = [  0.0D ,  1.0D ,  0.0D  ,  Dy  ]
  T[*,2] = [  0.0D ,  0.0D ,  1.0D  ,  Dz  ]
  T[*,3] = [  0.0D ,  0.0D ,  0.0D  , 1.0D ]

  ; rotation around the MEEQ/EMEQ Z-axis
  Rz[*,0] = [ -1.0D ,  0.0D ,  0.0D  , 0.0D  ]
  Rz[*,1] = [  0.0D , -1.0D ,  0.0D  , 0.0D ]
  Rz[*,2] = [  0.0D ,  0.0D ,  1.0D  , 0.0D ]
  Rz[*,3] = [  0.0D ,  0.0D ,  0.0D  , 1.0D ]

  R = (T ## Rz)

endif else if strcmp(transform,'meeq2imeq',/fold_case) then begin

  T  = dblarr(4,4)
  Rz = dblarr(4,4)
  Ry = dblarr(4,4)
  Rx = dblarr(4,4)
  R  = dblarr(4,4)

  Dx = double(Xorig)
  Dy = double(Yorig)
  Dz = double(Zorig)
  thetaZ = (-1.0D*(atan(Dy,Dx)*DRADEG + 180.0D) MOD 360)/DRADEG
  thetaY = -atan(Dz/sqrt(Dx^2+Dy^2))

  ; the following steps transform IMEQ axes into MEEQ axes

  ; rotation around the original IMEQ Y-axis (observe the rotation direction)
  Ry[*,0] = [ cos(thetaY) ,    0.0D      , sin(thetaY) , 0.0D ]
  Ry[*,1] = [   0.0D      ,    1.0D      ,   0.0D      , 0.0D ]
  Ry[*,2] = [-sin(thetaY) ,    0.0D      , cos(thetaY) , 0.0D ]
  Ry[*,3] = [    0.0D     ,    0.0D      ,   0.0D      , 1.0D ]

  ; rotation around the new Z-axis
  Rz[*,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,2] = [   0.0D      ,    0.0D      ,  1.0D  , 0.0D ]
  Rz[*,3] = [   0.0D      ,    0.0D      ,  0.0D  , 1.0D ]

  ; translation from IMEQ origin to MEEQ origin in the new cordinate system
  T[*,0] = [    1.0D      ,    0.0D      ,  0.0D  , -Dx   ]
  T[*,1] = [    0.0D      ,    1.0D      ,  0.0D  , -Dy   ]
  T[*,2] = [    0.0D      ,    0.0D      ,  1.0D  , -Dz   ]
  T[*,3] = [    0.0D      ,    0.0D      ,  0.0D  , 1.0D  ]

  R = ((Ry ## Rz) ## T)

endif else if strcmp(transform,'imeq2meeq',/fold_case) then begin

  T  = dblarr(4,4)
  Rz = dblarr(4,4)
  Ry = dblarr(4,4)
  Rx = dblarr(4,4)
  R  = dblarr(4,4)

  Dx = double(Xorig)
  Dy = double(Yorig)
  Dz = double(Zorig)
  thetaZ = ((atan(Dy,Dx)*DRADEG + 180.0D) MOD 360)/DRADEG
  thetaY = atan(Dz/sqrt(Dx^2+Dy^2))

  ; the following steps transform MEEQ axes into IMEQ axes

  ; translation from origin to the observer's location
  T[*,0] = [    1.0D      ,    0.0D      ,  0.0D  ,  Dx   ]
  T[*,1] = [    0.0D      ,    1.0D      ,  0.0D  ,  Dy   ]
  T[*,2] = [    0.0D      ,    0.0D      ,  1.0D  ,  Dz   ]
  T[*,3] = [    0.0D      ,    0.0D      ,  0.0D  , 1.0D  ]

  ; rotation around the Z-axis
  Rz[*,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,2] = [   0.0D      ,    0.0D      ,  1.0D  , 0.0D ]
  Rz[*,3] = [   0.0D      ,    0.0D      ,  0.0D  , 1.0D ]

  ; rotation around the new IMEQ Y-axis (observe the rotation direction)
  Ry[*,0] = [ cos(thetaY) ,    0.0D      , sin(thetaY) , 0.0D ]
  Ry[*,1] = [   0.0D      ,    1.0D      ,   0.0D      , 0.0D ]
  Ry[*,2] = [-sin(thetaY) ,    0.0D      , cos(thetaY) , 0.0D ]
  Ry[*,3] = [    0.0D     ,    0.0D      ,   0.0D      , 1.0D ]

  R = ((T ## Rz) ## Ry)

endif else if strcmp(transform,'eq2meeq',/fold_case) then begin

  T  = dblarr(4,4)
  Rz = dblarr(4,4)
  Ry = dblarr(4,4)
  Rx = dblarr(4,4)
  R  = dblarr(4,4)

  Dx = double(Xorig)
  Dy = 0.0D
  Dz = 0.0D
  thetaY = double(0.0-lat)/DRADEG
  thetaZ = double(180.0-lon)/DRADEG

  ; the following steps transform MEEQ axes into EQ axes

  ; translation from MEEQ origin to EQ origin
  T[*,0] = [    1.0D      ,    0.0D      ,  0.0D  ,  Dx   ]
  T[*,1] = [    0.0D      ,    1.0D      ,  0.0D  ,  Dy   ]
  T[*,2] = [    0.0D      ,    0.0D      ,  1.0D  ,  Dz   ]
  T[*,3] = [    0.0D      ,    0.0D      ,  0.0D  , 1.0D  ]

  ; rotation around the Y-axis (observe the rotation direction)
  Ry[*,0] = [ cos(thetaY) ,    0.0D      , sin(thetaY) , 0.0D ]
  Ry[*,1] = [   0.0D      ,    1.0D      ,   0.0D      , 0.0D ]
  Ry[*,2] = [-sin(thetaY) ,    0.0D      , cos(thetaY) , 0.0D ]
  Ry[*,3] = [    0.0D     ,    0.0D      ,   0.0D      , 1.0D ]

  ; rotation around the Z-axis
  Rz[*,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,2] = [   0.0D      ,    0.0D      ,  1.0D  , 0.0D ]
  Rz[*,3] = [   0.0D      ,    0.0D      ,  0.0D  , 1.0D ]

  R = ((T ## Ry) ## Rz)

endif else if strcmp(transform,'meeq2eq',/fold_case) then begin

  T  = dblarr(4,4)
  Rz = dblarr(4,4)
  Ry = dblarr(4,4)
  Rx = dblarr(4,4)
  R  = dblarr(4,4)

  Dx = double(Xorig)
  Dy = 0.0D
  Dz = 0.0D
  thetaY = double(lat)/DRADEG
  thetaZ = double(lon-180.0)/DRADEG

  ; the following steps transform EQ axes into MEEQ axes

  ; rotation around the Z-axis
  Rz[*,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,2] = [   0.0D      ,    0.0D      ,  1.0D  , 0.0D ]
  Rz[*,3] = [   0.0D      ,    0.0D      ,  0.0D  , 1.0D ]

  ; rotation around the Y-axis (observe the rotation direction)
  Ry[*,0] = [ cos(thetaY) ,    0.0D      , sin(thetaY) , 0.0D ]
  Ry[*,1] = [   0.0D      ,    1.0D      ,   0.0D      , 0.0D ]
  Ry[*,2] = [-sin(thetaY) ,    0.0D      , cos(thetaY) , 0.0D ]
  Ry[*,3] = [    0.0D     ,    0.0D      ,   0.0D      , 1.0D ]

  ; translation from EQ origin to MEEQ origin
  T[*,0] = [    1.0D      ,    0.0D      ,  0.0D  , -Dx   ]
  T[*,1] = [    0.0D      ,    1.0D      ,  0.0D  , -Dy   ]
  T[*,2] = [    0.0D      ,    0.0D      ,  1.0D  , -Dz   ]
  T[*,3] = [    0.0D      ,    0.0D      ,  0.0D  , 1.0D  ]

  R = ((Rz ## Ry) ## T)

endif else if strcmp(transform,'eq2geo',/fold_case) then begin

  Rz = dblarr(4,4)
  R  = dblarr(4,4)

  thetaZ = double(-lon)/DRADEG

  ; the following step transform GEO axes into EQ axes

  ; rotation around the Z-axis
  Rz[*,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,2] = [   0.0D      ,    0.0D      ,  1.0D  , 0.0D ]
  Rz[*,3] = [   0.0D      ,    0.0D      ,  0.0D  , 1.0D ]

  R = (Rz)

endif else if strcmp(transform,'geo2eq',/fold_case) then begin

  Rz = dblarr(4,4)
  R  = dblarr(4,4)

  thetaZ = double(lon)/DRADEG

  ; the following step transform EQ axes into GEO axes

  ; rotation around the Z-axis
  Rz[*,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0D  , 0.0D ]
  Rz[*,2] = [   0.0D      ,    0.0D      ,  1.0D  , 0.0D ]
  Rz[*,3] = [   0.0D      ,    0.0D      ,  0.0D  , 1.0D ]

  R = (Rz)

endif else begin

  stop,'ERROR: in CalcRotMatrix.'

endelse

return,R


END

;===============================================================================
;
; PRO SunMoon_ephemerid
;
; Compute Sun and Moon positions (RA, DEC, DIST) and Moon libration parameters
; (sub-terrestrial and sub-solar points on the Moon) from the julian date.
;
; The central formula for Moon position is approximate. Finer details
; like physical (as opposed to optical) libration and the nutation have
; been neglected. Formulas have been simplified from Meeus 'Astronomical
; Algorithms' (1st Ed) Chapter 51 (sub-earth and sub-solar points, PA of
; pole and Bright Limb, Illuminated fraction). The libration figures are
; usually 0.05 to 0.2 degree different from the results given by Harry
; Jamieson's 'Lunar Observer's Tool Kit' DOS program. Some of the code is
; adapted from a BASIC program by George Rosenberg (ALPO).
;
; Ver. 2007-03-01
;
;===============================================================================

PRO SunMoon_ephemerid, JD, RAsun, DECsun, DISTsun, RAmoon, DECmoon, DISTmoon, lat_lib, lon_lib, PA_lib


d2r = !DPI/180.0d       ; degrees to radians, double precision

caldat, JD, mon, d, yr, h, mnt, sec

; Alternative conversion to year, month, day, hour, minute
; when date is given in the form YYYYMMDD.hhmm
; g = 20000222.0843D
; yr  = fix(floor(g / 10000))
; mon = fix(floor( (g - yr*10000.0D) / 100))
; d   = fix(floor(g - yr*10000.0D - mon*100.0D ))
; bit = (g - floor(g))*100.0
; h   = fix(floor(bit))
; mnt = fix(floor(bit*100.0 - h*100.0 + 0.5))

; error checking
bk = 0
if (yr LT 1800 OR yr GT 2200) then begin
  stop, 'ERROR: date must be between the years 1800 and 2200.'
endif
if (mon LT 1 OR mon GT 12) then begin
  stop, 'ERROR: months are not right.'
endif
; check the month/day/year combination
leap = isleap(yr)
a = 1
if (d LE 0) then a = 0
if ((mon EQ 2) AND (leap EQ 1) AND (d GT 29)) then a= 0
if ((mon EQ 2) AND (d GT 28) AND (leap EQ 0)) then a = 0
if (((mon EQ 4) OR (mon EQ 6) OR (mon EQ 9) OR (mon EQ 11)) AND d GT 30) then a = 0
if (d GT 31) then a = 0
dayOK = a
if (dayOK EQ 0) then begin
  stop, 'Error: wrong number of days for the month or not a leap year.'
endif
if (h LT 0 OR h GT 23) then begin
  stop, 'ERROR: hours are not right.'
endif
if (mnt GT 59) then begin
  stop, 'ERROR: minutes are not right.'
endif

; get the number of days since J2000.0
days = day2000(yr,mon,d,h+mnt/60.0)
t = days / 36525.0

; Sun formulas
;
; L1  - Mean longitude
; M1  - Mean anomaly
; C1  - Equation of centre
; V1  - True anomaly
; Ec1 - Eccentricity
; R1  - Sun distance
; Th1 - Theta (true longitude)
; Om1 - Long Asc Node (Omega)
; Lam1- Lambda (apparent longitude)
; Obl - Obliquity of ecliptic
; Ra1 - Right Ascension
; Dec1- Declination

L1 = range(280.466 + 36000.8*t)
M1 = range(357.529 + 35999*t - 0.0001536*t*t + t*t*t/24490000.0)
C1 = (1.915 - 0.004817*t - 0.000014*t*t) * sin(M1*d2r)
C1 = C1 + (0.01999 - 0.000101*t)* sin(2*M1*d2r)
C1 = C1 + 0.00029 * sin(3*M1*d2r)
V1 = M1 + C1
Ec1 = 0.01671 - 0.00004204*t - 0.0000001236*t*t
R1 = 0.99972 / (1.0 + Ec1*cos(V1*d2r))
Th1 = L1 + C1
Om1 = range(125.04 - 1934.1*t)
Lam1 = Th1 - 0.00569 - 0.00478*sin(Om1*d2r)
Obl = (84381.448 - 46.815*t)/3600.0
Ra1 = datan2(sin(Th1*d2r) * cos(Obl*d2r) - tan(0.0*d2r)* sin(Obl*d2r), cos(Th1*d2r))
Dec1 = dasin(sin(0.0*d2r)* cos(Obl*d2r) + cos(0.0*d2r)*sin(Obl*d2r)*sin(Th1*d2r))


; Moon formulas
;
; F   - Argument of latitude (F)
; L2  - Mean longitude (L')
; Om2 - Long. Asc. Node (Om')
; M2  - Mean anomaly (M')
; D   - Mean elongation (D)
; D2  - 2 * D
; R2  - Lunar distance (Earth - Moon distance)
; R3  - Distance ratio (Sun / Moon)
; Bm  - Geocentric Latitude of Moon
; Lm  - Geocentric Longitude of Moon
; HLm - Heliocentric longitude
; HBm - Heliocentric latitude
; Ra2 - Lunar Right Ascension
; Dec2- Declination

F = range(93.2721 + 483202.0*t - 0.003403*t*t - t*t*t/3526000.0)
L2 = range(218.316 + 481268.0*t)
Om2 = range(125.045 - 1934.14*t + 0.002071 * t * t + t * t * t/450000.0)
M2 = range(134.963 + 477199 * t + 0.008997 * t * t + t * t * t/69700.0)
D = range(297.85 + 445267.0 * t - 0.00163 * t * t + t * t * t/545900.0)
D2 = 2*D
R2 = 1 + (-20954 * dcos(M2) - 3699 * dcos(D2 - M2) - 2956 * dcos(D2)) / 385000.0
R3 = (R2 / R1) / 379.168831168831
Bm = 5.128 * dsin(F) + 0.2806 * dsin(M2 + F)
Bm = Bm + 0.2777 * dsin(M2 - F) + 0.1732 * dsin(D2 - F)
Lm = 6.289 * dsin(M2) + 1.274 * dsin(D2 -M2) + 0.6583 * dsin(D2)
Lm = Lm + 0.2136 * dsin(2*M2) - 0.1851 * dsin(M1) - 0.1143 * dsin(2 * F);
Lm = Lm + 0.0588 * dsin(D2 - 2*M2)
Lm = Lm + 0.0572* dsin(D2 - M1 - M2) + 0.0533* dsin(D2 + M2)
Lm = Lm + L2
Ra2 = datan2(dsin(Lm) * dcos(Obl) - dtan(Bm)* dsin(Obl), dcos(Lm))
Dec2 = dasin(dsin(Bm)* dcos(Obl) + dcos(Bm)*dsin(Obl)*dsin(Lm))
HLm = range(Lam1 + 180.0 + (180.0/!PI) * R3 * dcos(Bm) * dsin(Lam1 - Lm))
HBm = R3 * Bm


; Selenographic coords of the sub Earth point.
; This gives the (geocentric) libration
; approximating to that listed in most almanacs

; Physical libration ignored, as is nutation.

; I   - Inclination of (mean) lunar orbit to ecliptic
; EL  - Selenographic longitude of sub Earth point
; EB  - Sel Lat of sub Earth point
; W   - angle variable
; X   - Rectangular coordinate
; Y   - Rectangular coordinate
; A   - Angle variable (see Meeus ch 51 for notation)

I = 1.54242
W = Lm - Om2
Y = dcos(W) * dcos(Bm)
X = dsin(W) * dcos(Bm) * dcos(I) - dsin(Bm) * dsin(I)
A = datan2(X, Y)
EL = A - F
EB = dasin(-dsin(W) * dcos(Bm) * dsin(I) - dsin(Bm) * dcos(I))

; Selenographic coords of sub-solar point. This point is
; the 'pole' of the illuminated hemisphere of the Moon
; and so describes the position of the terminator on the
; lunar surface. The information is communicated through
; numbers like the colongitude, and the longitude of the
; terminator.

; SL  - Sel Long of sub-solar point
; SB  - Sel Lat of sub-solar point
; W, Y, X, A  - temporary variables as for sub-Earth point
; Co  - Colongitude of the Sun
; SLt - Selenographic longitude of terminator
; riset - Lunar sunrise or set

W = range(HLm - Om2)
Y = dcos(W) * dcos(HBm)
X = dsin(W) * dcos(HBm) * dcos(I) - dsin(HBm) * dsin(I)
A = datan2(X, Y)
SL = range(A - F)
SB = dasin(-dsin(W) * dcos(HBm) * dsin(I) - dsin(HBm) * dcos(I))

if (SL LT 90.0) then begin
  Co = 90.0 - SL
endif else begin
  Co = 450.0 - SL
endelse

if ((Co GT 90.0) AND (Co LT 270.0)) then begin
  SLt = 180.0 - Co
endif else begin
  if (Co LT 90.0) then begin
    SLt = 0 - Co
  endif else begin
    SLt = 360.0 - Co
  endelse
endelse


; Calculate the illuminated fraction, the position angle of the bright
; limb, and the position angle of the Moon's rotation axis. All position
; angles relate to the North Celestial Pole - you need to work out the
; 'Parallactic angle' to calculate the orientation to your local zenith.

;--- Iluminated fraction
A = dcos(Bm) * dcos(Lm - Lam1)
Psi = 90.0 - datan(A / sqrt(1.0-A*A))
X = R1 * dsin(Psi)
Y = R3 - R1* A
Il = datan2(X, Y)
K = (1.0 + dcos(Il))/2.0

;--- PA bright limb
X = dsin(Dec1) * dcos(Dec2) - dcos(Dec1) * dsin(Dec2) * dcos(Ra1 - Ra2)
Y = dcos(Dec1) * dsin(Ra1 - Ra2)
P1 = datan2(Y, X)

;--- PA Moon's rotation axis
;--- Neglects nutation and physical libration, so Meeus' angle V is just Om2
X = dsin(I) * dsin(Om2)
Y = dsin(I) * dcos(Om2) * dcos(Obl) - dcos(I) * dsin(Obl)
W = datan2(X, Y)
A = sqrt(X*X + Y*Y) * dcos(Ra2 - W)
P2 = dasin(A / dcos(EB))

goto,jump
print, 'Libration in Lat (EB) = ', EB
print, 'Libration in Lon (EL) = ', EL
print, 'Colongitude of Sun (Co) = ', Co
print, 'Subsolar point Lat (SB) = ', SB
print, 'Subsolar point Lon (SL) = ', SL
print, 'Sel lon of terminator (SLt) = ', SLt
; form.SelIlum.value = round(K, 3);
; form.SelPaBl.value = round(P1, 1);
; form.SelPaPole.value = round(P2, 1);
jump:

;--- Sun
RAsun    = Ra1/15.0
DECsun   = Dec1
DISTsun  = R1

;--- Moon
RAmoon   = Ra2/15.0
DECmoon  = Dec2
DISTmoon = R2*60.268511

;--- libration
lat_lib  = EB
lon_lib  = EL
PA_lib   = P2


END





;======================================
; Fractional number of days since J2000
;======================================
;
 FUNCTION day2000, yr, mon, day, hr
    if (mon EQ 1) OR (mon EQ 2) then begin
      yr = yr - 1
      mon = mon + 12
    endif
    a = floor(yr/100.0)
    b = 2.0 - a  + floor(a/4.0)
    c = floor(365.25 * yr)
    d1 = floor(30.6001 * (mon + 1))
    return, (b + c + d1 - 730550.5 + day + hr/24.0)
 END




;=============================
; Leap year detecting function.
;=============================

 FUNCTION isleap, yr
   a = 0
   if ((yr MOD 4) EQ 0) then a = 1
   if ((yr MOD 100) EQ 0) then a = 0
   if ((yr MOD 400) EQ 0) then a = 1
   return, a
 END



;=========================================================
; Trigonometric functions working in degrees - this just
; makes implementing the formulas in books easier.
; The 'range' function brings angles into range 0 to 360,
; and an atan2(x,y) function returns arctan in correct
; quadrant. ipart(x) returns smallest integer nearest zero.
;=========================================================
;
 FUNCTION dsin, x
   return, sin(x*(!PI/180.0))
 END
;
 FUNCTION dcos, x
   return, cos(x*(!PI/180.0))
 END
;
 FUNCTION dtan, x
   return, tan(x*(!PI/180.0))
 END
;
 FUNCTION dasin, x
   return, (180.0/!PI) * asin(x)
 END
;
 FUNCTION dacos, x
   return, (180.0/!PI) * acos(x)
 END
;
 FUNCTION datan, x
   return, (180.0/!PI) * atan(x)
 END
;
 FUNCTION datan2, y, x
   if ((x EQ 0.0) AND (y EQ 0.0)) then begin
     return, 0
   endif else begin
     a = datan(y/x)
     if (x LT 0.0) then begin
       a = a + 180.0
     endif
     if (y LT 0.0 AND x GT 0.0) then begin
       a = a + 360.0
     endif
     return, a
   endelse
 END
;
 FUNCTION ipart, x
   if (x GT 0.0) then begin
     a = floor(x)
   endif else begin
     a = ceil(x)
   endelse
   return, a
 END
;
 FUNCTION range, x
   b = x / 360.0
   a = 360.0 * (b - ipart(b))
   if (a LT 0.0) then begin
     a = a + 360.0
   endif
   return, a
 END




;==============================================
; Month and day number checking function.
; This will work OK for Julian or Gregorian
; providing isleap() is defined appropriately.
; Returns 1 if Month and Day combination OK,
; and 0 if month and day combination impossible.
;==============================================
;
 FUNCTION goodmonthday, yr, mon, day
   leap = isleap(yr)
   a = 1
   if (day LE 0) then a = 0
   if ((mon EQ 2) AND (leap EQ 1) AND (day GT 29)) then a= 0
   if ((mon EQ 2) AND (day GT 28) AND (leap EQ 0)) then a = 0
   if (((mon EQ 4) OR (mon EQ 6) OR (mon EQ 9) OR (mon EQ 11)) AND day GT 30) then a = 0
   if (day GT 31) then a = 0
   return, a
 END
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
; The generated image is 'ideal' i.e. there are no sky, noise or CCD effects.
; The final image is returned in two versions: image_16bit (the ideal image
; stored as floating point, but scaled to simulate a well-exposed 16-bit frame)
; and image_I (the same, but without scaling).
;
; Version 40 - islike version 20 3except no scaling of CLEM to WILDEY or by eye.
;
; Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute
;
;===============================================================================


PRO eshine_core_40, JD, phase_angle, lat_lib, lon_lib, PA_lib,                 $
                 obsname, obssys, Xobs_in, Yobs_in, Zobs_in,                $
                 moon_albedo, moon_BRDF, earth_albedo, earth_albedo_uniform_value, hapkeG, $
		 hapket,earth_BRDF, datalib, imsize, pixelscale,                   $ 
                 if_moon_visible, if_librate, if_variable_distances,        $
                 image_I, image_16bit, image_info, mask, MAPofEARTH
;compile_opt idl2, hidden
common phases,phase_angle_M, phase_angle_E

Print,"This is eshine_core_40.pro and it does NOT scale Clementine"
;Print,"Currently Clementine IS scaled to Wildey!"
;Print,"Currently Clementine is scaled to Wildey aand then further scaled by eye!"

; NOTE: Check lines near 930 for inclusion of the scaled map etc
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
image       = dblarr(imsize,imsize) * 0.0d0
image_I     = dblarr(imsize,imsize) * 0.0d0
image_16bit = dblarr(imsize,imsize) * 0.0d0
mask        = dblarr(imsize,imsize) * 0.0d0



;===============================================================================
;=                                                                             =
;=  1. Sun-Earth-Moon geometry incl. libration.                                =
;=     Observer's location.                                                    =
;=     Matrixes to go between coordinate systems.                              =
;=                                                                             =
;===============================================================================


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
 print,JD, RAs, DECs, DISTs, RAm, DECm, DISTm, lat_lib, lon_lib, PA_lib
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




;===============================================================================
;=                                                                             =
;=  2.1 Reflection properties of Earth and Moon.                               =
;=                                                                             =
;===============================================================================


;-----------------------------------------------------------------------
; Moon reflectivity:
; given in terms of normal albedo PNORM, i.e. the reflectivity at the
; standard viewing geometry (phi=i=30, e=0)
;-----------------------------------------------------------------------
if (moon_albedo EQ 0) then begin
; 0 -> uniform reflectivity 0.0720
PNORMmoon = fltarr(1080,540) + 0.0720
endif else if (moon_albedo EQ 1) then begin
;......................................................
; WARNING, the following scaled V2 map may not be very good.
; ; 1 -> Clementine V2 map scaled so that median of HIRES_750_3ppd.alb and this one are the same
; X = read_ascii(datalib+'/'+'CLEM_V2_scaled.alb',data_start=0)
;......................................................
; ; 1 -> Clementine/HIRES 750 nm reflectivity
 X = read_ascii(datalib+'/'+'HIRES_750_3ppd.alb',data_start=0)
;......................................................
; 1 -> Clementine/HIRES 750 nm reflectivity SCALED to match the gross features of the Wildey map
; X = read_ascii(datalib+'/'+'HIRES_750_3ppd_scaled_to_WIldey.alb',data_start=0)
;......................................................
; 1 -> Clementine/HIRES 750 nm reflectivity SCALED to conserve mean value and dampen SD to 90%
; X = read_ascii(datalib+'/'+'SPECIAL.HIRES_750_3ppd_scaled_to_WIldey.alb',data_start=0)
;......................................................
  PNORMmoon = float(X.field0001)
endif


;-----------------------------------------------------------------------
; Earth reflectivity:
; given in terms of hemispheric albedo RHO
;-----------------------------------------------------------------------
if (earth_albedo EQ 0) then begin
  ; 0 -> uniform albedo set to user-input value
  RHOearth = fltarr(360,180)*0.0 + earth_albedo_uniform_value
endif else if (earth_albedo EQ 1) then begin
  ; 1 -> cloud-free Earth
;----
; I thought reading from a binary file would speed up the code - it appears it did not
; fetch_terrestrial_albedo_map,indx0,indx1,indx2,indx3,indx4,indx5,indx6,indx7,indx,	$
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
endif
  print,' JD, ALBearth:', JD, mean(RHOearth)

; must flip North to SOuth and vice versa or map does not correspond to 
; direction of loop over lon and lat 

RHOearth=reverse(RHOearth,2)

; Must also - apparently - shift map in longitude 180 degrees

RHOearth=shift(RHOearth,180)

;-----------------------------------------------------------------------
; Moon BRDF parameters:
; Get the parameter OMEGA from the normal albedo PNORM.
; The relation between these two depend on the type of BRDF assumed.
;-----------------------------------------------------------------------
if (moon_BRDF EQ 0) then begin
  ; 0 -> Lambert
  OMEGAmoon = PNORMmoon/(cos(30./DRADEG)/!DPI)
endif else if (moon_BRDF EQ 1) then begin
  ; 1 -> Hapke -63. JGR 1963 68, pp. 4571-4586.
  g=hapkeG
  t=hapket
  tan30degrees=tan(30./DRADEG)
  ;B = 2.0 - (tan(30./DRADEG)/(2.*g)) * (1.0 - exp(-g/tan(30./DRADEG))) * (3.0 - exp(-g/tan(30./DRADEG)))
  B = 2.0 - (tan30degrees/(2.*g)) * (1.0 - exp(-g/tan30degrees)) * (3.0 - exp(-g/tan30degrees))
  S = (2.0/(3*!DPI)) * ( (sin(30./DRADEG) + (!DPI-30./DRADEG)*cos(30./DRADEG))/!DPI + t*(1.0 - 0.5*cos(30./DRADEG))^2 )
  g30 = B*S  ; 0.228068
  LS30 = cos(30./DRADEG) / (cos(30./DRADEG) + cos(0.0/DRADEG))   ; 0.464102
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

  thing =  BRDFse*Isun*cos(AoI)*surfarea*cos(AoR)*1.0/(Dem*Dem*1.0e6)
  Iearth = Iearth + thing
  MAPofEARTH(ilon,ilat)=thing

endfor
endfor

Iearth = Iearth[0]

mphase,jd,k
print,format='(a,f20.5,1x,2(f20.7,1x),2(f10.5,1x))', 'JD, Isun, Iearth, ph_M, ph_E = ', JD,Isun, Iearth, phase_angle_M, phase_angle_E
printf,83,format='(a,f20.5,1x,2(f20.7,1x),2(f10.5,1x))', 'JD, Isun, Iearth, ph_M, ph_E = ', JD,Isun, Iearth, phase_angle_M, phase_angle_E

;===============================================================================
;=                                                                             =
;=  4. Form the image pixel by pixel by adding the contributions from the      =
;=     Moon and any other light in the field of view. Each pixel collects      =
;=     light in a certain direction, and the light sources contributing        =
;=     to the pixel value are found by a simple form of ray tracing.           =
;=                                                                             =
;===============================================================================


;----------------------------------------------------------------------------
; For each image pixel, compute the incident light.
; Each pixel receives light from a certain solid angle in a certain direction.
;----------------------------------------------------------------------------
; Nabox_lon = intarr(imsize,imsize) * 0
; Nabox_lat = intarr(imsize,imsize) * 0

lonlatSELimage=fltarr(imsize,imsize,2)	; array to hold lunar lon and lat
theta_i_and_r_and_phi=fltarr(imsize,imsize,2)	; array to hold theta_i and theta_r

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
    surfnormal = [1.0*cos(lonMEEQ/DRADEG)*cos(latMEEQ/DRADEG) , 1.0*sin(lonMEEQ/DRADEG)*cos(latMEEQ/DRADEG) , 1.0*sin(latMEEQ/DRADEG)]

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

 ; also store the directions to SUn and Observer as a map across the sunlit side of the Moon
    theta_i_and_r_and_phi(iy+imsize/2,  iz+imsize/2, 0)=reform(AoIs)
    theta_i_and_r_and_phi(iy+imsize/2,  iz+imsize/2, 1)=reform(AoR)

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
    OMEGA = median(OMEGAmoon[jj,ii_min:ii_max])
    ; OMEGA = mean(OMEGAmoon[jj,ii_min:ii_max])

    ; Hapke -63 phase function for the sunshine incident on the Moon
    g = hapkeG
    t = hapket
    if (phi EQ 0.0D) then begin
      B = 2.0
    endif else if (phi GT 0.0D AND phi LT (!DPI/2.0-0.00001)) then begin
      B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
    endif else if (phi GE (!DPI/2.0-0.00001)) then begin
      B = 1.0
    endif
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
      ;print,'AoIs,AoR:',AoIs,AoR
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
    image[imsize/2+iy,imsize/2+iz] = double(BRDFsm*Isun*cos(AoIs)) + double(BRDFem*Iearth*cos(AoIe))
    ; generate also a 'mask' that contains only the sunlit part of the Moon
    mask[imsize/2+iy,imsize/2+iz] = double(BRDFsm*Isun*cos(AoIs)) 

  endif

endfor
endfor

indx = where(image LT 0.0d,count)
if (count GT 0) then stop,'ERROR: ray-tracing produced negative intensities.'




;===============================================================================
;
; 5. Store two versions of the generated image:
;
;      image_I      -  the actual radiances from the Moon, without sky, filters,
;                      Poisson noise, or CCD effects.
;
;      image_16bit  -  the same ideal image, still floating-point but now scaled
;                      to simulate a well-exposed 16-bit CCD frame
;
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

;===============================================================================
;=                                                                             =
;=  6. Gather image information.                                               =
;=                                                                             =
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
                    lat_lib:lat_lib, lon_lib:lon_lib, PA_lib:PA_lib,          $
                    phase_angle_E:phase_angle_E, phase_angle_M:phase_angle_M, $
                    Isun:Isun, Iearth:Iearth }
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
sxaddpar, header55, 'PhsAn_E', phase_angle_E, ' Sun-Earth_Moon angle'
sxaddpar, header55, 'PhsAn_N', phase_angle_M, ' Sun-Moon-Earth angle'
sxaddpar, header55, 'Isun', Isun , ' Sun intensity'
sxaddpar, header55, 'Iearth', Iearth, ' Earthshine intensity'

nameout1=strcompress('OUTPUT/lonlatSELimage_JD'+string(JD,format='(f15.7)')+'.fits',/remove_all)
writefits,nameout1,lonlatSELimage,header55
print,'Wrote image: ',nameout1
get_lun,chj
openw,chj,'Iearth.now'
printf,chj,Iearth
close,chj
free_lun,chj

nameout2=strcompress('OUTPUT/Angles_JD'+string(JD,format='(f15.7)')+'.fits',/remove_all)
writefits,nameout2,theta_i_and_r_and_phi,header55
print,'Wrote file ',nameout2
END
