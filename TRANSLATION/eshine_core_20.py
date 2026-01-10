#!/usr/bin/env python

import os
import time
import numpy as np

#=============================================================================== 
# 
# FUNCTION CalcTransformMatrix 
# 
# Compute transformation matrixes for conversion between coordinate systems. 
# 
# SEL  :  Rectangular selenographic coordinates 
# MEEQ :  Moon-centred Earth-directed Equatorial system 
# EMEQ :  Earth-centred Moon-directed Equatorial system 
# IMEQ :  Image-centred Moon-directed Equatorial system 
# GEO  :  Rectangular geographic coordinates 
# EQ   ;  Rectangular equatorial coordinates 
# 
# Ver. 2007-03-28 
# 
#=============================================================================== 
 
def  CalcTransformMatrix, transform, lat, lon, phi, Xorig, Yorig, Zorig 
     
     
    transform = strcompress(transform,/rem) 
     
    DRADEG = 180.0/3.1415926535 
    RADEG  = 180.0/!PI 
     
    if strcmp(transform,'meeq2sel',/fold_case): 
         
        Rz = dblarr(3,3) 
        Ry = dblarr(3,3) 
        Rx = dblarr(3,3) 
         
        lat =:uble(lat) 
        lon =:uble(lon) 
        phi =:uble(phi) 
         
        thetaZ = lon/DRADEG 
        thetaY = -lat/DRADEG 
        thetaX = -phi/DRADEG 
         
        # the following steps transform SEL axes into MEEQ axes 
        # assume initially that SEL and MEEQ Z-axes coincide 
         
        # rotation around the original Z-axis 
        Rz[:,0] = [ cos(thetaZ) ,-sin(thetaZ) ,   0.0   ] 
        Rz[:,1] = [ sin(thetaZ) , cos(thetaZ) ,   0.0   ] 
        Rz[:,2] = [    0.0      ,    0.0      ,   1.0   ] 
         
        # rotation around the new Y-axis (observe the rotation direction) 
        Ry[:,0] = [ cos(thetaY) ,   0.0    , sin(thetaY) ] 
        Ry[:,1] = [    0.0      ,   1.0    ,     0.0     ] 
        Ry[:,2] = [-sin(thetaY) ,   0.0    , cos(thetaY) ] 
         
        # rotation around the new X-axis 
        Rx[:,0] = [   1.0    ,    0.0      ,   0.0       ] 
        Rx[:,1] = [   0.0    , cos(thetaX) ,-sin(thetaX) ] 
        Rx[:,2] = [   0.0    , sin(thetaX) , cos(thetaX) ] 
         
        R = ((Rz## Ry) ## Rx) 
         
     else if strcmp(transform,'sel2meeq',/fold_case): 
         
        Rz = dblarr(3,3) 
        Ry = dblarr(3,3) 
        Rx = dblarr(3,3) 
         
        lat =:uble(lat) 
        lon =:uble(lon) 
        phi =:uble(phi) 
         
        thetaZ = -lon/DRADEG 
        thetaY = lat/DRADEG 
        thetaX = phi/DRADEG 
         
        # the following steps transform MEEQ axes into SEL axes 
         
        # rotation around the X-axis 
        Rx[:,0] = [   1.0    ,    0.0      ,   0.0       ] 
        Rx[:,1] = [   0.0    , cos(thetaX) ,-sin(thetaX) ] 
        Rx[:,2] = [   0.0    , sin(thetaX) , cos(thetaX) ] 
         
        # rotation around the Y-axis (observe the rotation direction) 
        Ry[:,0] = [ cos(thetaY) ,   0.0    , sin(thetaY) ] 
        Ry[:,1] = [    0.0      ,   1.0    ,     0.0     ] 
        Ry[:,2] = [-sin(thetaY) ,   0.0    , cos(thetaY) ] 
         
        # rotation around the Z-axis 
        Rz[:,0] = [ cos(thetaZ) ,-sin(thetaZ) ,   0.0    ] 
        Rz[:,1] = [ sin(thetaZ) , cos(thetaZ) ,   0.0    ] 
        Rz[:,2] = [    0.0      ,    0.0      ,   1.0    ] 
         
        R = ((Rx## Ry) ## Rz) 
         
     else if strcmp(transform,'meeq2emeq',/fold_case) OR strcmp(transform,'emeq2meeq',/fold_case): 
         
        T  = dblarr(4,4) 
        Rz = dblarr(4,4) 
        R  = dblarr(4,4) 
         
        Dx =:uble(Xorig) 
        Dy = 0.0  
        Dz = 0.0  
         
        # the following steps transform EMEQ axes into MEEQ axes or vice versa 
         
        # translation in MEEQ/EMEQ coordinates 
        T[:,0] = [  1.0  ,  0.0  ,  0.0   ,  Dx  ] 
        T[:,1] = [  0.0  ,  1.0  ,  0.0   ,  Dy  ] 
        T[:,2] = [  0.0  ,  0.0  ,  1.0   ,  Dz  ] 
        T[:,3] = [  0.0  ,  0.0  ,  0.0   , 1.0  ] 
         
        # rotation around the MEEQ/EMEQ Z-axis 
        Rz[:,0] = [ -1.0  ,  0.0  ,  0.0   , 0.0   ] 
        Rz[:,1] = [  0.0  , -1.0  ,  0.0   , 0.0  ] 
        Rz[:,2] = [  0.0  ,  0.0  ,  1.0   , 0.0  ] 
        Rz[:,3] = [  0.0  ,  0.0  ,  0.0   , 1.0  ] 
         
        R = (T## Rz) 
         
     else if strcmp(transform,'meeq2imeq',/fold_case): 
         
        T  = dblarr(4,4) 
        Rz = dblarr(4,4) 
        Ry = dblarr(4,4) 
        Rx = dblarr(4,4) 
        R  = dblarr(4,4) 
         
        Dx =:uble(Xorig) 
        Dy =:uble(Yorig) 
        Dz =:uble(Zorig) 
        thetaZ = (-1.0 *(atan(Dy,Dx)*DRADEG + 180.0) MOD 360)/DRADEG 
        thetaY = -atan(Dz/sqrt(Dx**2+Dy**2)) 
         
        # the following steps transform IMEQ axes into MEEQ axes 
         
        # rotation around the original IMEQ Y-axis (observe the rotation direction) 
        Ry[:,0] = [ cos(thetaY) ,    0.0       , sin(thetaY) , 0.0  ] 
        Ry[:,1] = [   0.0       ,    1.0       ,   0.0       , 0.0  ] 
        Ry[:,2] = [-sin(thetaY) ,    0.0       , cos(thetaY) , 0.0  ] 
        Ry[:,3] = [    0.0      ,    0.0       ,   0.0       , 1.0  ] 
         
        # rotation around the new Z-axis 
        Rz[:,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0   , 0.0  ] 
        Rz[:,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0   , 0.0  ] 
        Rz[:,2] = [   0.0       ,    0.0       ,  1.0   , 0.0  ] 
        Rz[:,3] = [   0.0       ,    0.0       ,  0.0   , 1.0  ] 
         
        # translation from IMEQ origin to MEEQ origin in the new cordinate system 
        T[:,0] = [    1.0       ,    0.0       ,  0.0   , -Dx   ] 
        T[:,1] = [    0.0       ,    1.0       ,  0.0   , -Dy   ] 
        T[:,2] = [    0.0       ,    0.0       ,  1.0   , -Dz   ] 
        T[:,3] = [    0.0       ,    0.0       ,  0.0   , 1.0   ] 
         
        R = ((Ry## Rz) ## T) 
         
     else if strcmp(transform,'imeq2meeq',/fold_case): 
         
        T  = dblarr(4,4) 
        Rz = dblarr(4,4) 
        Ry = dblarr(4,4) 
        Rx = dblarr(4,4) 
        R  = dblarr(4,4) 
         
        Dx =:uble(Xorig) 
        Dy =:uble(Yorig) 
        Dz =:uble(Zorig) 
        thetaZ = ((atan(Dy,Dx)*DRADEG + 180.0) MOD 360)/DRADEG 
        thetaY = atan(Dz/sqrt(Dx**2+Dy**2)) 
         
        # the following steps transform MEEQ axes into IMEQ axes 
         
        # translation from origin to the observer's location 
        T[:,0] = [    1.0       ,    0.0       ,  0.0   ,  Dx   ] 
        T[:,1] = [    0.0       ,    1.0       ,  0.0   ,  Dy   ] 
        T[:,2] = [    0.0       ,    0.0       ,  1.0   ,  Dz   ] 
        T[:,3] = [    0.0       ,    0.0       ,  0.0   , 1.0   ] 
         
        # rotation around the Z-axis 
        Rz[:,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0   , 0.0  ] 
        Rz[:,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0   , 0.0  ] 
        Rz[:,2] = [   0.0       ,    0.0       ,  1.0   , 0.0  ] 
        Rz[:,3] = [   0.0       ,    0.0       ,  0.0   , 1.0  ] 
         
        # rotation around the new IMEQ Y-axis (observe the rotation direction) 
        Ry[:,0] = [ cos(thetaY) ,    0.0       , sin(thetaY) , 0.0  ] 
        Ry[:,1] = [   0.0       ,    1.0       ,   0.0       , 0.0  ] 
        Ry[:,2] = [-sin(thetaY) ,    0.0       , cos(thetaY) , 0.0  ] 
        Ry[:,3] = [    0.0      ,    0.0       ,   0.0       , 1.0  ] 
         
        R = ((T## Rz) ## Ry) 
         
     else if strcmp(transform,'eq2meeq',/fold_case): 
         
        T  = dblarr(4,4) 
        Rz = dblarr(4,4) 
        Ry = dblarr(4,4) 
        Rx = dblarr(4,4) 
        R  = dblarr(4,4) 
         
        Dx =:uble(Xorig) 
        Dy = 0.0 
        Dz = 0.0 
        thetaY =:uble(0.0-lat)/DRADEG 
        thetaZ =:uble(180.0-lon)/DRADEG 
         
        # the following steps transform MEEQ axes into EQ axes 
         
        # translation from MEEQ origin to EQ origin 
        T[:,0] = [    1.0      ,    0.0      ,  0.0  ,  Dx   ] 
        T[:,1] = [    0.0      ,    1.0      ,  0.0  ,  Dy   ] 
        T[:,2] = [    0.0      ,    0.0      ,  1.0  ,  Dz   ] 
        T[:,3] = [    0.0      ,    0.0      ,  0.0  , 1.0  ] 
         
        # rotation around the Y-axis (observe the rotation direction) 
        Ry[:,0] = [ cos(thetaY) ,    0.0      , sin(thetaY) , 0.0 ] 
        Ry[:,1] = [   0.0      ,    1.0      ,   0.0      , 0.0 ] 
        Ry[:,2] = [-sin(thetaY) ,    0.0      , cos(thetaY) , 0.0 ] 
        Ry[:,3] = [    0.0     ,    0.0      ,   0.0      , 1.0 ] 
         
        # rotation around the Z-axis 
        Rz[:,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0  , 0.0 ] 
        Rz[:,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0  , 0.0 ] 
        Rz[:,2] = [   0.0      ,    0.0      ,  1.0  , 0.0 ] 
        Rz[:,3] = [   0.0      ,    0.0      ,  0.0  , 1.0 ] 
         
        R = ((T## Ry) ## Rz) 
         
     else if strcmp(transform,'meeq2eq',/fold_case): 
         
        T  = dblarr(4,4) 
        Rz = dblarr(4,4) 
        Ry = dblarr(4,4) 
        Rx = dblarr(4,4) 
        R  = dblarr(4,4) 
         
        Dx =:uble(Xorig) 
        Dy = 0.0 
        Dz = 0.0 
        thetaY =:uble(lat)/DRADEG 
        thetaZ =:uble(lon-180.0)/DRADEG 
         
        # the following steps transform EQ axes into MEEQ axes 
         
        # rotation around the Z-axis 
        Rz[:,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0  , 0.0 ] 
        Rz[:,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0  , 0.0 ] 
        Rz[:,2] = [   0.0      ,    0.0      ,  1.0  , 0.0 ] 
        Rz[:,3] = [   0.0      ,    0.0      ,  0.0  , 1.0 ] 
         
        # rotation around the Y-axis (observe the rotation direction) 
        Ry[:,0] = [ cos(thetaY) ,    0.0      , sin(thetaY) , 0.0 ] 
        Ry[:,1] = [   0.0      ,    1.0      ,   0.0      , 0.0 ] 
        Ry[:,2] = [-sin(thetaY) ,    0.0      , cos(thetaY) , 0.0 ] 
        Ry[:,3] = [    0.0     ,    0.0      ,   0.0      , 1.0 ] 
         
        # translation from EQ origin to MEEQ origin 
        T[:,0] = [    1.0      ,    0.0      ,  0.0  , -Dx   ] 
        T[:,1] = [    0.0      ,    1.0      ,  0.0  , -Dy   ] 
        T[:,2] = [    0.0      ,    0.0      ,  1.0  , -Dz   ] 
        T[:,3] = [    0.0      ,    0.0      ,  0.0  , 1.0  ] 
         
        R = ((Rz## Ry) ## T) 
         
     else if strcmp(transform,'eq2geo',/fold_case): 
         
        Rz = dblarr(4,4) 
        R  = dblarr(4,4) 
         
        thetaZ =:uble(-lon)/DRADEG 
         
        # the following step transform GEO axes into EQ axes 
         
        # rotation around the Z-axis 
        Rz[:,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0  , 0.0 ] 
        Rz[:,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0  , 0.0 ] 
        Rz[:,2] = [   0.0      ,    0.0      ,  1.0  , 0.0 ] 
        Rz[:,3] = [   0.0      ,    0.0      ,  0.0  , 1.0 ] 
         
        R = (Rz) 
         
     else if strcmp(transform,'geo2eq',/fold_case): 
         
        Rz = dblarr(4,4) 
        R  = dblarr(4,4) 
         
        thetaZ =:uble(lon)/DRADEG 
         
        # the following step transform EQ axes into GEO axes 
         
        # rotation around the Z-axis 
        Rz[:,0] = [ cos(thetaZ) , -sin(thetaZ) ,  0.0  , 0.0 ] 
        Rz[:,1] = [ sin(thetaZ) ,  cos(thetaZ) ,  0.0  , 0.0 ] 
        Rz[:,2] = [   0.0      ,    0.0      ,  1.0  , 0.0 ] 
        Rz[:,3] = [   0.0      ,    0.0      ,  0.0  , 1.0 ] 
         
        R = (Rz) 
         
    else: 
         
        import pdb; pdb.set_trace(),'ERROR: in CalcRotMatrix.' 
         
     
    return R 
     
     
 
 
#=============================================================================== 
# 
# PRO SunMoon_ephemerid 
# 
# Compute Sun and Moon positions (RA, DEC, DIST) and Moon libration parameters 
# (sub-terrestrial and sub-solar points on the Moon) from the julian date. 
# 
# The central formula for Moon position is approximate. Finer details 
# like physical (as opposed to optical) libration and the nutation have 
# been neglected. Formulas have been simplified from Meeus 'Astronomical 
# Algorithms' (1st Ed) Chapter 51 (sub-earth and sub-solar points, PA of 
# pole and Bright Limb, Illuminated fraction). The libration figures are 
# usually 0.05 to 0.2 degree different from the results given by Harry 
# Jamieson's 'Lunar Observer's Tool Kit' DOS program. Some of the code is 
# adapted from a BASIC program by George Rosenberg (ALPO). 
# 
# Ver. 2007-03-01 
# 
#=============================================================================== 
 
def SunMoon_ephemerid, JD, RAsun, DECsun, DISTsun, RAmoon, DECmoon, DISTmoon, lat_lib, lon_lib, PA_lib 
     
     
    d2r = 3.1415926535/180.0 # degrees to radians, double precision 
     
    caldat, JD, mon, d, yr, h, mnt, sec 
     
    # Alternative conversion to year, month, day, hour, minute 
    # when date is given in the form YYYYMMDD.hhmm 
    # g = 20000222.0843  
    # yr  = fix(floor(g / 10000)) 
    # mon = fix(floor( (g - yr*10000.0) / 100)) 
    # d   = fix(floor(g - yr*10000.0 - mon*100.0 )) 
    # bit = (g - floor(g))*100.0 
    # h   = fix(floor(bit)) 
    # mnt = fix(floor(bit*100.0 - h*100.0 + 0.5)) 
     
    # error checking 
    bk = 0 
    if (yr < 1800 OR yr > 2200): 
        import pdb; pdb.set_trace(), 'ERROR: date must be between the years 1800 and 2200.' 
    if (mon < 1 OR mon > 12): 
        import pdb; pdb.set_trace(), 'ERROR: months are not right.' 
    # check the month/day/year combination 
    leap = isleap(yr) 
    a = 1 
    if (d <= 0) : 
        a = 0 
    if ((mon == 2) AND (leap == 1) AND (d > 29)) : 
        a= 0 
    if ((mon == 2) AND (d > 28) AND (leap == 0)) : 
        a = 0 
    if (((mon == 4) OR (mon == 6) OR (mon == 9) OR (mon == 11)) AND d > 30) : 
        a = 0 
    if (d > 31) : 
        a = 0 
    dayOK = a 
    if (dayOK == 0): 
        import pdb; pdb.set_trace(), 'Error: wrong number of days for the month or not a leap year.' 
    if (h < 0 OR h > 23): 
        import pdb; pdb.set_trace(), 'ERROR: hours are not right.' 
    if (mnt > 59): 
        import pdb; pdb.set_trace(), 'ERROR: minutes are not right.' 
     
    # get the number of days since J2000.0 
    days = day2000(yr,mon,d,h+mnt/60.0) 
    t = days / 36525.0 
     
    # Sun formulas 
    # 
    # L1  - Mean longitude 
    # M1  - Mean anomaly 
    # C1  - Equation of centre 
    # V1  - True anomaly 
    # Ec1 - Eccentricity 
    # R1  - Sun distance 
    # Th1 - Theta (true longitude) 
    # Om1 - Long Asc Node (Omega) 
    # Lam1- Lambda (apparent longitude) 
    # Obl - Obliquity of ecliptic 
    # Ra1 - Right Ascension 
    # Dec1- Declination 
     
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
     
     
    # Moon formulas 
    # 
    # F   - Argument of latitude (F) 
    # L2  - Mean longitude (L') 
    # Om2 - Long. Asc. Node (Om') 
    # M2  - Mean anomaly (M') 
    # D   - Mean elongation (D) 
    # D2  - 2 * D 
    # R2  - Lunar distance (Earth - Moon distance) 
    # R3  - Distance ratio (Sun / Moon) 
    # Bm  - Geocentric Latitude of Moon 
    # Lm  - Geocentric Longitude of Moon 
    # HLm - Heliocentric longitude 
    # HBm - Heliocentric latitude 
    # Ra2 - Lunar Right Ascension 
    # Dec2- Declination 
     
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
    Lm = Lm + 0.2136 * dsin(2*M2) - 0.1851 * dsin(M1) - 0.1143 * dsin(2 * F)# 
    Lm = Lm + 0.0588 * dsin(D2 - 2*M2) 
    Lm = Lm + 0.0572* dsin(D2 - M1 - M2) + 0.0533* dsin(D2 + M2) 
    Lm = Lm + L2 
    Ra2 = datan2(dsin(Lm) * dcos(Obl) - dtan(Bm)* dsin(Obl), dcos(Lm)) 
    Dec2 = dasin(dsin(Bm)* dcos(Obl) + dcos(Bm)*dsin(Obl)*dsin(Lm)) 
    HLm = range(Lam1 + 180.0 + (180.0/!PI) * R3 * dcos(Bm) * dsin(Lam1 - Lm)) 
    HBm = R3 * Bm 
     
     
    # Selenographic coords of the sub Earth point. 
    # This gives the (geocentric) libration 
    # approximating to that listed in most almanacs 
     
    # Physical libration ignored, as is nutation. 
     
    # I   - Inclination of (mean) lunar orbit to ecliptic 
    # EL  - Selenographic longitude of sub Earth point 
    # EB  - Sel Lat of sub Earth point 
    # W   - angle variable 
    # X   - Rectangular coordinate 
    # Y   - Rectangular coordinate 
    # A   - Angle variable (see Meeus ch 51 for notation) 
     
    I = 1.54242 
    W = Lm - Om2 
    Y = dcos(W) * dcos(Bm) 
    X = dsin(W) * dcos(Bm) * dcos(I) - dsin(Bm) * dsin(I) 
    A = datan2(X, Y) 
    EL = A - F 
    EB = dasin(-dsin(W) * dcos(Bm) * dsin(I) - dsin(Bm) * dcos(I)) 
     
    # Selenographic coords of sub-solar point. This point is 
    # the 'pole' of the illuminated hemisphere of the Moon 
    # and so describes the position of the terminator on the 
    # lunar surface. The information is communicated through 
    # numbers like the colongitude, and the longitude of the 
    # terminator. 
     
    # SL  - Sel Long of sub-solar point 
    # SB  - Sel Lat of sub-solar point 
    # W, Y, X, A  - temporary variables as for sub-Earth point 
    # Co  - Colongitude of the Sun 
    # SLt - Selenographic longitude of terminator 
    # riset - Lunar sunrise or set 
     
    W = range(HLm - Om2) 
    Y = dcos(W) * dcos(HBm) 
    X = dsin(W) * dcos(HBm) * dcos(I) - dsin(HBm) * dsin(I) 
    A = datan2(X, Y) 
    SL = range(A - F) 
    SB = dasin(-dsin(W) * dcos(HBm) * dsin(I) - dsin(HBm) * dcos(I)) 
     
    if (SL < 90.0): 
        Co = 90.0 - SL 
    else: 
        Co = 450.0 - SL 
     
    if ((Co > 90.0) AND (Co < 270.0)): 
        SLt = 180.0 - Co 
    else: 
        if (Co < 90.0): 
            SLt = 0 - Co 
        else: 
            SLt = 360.0 - Co 
     
     
    # Calculate the illuminated fraction, the position angle of the bright 
    # limb, and the position angle of the Moon's rotation axis. All position 
    # angles relate to the North Celestial Pole - you need to work out the 
    # 'Parallactic angle' to calculate the orientation to your local zenith. 
     
    #--- Iluminated fraction 
    A = dcos(Bm) * dcos(Lm - Lam1) 
    Psi = 90.0 - datan(A / sqrt(1.0-A*A)) 
    X = R1 * dsin(Psi) 
    Y = R3 - R1* A 
    Il = datan2(X, Y) 
    K = (1.0 + dcos(Il))/2.0 
     
    #--- PA bright limb 
    X = dsin(Dec1) * dcos(Dec2) - dcos(Dec1) * dsin(Dec2) * dcos(Ra1 - Ra2) 
    Y = dcos(Dec1) * dsin(Ra1 - Ra2) 
    P1 = datan2(Y, X) 
     
    #--- PA Moon's rotation axis 
    #--- Neglects nutation and physical libration, so Meeus' angle V is just Om2 
    X = dsin(I) * dsin(Om2) 
    Y = dsin(I) * dcos(Om2) * dcos(Obl) - dcos(I) * dsin(Obl) 
    W = datan2(X, Y) 
    A = sqrt(X*X + Y*Y) * dcos(Ra2 - W) 
    P2 = dasin(A / dcos(EB)) 
     
    goto,jump 
    print( 'Libration in Lat (EB) = ', EB 
    print( 'Libration in Lon (EL) = ', EL 
    print( 'Colongitude of Sun (Co) = ', Co 
    print( 'Subsolar point Lat (SB) = ', SB 
    print( 'Subsolar point Lon (SL) = ', SL 
    print( 'Sel lon of terminator (SLt) = ', SLt 
    # form.SelIlum.value = round(K, 3); 
    # form.SelPaBl.value = round(P1, 1); 
    # form.SelPaPole.value = round(P2, 1); 
    jump: 
     
    #--- Sun 
    RAsun    = Ra1/15.0 
    DECsun   = Dec1 
    DISTsun  = R1 
     
    #--- Moon 
    RAmoon   = Ra2/15.0 
    DECmoon  = Dec2 
    DISTmoon = R2*60.268511 
     
    #--- libration 
    lat_lib  = EB 
    lon_lib  = EL 
    PA_lib   = P2 
     
     
 
 
 
 
 
 
#====================================== 
# Fractional number of days since J2000 
#====================================== 
# 
def day2000, yr, mon, day, hr 
    if (mon == 1) OR (mon == 2): 
        yr = yr - 1 
        mon = mon + 12 
    a = floor(yr/100.0) 
    b = 2.0 - a  + floor(a/4.0) 
    c = floor(365.25 * yr) 
    d1 = floor(30.6001 * (mon + 1)) 
    return  (b + c + d1 - 730550.5 + day + hr/24.0) 
 
 
 
 
 
#============================= 
# Leap year detecting function. 
#============================= 
 
def isleap, yr 
    a = 0 
    if ((yr MOD 4) == 0) : 
        a = 1 
    if ((yr MOD 100) == 0) : 
        a = 0 
    if ((yr MOD 400) == 0) : 
        a = 1 
    return  a 
 
 
 
 
#========================================================= 
# Trigonometric functions working in degrees - this just 
# makes implementing the formulas in books easier. 
# The 'range' function brings angles into range 0 to 360, 
# and an atan2(x,y) function returns arctan in correct 
# quadrant. ipart(x) returns smallest integer nearest zero. 
#========================================================= 
# 
def dsin, x 
    return  sin(x*(!PI/180.0)) 
 
# 
def dcos, x 
    return  cos(x*(!PI/180.0)) 
 
# 
def dtan, x 
    return  tan(x*(!PI/180.0)) 
 
# 
def dasin, x 
    return  (180.0/!PI) * asin(x) 
 
# 
def dacos, x 
    return  (180.0/!PI) * acos(x) 
 
# 
def datan, x 
    return  (180.0/!PI) * atan(x) 
 
# 
def datan2, y, x 
    if ((x == 0.0) AND (y == 0.0)): 
        return  0 
    else: 
        a = datan(y/x) 
        if (x < 0.0): 
            a = a + 180.0 
        if (y < 0.0 AND x > 0.0): 
            a = a + 360.0 
        return  a 
 
# 
def ipart, x 
    if (x > 0.0): 
        a = floor(x) 
    else: 
        a = ceil(x) 
    return  a 
 
# 
def range, x 
    b = x / 360.0 
    a = 360.0 * (b - ipart(b)) 
    if (a < 0.0): 
        a = a + 360.0 
    return  a 
 
 
 
 
 
#============================================== 
# Month and day number checking function. 
# This will work OK for Julian or Gregorian 
# providing isleap() is defined appropriately. 
# Returns 1 if Month and Day combination OK, 
# and 0 if month and day combination impossible. 
#============================================== 
# 
def goodmonthday, yr, mon, day 
    leap = isleap(yr) 
    a = 1 
    if (day <= 0) : 
        a = 0 
    if ((mon == 2) AND (leap == 1) AND (day > 29)) : 
        a= 0 
    if ((mon == 2) AND (day > 28) AND (leap == 0)) : 
        a = 0 
    if (((mon == 4) OR (mon == 6) OR (mon == 9) OR (mon == 11)) AND day > 30) : 
        a = 0 
    if (day > 31) : 
        a = 0 
    return  a 
 
#=============================================================================== 
# 
# PRO eshine_core 
# 
# A code to generate simulated images of the Moon as seen from Earth. The 
# Moon is illuminated by Sunshine and Earthshine, where the Earthshine is 
# caused by reflection off the Earth. 
# 
# The viewing geometry, the lunar librations, and the Sun-Earth-Moon distances 
# can be set from an ephemeris. 
# 
# The generated image is 'ideal' i.e. there are no sky, noise or CCD effects. 
# The final image is returned in two versions: image_16bit (the ideal image 
# stored as floating point, but scaled to simulate a well-exposed 16-bit frame) 
# and image_I (the same, but without scaling). 
# 
# Version 20 - has keyword for the Single Scattering Albedo of Earth, and one 
# for the 'g' factor in Hapkes formula. 
# and also returns a 'mask' showing us the sunlit part of the Moon 
# And also returns a map of the earth showing where the light is falling. 
# 
# Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute 
# 
#=============================================================================== 
 
 
def eshine_core_20, JD, phase_angle, lat_lib, lon_lib, PA_lib,                                  obsname, obssys, Xobs_in, Yobs_in, Zobs_in,                                 moon_albedo, moon_BRDF, earth_albedo, earth_albedo_uniform_value, hapkeG, 		 earth_BRDF, datalib, imsize, pixelscale,                   $                 if_moon_visible, if_librate, if_variable_distances,                         image_I, image_16bit, image_info, mask, MAPofEARTH 
    #compile_opt idl2, hidden 
    common phases,phase_angle_M, phase_angle_E 
     
    print("This is eshine_core_20.def with a provision for scaling the Clementine map to Wildey levels" 
    #Print,"Currently Clementine IS scaled to Wildey!" 
    print("Currently Clementine is scaled to Wildey aand:further scaled by eye!" 
     
    # NOTE: Check lines near 930 for inclusion of the scaled map etc 
    #----------------------------------------------------------------------- 
    # Set various constants. 
    #----------------------------------------------------------------------- 
    RADEG  = 180.0/!PI 
    DRADEG = 180.0/3.1415926535 
     
     
    #----------------------------------------------------------------------- 
    # Assign image arrays:  image       - work space 
    #                       image_I     - 'ideal image' 
    #                       image_16bit - 'ideal image' but scaled to 16 bits 
    #----------------------------------------------------------------------- 
    image       = dblarr(imsize,imsize) * 0.0
    image_I     = dblarr(imsize,imsize) * 0.0
    image_16bit = dblarr(imsize,imsize) * 0.0
    mask        = dblarr(imsize,imsize) * 0.0
     
     
     
    #=============================================================================== 
    #=                                                                             = 
    #=  1. Sun-Earth-Moon geometry incl. libration.                                = 
    #=     Observer's location.                                                    = 
    #=     Matrixes to go between coordinate systems.                              = 
    #=                                                                             = 
    #=============================================================================== 
     
     
    #------------------------------------------------------------------------ 
    # Moon's and Sun's equatorial coordinates 
    # Earth-Moon distance 
    # Sun-Earth distance 
    # phase angles (elongations) 
    # Moon's illumination 
    #------------------------------------------------------------------------ 
    JD =:uble(JD) 
    AU = 149.6e+6# mean Sun-Earth distance     [km] 
    Rearth = 6365.0# Earth radius                [km] 
    Rmoon = 1737.4# Moon radius                 [km] 
    Dse = AU# default Sun-Earth distance  [km] 
    Dem = 384400.0# default Earth-Moon distance [km] 
    if (JD > 0.0): 
        moonpos, JD, RAmoon, DECmoon, Dem 
        sunpos, JD, RAsun, DECsun 
        xyz, JD-2400000.0, Xs, Ys, Zs, equinox=2000 
        if (if_variable_distances == 1): 
            Dse = sqrt(Xs**2 + Ys**2 + Zs**2)*AU 
            Dem = Dem 
        else: 
            Dse = AU 
            Dem = 384400.0
    else: 
        RAmoon  =:uble(phase_angle) 
        DECmoon = 0.0 
        RAsun   = 0.0 
        DECsun  = 0.0 
    RAdiff = RAmoon - RAsun 
    sign = +1 
    if (RAdiff > 180.0) OR (RAdiff < 0.0 AND RAdiff > -180.0) : 
        sign = -1 
    phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG 
    phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG 
    illum_frac = (1 + cos(phase_angle_M/DRADEG))/2.0 
     
     
    #-------------------------------------------------------- 
    # Calculate the LHA at Greenwich for the vernal equinox. 
    # This is used to compute the GEO transformation matrixes. 
    #-------------------------------------------------------- 
    if (JD > 0.0): 
        ct2lst, LST, 0.0, 0, JD 
        GHAaries = 15.0*LST 
    else: 
        GHAaries =:uble(phase_angle) 
     
     
    #------------------------------------------------ 
    # Calculate Moon's libration from the Julian Date. 
    #------------------------------------------------ 
    if (JD > 0.0 AND if_librate == 1): 
        SunMoon_ephemerid, JD, RAs, DECs, DISTs, RAm, DECm, DISTm, lat_lib, lon_lib, PA_lib 
        print(JD, RAs, DECs, DISTs, RAm, DECm, DISTm, lat_lib, lon_lib, PA_lib 
    else: 
        lat_lib = 0.0 
        lon_lib = 0.0 
        PA_lib  = 0.0 
     
     
    #------------------------------------------------------ 
    # Transformation matrixes amongst MEEQ, EQ, SEL and GEO. 
    #------------------------------------------------------ 
    ROTmeeq2sel  = CalcTransformMatrix('meeq2sel',  lat_lib, lon_lib, PA_lib, 0.0, 0.0, 0.0) 
    ROTsel2meeq  = CalcTransformMatrix('sel2meeq',  lat_lib, lon_lib, PA_lib, 0.0, 0.0, 0.0) 
    ROTmeeq2eq   = CalcTransformMatrix('meeq2eq',  DECmoon, RAmoon, 0.0, Dem, 0.0, 0.0) 
    ROTeq2meeq   = CalcTransformMatrix('eq2meeq',  DECmoon, RAmoon, 0.0, Dem, 0.0, 0.0) 
    ROTgeo2eq    = CalcTransformMatrix('geo2eq',  0.0, GHAaries, 0.0, 0.0, 0.0, 0.0) 
    ROTeq2geo    = CalcTransformMatrix('eq2geo',  0.0, GHAaries, 0.0, 0.0, 0.0, 0.0) 
    ROTmeeq2geo  = CalcTransformMatrix('meeq2eq',  DECmoon, RAmoon-GHAaries, 0.0, Dem, 0.0, 0.0) 
    ROTgeo2meeq  = CalcTransformMatrix('eq2meeq',  DECmoon, RAmoon-GHAaries, 0.0, Dem, 0.0, 0.0) 
     
    # print, 'LIB: ', lat_lib, lon_lib, PA_lib 
    # poleSEL = [0.0, 0.0, Rmoon] 
    # zeroSEL = [Rmoon, 0.0, 0.0] 
    # print, 'poleSEL  = ', poleSEL[0], poleSEL[1], poleSEL[2] 
    # print, 'zeroSEL  = ', zeroSEL[0], zeroSEL[1], zeroSEL[2] 
    # poleMEEQ = ROTsel2meeq ## poleSEL 
    # zeroMEEQ = ROTsel2meeq ## zeroSEL 
    # print, 'poleMEEQ = ', poleMEEQ[0], poleMEEQ[1], poleMEEQ[2] 
    # print, 'zeroMEEQ = ', zeroMEEQ[0], zeroMEEQ[1], zeroMEEQ[2] 
    # print, ' ' 
    # print, 'PA = ', !RADEG*atan(poleMEEQ[1]/poleMEEQ[2]) 
    # poleSEL = ROTmeeq2sel ## poleMEEQ 
    # zeroSEL = ROTmeeq2sel ## zeroMEEQ 
    # print, 'poleSEL  = ', poleSEL[0], poleSEL[1], poleSEL[2] 
    # print, 'zeroSEL  = ', zeroSEL[0], zeroSEL[1], zeroSEL[2] 
     
     
    #-------------------------------------------------------- 
    # Airmass for the Moon. 
    #-------------------------------------------------------- 
    #if strcmp(obssys,'GEO',/fold_case) AND NOT strcmp(obsname,'Earth''s center',/fold_case) AND NOT strcmp(obsname,'DMI',/fold_case) then begin 
    #  observatory, obsname, obs 
    #  am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, obs.latitude*!dtor, obs.longitude*!dtor) 
    #endif else if strcmp(obsname,'DMI',/fold_case) then begin 
    #  am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, 55.60*!dtor, 347.30*!dtor) 
    #endif else begin 
    #  am = 0.0 
    #endelse 
     
     
    #--------------------------------------------- 
    # Observer's location in MEEQ coordinates [km]. 
    #--------------------------------------------- 
    if (if_variable_distances == 1): 
        if strcmp(obssys,'MEEQ',/fold_case): 
            Xobs =:uble(Xobs_in) 
            Yobs =:uble(Yobs_in) 
            Zobs =:uble(Zobs_in) 
         else if strcmp(obssys,'GEO',/fold_case): 
            XYZ_MEEQ = ROTgeo2meeq## [[Xobs_in],[Yobs_in],[Zobs_in],[1]] 
            Xobs = XYZ_MEEQ[0] 
            Yobs = XYZ_MEEQ[1] 
            Zobs = XYZ_MEEQ[2] 
            # print, Xobs, Yobs, Zobs 
            # GHAmoon = GHAaries - RAmoon 
            # LHAmoon = GHAmoon + atan(Yobs_in/Xobs_in)*DRADEG 
            # Xobs = Dem - Rearth*cos(LHAmoon*!dtor)*cos(DECmoon*!dtor) 
            # Yobs = Rearth*sin(LHAmoon*!dtor) 
            # Zobs = Rearth*cos(LHAmoon*!dtor)*sin(DECmoon*!dtor) 
            # print, LHAmoon, DECmoon 
            # print, Xobs, Yobs, Zobs 
        else: 
            import pdb; pdb.set_trace(), 'ERROR: observer''s location given in unknown coordinates.' 
    else: 
        Xobs =:uble(Dem) 
        Yobs =:uble(0.0) 
        Zobs =:uble(0.0) 
     
     
    #------------------------------------------- 
    # More transformation matrixes:  MEEQ<->IMEQ 
    #------------------------------------------- 
    ROTmeeq2imeq = CalcTransformMatrix('meeq2imeq', 0.0, 0.0, 0.0, Xobs, Yobs, Zobs) 
    ROTimeq2meeq = CalcTransformMatrix('imeq2meeq', 0.0, 0.0, 0.0, Xobs, Yobs, Zobs) 
     
     
    #------------------------- 
    # Directional unit vectors 
    #------------------------- 
    earthpos_EQ = [0.0 , 0.0 , 0.0] 
    moonpos_EQ  = Dem*[cos(DECmoon/DRADEG)*cos(RAmoon/DRADEG) , cos(DECmoon/DRADEG)*sin(RAmoon/DRADEG) , sin(DECmoon/DRADEG)] 
    sunpos_EQ   = Dse*[cos(DECsun/DRADEG)*cos(RAsun/DRADEG) , cos(DECsun/DRADEG)*sin(RAsun/DRADEG) , sin(DECsun/DRADEG)] 
    earthpos_MEEQ = [Dem , 0.0 , 0.0] 
    moonpos_MEEQ  = [0.0 , 0.0 , 0.0] 
    sunpos_MEEQ   = ROTeq2meeq## [[sunpos_EQ[0]],[sunpos_EQ[1]],[sunpos_EQ[2]],[1]] 
    sunpos_MEEQ   = sunpos_MEEQ[0:2] 
    # 
    earth2moondir_EQ = moonpos_EQ/Dem 
    earth2sundir_EQ  = sunpos_EQ/Dse 
    moon2sundir_MEEQ   = sunpos_MEEQ[0:2]/sqrt(sunpos_MEEQ[0]**2+sunpos_MEEQ[1]**2+sunpos_MEEQ[2]**2) 
    moon2earthdir_MEEQ = [1.0 , 0.0 , 0.0] 
    earth2sundir_MEEQ  = (sunpos_MEEQ - earthpos_MEEQ) / norm(sunpos_MEEQ-earthpos_MEEQ,/double) 
     
     
     
     
    #=============================================================================== 
    #=                                                                             = 
    #=  2.1 Reflection properties of Earth and Moon.                               = 
    #=                                                                             = 
    #=============================================================================== 
     
     
    #----------------------------------------------------------------------- 
    # Moon reflectivity: 
    # given in terms of normal albedo PNORM, i.e. the reflectivity at the 
    # standard viewing geometry (phi=i=30, e=0) 
    #----------------------------------------------------------------------- 
    if (moon_albedo == 0): 
        # 0 -> uniform reflectivity 0.0720 
        PNORMmoon = fltarr(1080,540) + 0.0720 
     else if (moon_albedo == 1): 
        # ; 1 -> Clementine/HIRES 750 nm reflectivity 
        # X = read_ascii(datalib+'/'+'HIRES_750_3ppd.alb',data_start=0) 
        # 1 -> Clementine/HIRES 750 nm reflectivity SCALED to match the gross features of the Wildey map 
        # X = read_ascii(datalib+'/'+'HIRES_750_3ppd_scaled_to_WIldey.alb',data_start=0) 
        # 1 -> Clementine/HIRES 750 nm reflectivity SCALED to conserve mean value and dampen SD to 90% 
        X = read_ascii(datalib+'/'+'SPECIAL.HIRES_750_3ppd_scaled_to_WIldey.alb',data_start=0) 
        PNORMmoon = float(X.field1)# this may be a GDL vs IDL thing? 
        #PNORMmoon = float(X.field0001) 
     
     
    #----------------------------------------------------------------------- 
    # Earth reflectivity: 
    # given in terms of hemispheric albedo RHO 
    #----------------------------------------------------------------------- 
    if (earth_albedo == 0): 
        # 0 -> uniform albedo set to user-input value 
        RHOearth = fltarr(360,180)*0.0 + earth_albedo_uniform_value 
     else if (earth_albedo == 1): 
        # 1 -> cloud-free Earth 
        #---- 
        # I thought reading from a binary file would speed up the code - it appears it did not 
        # fetch_terrestrial_albedo_map,indx0,indx1,indx2,indx3,indx4,indx5,indx6,indx7,indx,	;      count0,count1,count2,count3,count4,count5,count6,count7,count 
        #---- 
        #  X = read_ascii(datalib+'\'+'Earth.1d.map',data_start=0) 
        X = read_ascii(datalib+'/'+'Earth.1d.map',data_start=0) 
        indx0 , = np.where(X.field001 == 0,count0)# water 
        indx1 , = np.where(X.field001 == 1,count1)# ice 
        indx2 , = np.where(X.field001 == 2,count2)# land 
        indx3 , = np.where(X.field001 == 3,count3)# land 
        indx4 , = np.where(X.field001 == 4,count4)# land 
        indx5 , = np.where(X.field001 == 5,count5)# land 
        indx6 , = np.where(X.field001 == 6,count6)# land 
        indx7 , = np.where(X.field001 == 7,count7)# ice 
        indx  , = np.where(X.field001 < 0 OR X.field001 > 7, count) 
        if (count > 0) : 
            import pdb; pdb.set_trace(),'ERROR: in the input file Earth.1d.map' 
        RHOearth = fltarr(360,180) 
        if (count0 > 0) :# water 
            RHOearth[indx0] = 0.100 
        if (count1 > 0) :# ice 
            RHOearth[indx1] = 0.900 
        if (count2 > 0) :# land 
            RHOearth[indx2] = 0.650 
        if (count3 > 0) :# land 
            RHOearth[indx3] = 0.650 
        if (count4 > 0) :# land 
            RHOearth[indx4] = 0.650 
        if (count5 > 0) :# land 
            RHOearth[indx5] = 0.650 
        if (count6 > 0) :# land 
            RHOearth[indx6] = 0.650 
        if (count7 > 0) :# ice 
            RHOearth[indx7] = 0.900 
     else if (earth_albedo == 2): 
        # 2 -> time-varying but spatially uniform albedo 
        RHOearth = fltarr(360,180) + 0.300 + 0.03*sin(JD/1.0*2.0*3.1415926535) 
    print(' JD, ALBearth:', JD, np.mean(RHOearth) 
     
    # must flip North to SOuth and vice versa or map does not correspond to 
    # direction of loop over lon and lat 
     
    RHOearth=np.flip(RHOearth,2) 
     
    # Must also - apparently - shift map in longitude 180 degrees 
     
    RHOearth=shift(RHOearth,180) 
     
    #----------------------------------------------------------------------- 
    # Moon BRDF parameters: 
    # Get the parameter OMEGA from the normal albedo PNORM. 
    # The relation between these two depend on the type of BRDF assumed. 
    #----------------------------------------------------------------------- 
    tvalue=0.2# and experiment - increases DS counts by 40% by doubling from t=0.1 
    tvalue=0.1# Hapke 63 value 
    if (moon_BRDF == 0): 
        # 0 -> Lambert 
        OMEGAmoon = PNORMmoon/(cos(30./DRADEG)/3.1415926535) 
     else if (moon_BRDF == 1): 
        # 1 -> Hapke -63. JGR 1963 68, pp. 4571-4586. 
        g=hapkeG 
        tan30degrees=tan(30./DRADEG) 
        #B = 2.0 - (tan(30./DRADEG)/(2.*g)) * (1.0 - exp(-g/tan(30./DRADEG))) * (3.0 - exp(-g/tan(30./DRADEG))) 
        B = 2.0 - (tan30degrees/(2.*g)) * (1.0 - exp(-g/tan30degrees)) * (3.0 - exp(-g/tan30degrees)) 
        S = (2.0/(3*3.1415926535)) * ( (sin(30./DRADEG) + (3.1415926535-30./DRADEG)*cos(30./DRADEG))/3.1415926535 + tvalue*(1.0 - 0.5*cos(30./DRADEG))**2 ) 
        g30 = B*S# 0.228068 
        LS30 = cos(30./DRADEG) / (cos(30./DRADEG) + cos(0.0/DRADEG))# 0.464102 
        OMEGAmoon = PNORMmoon/(g30*LS30) 
     
     
    #----------------------------------------------------------------------- 
    # Earth BRDF parameters 
    # Get the single-scattering albedo OMEGA from the hemispheric albedo RHO. 
    # The relation between these two depend on the type of BRDF assumed. 
    #----------------------------------------------------------------------- 
    if (earth_BRDF == 0): 
        # 0 -> Lambert (uniform) 
        BRDFearth = intarr(360,180) 
        OMEGAearth  = RHOearth 
     else if (earth_BRDF == 1): 
        # 1 -> Hapke-type BRDFs for a cloud-free Earth according to Ford et al. 
        X = read_ascii(datalib+'/'+'Earth.1d.map',data_start=0) 
        BRDFearth = fix(X.field001) 
     
     
     
    #=============================================================================== 
    #=                                                                             = 
    #=  2.2 Topographic shadowing of the sunshine.                                 = 
    #=                                                                             = 
    #=============================================================================== 
     
     
    #--------------------------------------------- 
    # Moon's topography from Clementine/LIDAR data. 
    #--------------------------------------------- 
    # X = read_ascii(datalib+'\'+'clem_topogrid2.dat',data_start=0) 
    # TOPOmoon = X.field0001 
     
     
     
     
    #=============================================================================== 
    #=                                                                             = 
    #=  2.3 Sunshine incident on the Earth-Moon system.                            = 
    #=                                                                             = 
    #=============================================================================== 
     
     
    #------------------------------------------------ 
    # Compute the sunshine incident on Earth and Moon. 
    #------------------------------------------------ 
    Isun_1AU = 1368.0 
    Isun     = Isun_1AU*(AU/Dse)**2 
     
     
     
     
    #=============================================================================== 
    #=                                                                             = 
    #=  3. For a given Sun-Earth-Moon geometry, determine the sunshine             = 
    #=     reflected off the Earth in the direction of the Moon. This              = 
    #=     reflected light forms the earthshine incident on the Moon.              = 
    #=                                                                             = 
    #=============================================================================== 
     
     
    #-------------------------------------------- 
    # Compute the earthshine incident on the Moon. 
    # Work in equatorial (EQ) coordinates. 
    #-------------------------------------------- 
    Iearth = 0.0 
     
    for idec in range(179+1): 
        for ira in range(359+1): 
             
            # position on Earth in equatorial declination and right ascension, and in geographic lat and long 
            dec =:uble(idec-89.5) 
            ra  =:uble(ira+0.5) 
            lat = dec 
            lon = ra - GHAaries 
            ilat = idec 
            ilon = floor((lon+360) MOD 360) 
             
            # surface normal and area (m2) of the grid box (in EQ) 
            surfnormal = [1.0*cos(ra/DRADEG)*cos(dec/DRADEG) , 1.0*sin(ra/DRADEG)*cos(dec/DRADEG) , 1.0*sin(dec/DRADEG)] 
            surfarea = cos(dec/DRADEG) * (Rearth*1000.0)**2 * (1.0/DRADEG) * (1.0/DRADEG) 
             
            # direction to the Sun (in EQ) 
            sundir = earth2sundir_EQ 
             
            # direction to the Moon (in EQ) 
            # moondir = [cos((phase_angle_E)/DRADEG) , sin((phase_angle_E)/DRADEG) , 0.0] 
            moondir = earth2moondir_EQ 
             
            # get AoI and AoR from scalar products with the surface normal 
            AoI = acos(surfnormal##transpose(sundir)) 
            AoR = acos(surfnormal##transpose(moondir)) 
            phi = acos(sundir##transpose(moondir)) 
             
            # BRDF for the sunshine incident on the Earth 
            if (BRDFearth[ilon,ilat] == 0): 
                #--- Lambert --- 
                if (AoI <= 3.1415926535/2) AND (AoR <= 3.1415926535/2): 
                    BRDFse = OMEGAearth[ilon,ilat]/3.1415926535 
                else: 
                    BRDFse = 0.0 
            else: 
                import pdb; pdb.set_trace(),'ERROR: only Lambert reflection has been implemented for Earth.' 
             
            thing =  BRDFse*Isun*cos(AoI)*surfarea*cos(AoR)*1.0/(Dem*Dem*1.0e6) 
            Iearth = Iearth + thing 
            MAPofEARTH(ilon,ilat)=thing 
             
     
    Iearth = Iearth[0] 
     
    mphase,jd,k 
    print(format='(a,f20.5,1x,2(f20.7,1x),2(f10.5,1x))', 'JD, Isun, Iearth, ph_M, ph_E = ', JD,Isun, Iearth, phase_angle_M, phase_angle_E 
    printf,83,format='(a,f20.5,1x,2(f20.7,1x),2(f10.5,1x))', 'JD, Isun, Iearth, ph_M, ph_E = ', JD,Isun, Iearth, phase_angle_M, phase_angle_E 
     
    #=============================================================================== 
    #=                                                                             = 
    #=  4. Form the image pixel by pixel by adding the contributions from the      = 
    #=     Moon and any other light in the field of view. Each pixel collects      = 
    #=     light in a certain direction, and the light sources contributing        = 
    #=     to the pixel value are found by a simple form of ray tracing.           = 
    #=                                                                             = 
    #=============================================================================== 
     
     
    #---------------------------------------------------------------------------- 
    # For each image pixel, compute the incident light. 
    # Each pixel receives light from a certain solid angle in a certain direction. 
    #---------------------------------------------------------------------------- 
    # Nabox_lon = intarr(imsize,imsize) * 0 
    # Nabox_lat = intarr(imsize,imsize) * 0 
     
    lonlatSELimage=fltarr(imsize,imsize,2)# array to hold lunar lon and lat 
    theta_i_and_r_and_phi=fltarr(imsize,imsize,3)# array to hold theta_i and theta_r and the direction to Earth centre 
     
    for iy in np.arange(-imsize/2,imsize/2+1): 
        for iz in np.arange(-imsize/2,imsize/2+1): 
             
            # pixel locations in radians - measured from image center: Y=left, Z=up 
            im_y = pixelscale*(double(iy)/3600.0)/DRADEG 
            im_z = pixelscale*(double(iz)/3600.0)/DRADEG 
             
            # mapping of pixels onto lunar surface in IMEQ coordinates, 
            # followed by conversion to MEEQ and SEL coordinates 
            mu2  = tan(im_y)**2 + tan(im_z)**2 
            limb = Rmoon**2 / ((Xobs**2+Yobs**2+Zobs**2) - Rmoon**2) 
            if mu2 < limb: 
                hitMoon = 1 
                HL = (1.0/(double(1.0)+mu2)) * ( Rmoon**2 - (Xobs**2+Yobs**2+Zobs**2)*mu2/(double(1.0)+mu2) ) 
                t = sqrt(Xobs**2+Yobs**2+Zobs**2)/(double(1.0)+mu2) - sqrt(HL) 
                xIMEQ = t 
                yIMEQ = t*tan(-im_y) 
                zIMEQ = t*tan(im_z) 
                # 
                # IMEQ to MEEQ coordinates 
                xyzMEEQ = ROTimeq2meeq## [[xIMEQ],[yIMEQ],[zIMEQ],[1]] 
                xMEEQ = xyzMEEQ[0] 
                yMEEQ = xyzMEEQ[1] 
                zMEEQ = xyzMEEQ[2] 
                # xMEEQ = Dem - t 
                # yMEEQ = t*tan(im_y) 
                # zMEEQ = t*tan(im_z) 
                rMEEQ = sqrt(xMEEQ**2 + yMEEQ**2 + zMEEQ**2) 
                latMEEQ = DRADEG*atan(zMEEQ/sqrt(xMEEQ**2 + yMEEQ**2)) 
                lonMEEQ = DRADEG*atan(yMEEQ,xMEEQ) 
                # 
                # MEEQ to SEL coordinates 
                xyzSEL = ROTmeeq2sel## [[xMEEQ],[yMEEQ],[zMEEQ]] 
                xSEL = xyzSEL[0] 
                ySEL = xyzSEL[1] 
                zSEL = xyzSEL[2] 
                rSEL = sqrt(xSEL**2 + ySEL**2 + zSEL**2) 
                latSEL = DRADEG*atan(zSEL/sqrt(xSEL**2 + ySEL**2)) 
                lonSEL = DRADEG*atan(ySEL,xSEL) 
                if (rMEEQ-rSEL) > 0.0001 : 
                    import pdb; pdb.set_trace(),'ERROR: in conversion between MEEQ and SEL.' 
            else: 
                hitMoon = 0 
                latMEEQ = !VALUES.F_NaN 
                lonMEEQ = !VALUES.F_NaN 
             
            # generate map of selenographic coordinates 
            if (iy+imsize/2 >= 0 and iy+imsize/2 < imsize and iz+imsize/2 >= 0 and iz+imsize/2 < imsize): 
                if(hitMoon): 
                lonlatSELimage(iy+imsize/2, iz+imsize/2,0)=lonSEL 
                lonlatSELimage(iy+imsize/2,  iz+imsize/2,1)=latSEL 
            else: 
                lonlatSELimage(iy+imsize/2, iz+imsize/2,0)=-999 
                lonlatSELimage(iy+imsize/2, iz+imsize/2,1)=-999 
         
        # if the ray from pixel {iy,iz} hits the Moon 
        if hitMoon: 
             
            # lunar surface normal (in MEEQ) 
            surfnormal = [1.0*cos(lonMEEQ/DRADEG)*cos(latMEEQ/DRADEG) , 1.0*sin(lonMEEQ/DRADEG)*cos(latMEEQ/DRADEG) , 1.0*sin(latMEEQ/DRADEG)] 
             
            # direction to the sun (in MEEQ) 
            # sundir = [cos(phase_angle_M/DRADEG) , sin(phase_angle_M/DRADEG) , 0.0] 
            sundir = moon2sundir_MEEQ 
             
            # direction to the earth (in MEEQ) 
            earthdir = [1.0 , 0.0 , 0.0] 
             
            # direction to the observer (in MEEQ) 
            observdir = [Xobs , Yobs , Zobs] / sqrt(Xobs**2+Yobs**2+Zobs**2) 
             
            # get AoIs, AoIe, and AoR from scalar products with the lunar surface normal 
            AoIs = acos(surfnormal##transpose(sundir)) 
            AoIe = acos(surfnormal##transpose(earthdir)) 
            AoR  = acos(surfnormal##transpose(observdir)) 
            phi  = abs( acos(sundir##transpose(observdir)) ) 
             
            # also store the directions to SUn and Observer as a map across the sunlit side of the Moon 
            theta_i_and_r_and_phi(iy+imsize/2,  iz+imsize/2, 0)=reform(AoIs) 
            theta_i_and_r_and_phi(iy+imsize/2,  iz+imsize/2, 1)=reform(AoR) 
            theta_i_and_r_and_phi(iy+imsize/2,  iz+imsize/2, 2)=reform(AoIe) 
             
            # approximate width of pixel in SEL latitudes and longitudes 
            res0 = 360.0*xIMEQ*tan(pixelscale/(3600.0*DRADEG)) / (2*3.1415926535*Rmoon) 
            dlat = (res0/cos(AoR))*cos(lonSEL/DRADEG) 
            dlon = res0/cos(AoR) 
            Nabox_lat = max([1,int(np.round(dlat/0.3333333))]) 
            Nabox_lon = max([1,int(np.round(dlon/0.3333333))]) 
             
            # mean OMEGA within the pixel field of view 
            # Nabox_lat = 1 
            # Nabox_lon = 1 
            ii = floor(3*(latSEL+90.0)) 
            jj = floor(3*((360.0+lonSEL) MOD 360)) 
            if Nabox_lon >= 5: 
                jj = [jj-2,jj-1,jj,(jj+1) MOD 1080,(jj+2) MOD 1080] 
             else if Nabox_lon >= 2: 
                jj = [jj-1,jj,(jj+1) MOD 1080] 
            ii_min = max([ii-Nabox_lat/2,0]) 
            ii_max = min([ii+Nabox_lat/2,539]) 
            OMEGA = np.median(OMEGAmoon[jj,ii_min:ii_max]) 
            # OMEGA = mean(OMEGAmoon[jj,ii_min:ii_max]) 
             
            # Hapke -63 phase function for the sunshine incident on the Moon 
            g = hapkeG 
            if (phi == 0.0): 
                B = 2.0 
             else if (phi > 0.0 AND phi < (3.1415926535/2.0-0.00001)): 
                B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi))) 
             else if (phi >= (3.1415926535/2.0-0.00001)): 
                B = 1.0 
            S = (2.0/(3*3.1415926535)) * ( (sin(phi) + (3.1415926535-phi)*cos(phi))/3.1415926535 + tvalue*(1.0 - 0.5*cos(phi))**2 ) 
            fphHapke63 = B*S 
             
            # BRDF for the sunshine incident on the Moon and reflected in the direction of the observer 
            if (moon_BRDF == 0): 
                # Lambert 
                if (AoIs <= 3.1415926535/2) AND (AoR <= 3.1415926535/2): 
                    BRDFsm = OMEGA/3.1415926535 
                else: 
                    BRDFsm = 0.0 
             else if (moon_BRDF == 1): 
                # Hapke -63 
                if (AoIs < 3.1415926535/2) AND (AoR < 3.1415926535/2): 
                    BRDFsm =  OMEGA * fphHapke63 * 1.0/(cos(AoIs)+cos(AoR)) 
                else: 
                    BRDFsm = 0.0 
                #print,'AoIs,AoR:',AoIs,AoR 
             
            # BRDF for the earthshine incident on the Moon and reflected in the direction of the observer 
            if (moon_BRDF == 0): 
                # Lambert 
                if (AoIe <= 3.1415926535/2) AND (AoR <= 3.1415926535/2): 
                    BRDFem = OMEGA/3.1415926535 
                else: 
                    BRDFem = 0.0 
             else if (moon_BRDF == 1): 
                # Hapke -63 
                if (AoIe < 3.1415926535/2) AND (AoR < 3.1415926535/2): 
                    BRDFem =  OMEGA * 2.0 * 0.2372 * 1.0/(cos(AoIe)+cos(AoR)) 
                else: 
                    BRDFem = 0.0 
             
            # form the image by adding the two components of the moonshine 
            image[imsize/2+iy,imsize/2+iz] =:uble(BRDFsm*Isun*cos(AoIs)) +:uble(BRDFem*Iearth*cos(AoIe)) 
            # generate also a 'mask' that contains only the sunlit part of the Moon 
            mask[imsize/2+iy,imsize/2+iz] =:uble(BRDFsm*Isun*cos(AoIs)) 
             
         
 
indx , = np.where(image < 0.0,count) 
if (count > 0) : 
    import pdb; pdb.set_trace(),'ERROR: ray-tracing produced negative intensities.' 
 
 
 
 
#=============================================================================== 
# 
# 5. Store two versions of the generated image: 
# 
#      image_I      -  the actual radiances from the Moon, without sky, filters, 
#                      Poisson noise, or CCD effects. 
# 
#      image_16bit  -  the same ideal image, still floating-point but now scaled 
#                      to simulate a well-exposed 16-bit CCD frame 
# 
#=============================================================================== 
 
 
#----------------------------------------------------------------------- 
# The 'ideal image' of the object 
#----------------------------------------------------------------------- 
image_I = image 
 
 
#----------------------------------------------------------------------- 
# The 'ideal image' of the object, but scaled to 90% of 16 bits 
#----------------------------------------------------------------------- 
maxval = 0.90*65535.0 
image_16bit = maxval*image/max(image) 
 
#=============================================================================== 
#=                                                                             = 
#=  6. Gather image information.                                               = 
#=                                                                             = 
#=============================================================================== 
 
 
#----------------------------------- 
# Create the image information array. 
#----------------------------------- 
Nchars = strlen(obsname) 
if (Nchars < 15): 
    fill = '' 
    for ii in np.arange(Nchars,15): 
        fill = fill + ' ' 
 
image_info = {info, JD:JD,                                                                        obsname:obsname+fill, Xobs:Xobs, Yobs:Yobs, Zobs:Zobs,                        pixelscale:pixelscale,                                                        RAmoon:RAmoon, DECmoon:DECmoon, Dem:Dem,                                      RAsun:RAsun, DECsun:DECsun, Dse:Dse,                                          lat_lib:lat_lib, lon_lib:lon_lib, PA_lib:PA_lib,                              phase_angle_E:phase_angle_E, phase_angle_M:phase_angle_M,                     Isun:Isun, Iearth:Iearth } 
# generate a FITS header, instead of the INFO file structure 
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
outname17 = strcompress('OUTPUT/LONLAT_AND_ANGLES_IMAGES/lonlatSELimage_JD'+string(JD,format='(f15.7)')+'.fits',/remove_all) 
print(outname17 
writefits,outname17,lonlatSELimage,header55 
get_lun,chj 
openw,chj,'Iearth.now' 
printf,chj,Iearth 
close,chj 
free_lun,chj 
 
writefits,strcompress('OUTPUT/LONLAT_AND_ANGLES_IMAGES/Angles_JD'+string(JD,format='(f15.7)')+'.fits',/remove_all),theta_i_and_r_and_phi,header55 
 
 
