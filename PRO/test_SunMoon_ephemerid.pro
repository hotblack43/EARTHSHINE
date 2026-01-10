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





JD=systime(/julian)
SunMoon_ephemerid, JD, RAsun, DECsun, DISTsun, RAmoon, DECmoon, DISTmoon, lat_lib, lon_lib, PA_lib
print,'JD: ',JD
print,'SUN RA,Dec,Dist: ', RAsun, DECsun, DISTsun
print,'MOON RA,Dec,Moon: ', RAmoon, DECmoon, DISTmoon
print,'LIBRATION lat,lon, PA: ', lat_lib, lon_lib, PA_lib
end
