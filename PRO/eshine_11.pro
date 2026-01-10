

PRO call_table,table,jd,l_out,b_out,paaxis_out,palimb_out
si=size(table,/dimensions)
ncols=5
nrows=si(1)
l_out=-911.1
b_out=-911.1
paaxis_out=-911.1
palimb_out=-911.1
for i=0,nrows-2,1 do begin
if (jd ge table(0,i) and jd lt table(0,i+1)) then begin
    jdfract=(jd-table(0,i))/(table(0,i+1)-table(0,i))
    l_out=table(1,i)+jdfract*(table(1,i+1)-table(1,i))
    b_out=table(2,i)+jdfract*(table(2,i+1)-table(2,i))
    paaxis_out=table(3,i)+jdfract*(table(3,i+1)-table(3,i))
    palimb_out=table(4,i)+jdfract*(table(4,i+1)-table(4,i))
endif
endfor
return
end


PRO get_libration,jd,l_out,b_out,paaxis_out,palimb_out
common remember,donethis,table
if (donethis eq 314) then begin
nBIG=10000
table=fltarr(5,nBIG)
file='libration.dat'
openr,68,file
line=''
astr=''
l=0.0
b=0.0
paaxis=0.0
palimb=0.0
i=0
while not eof(68) do begin
readf,68,line
astr=strmid(line,0,19)
l=float(strmid(line,20,8))
b=float(strmid(line,28,8))
paaxis=float(strmid(line,36,10))
palimb=float(strmid(line,46,10))
yy=fix(strmid(astr,0,4))
mm=fix(strmid(astr,5,2))
dd=fix(strmid(astr,8,2))
hh=fix(strmid(astr,12,2))
mi=fix(strmid(astr,15,2))
se=fix(strmid(astr,18,2))
table(0,i)=double(julday(mm,dd,yy,hh,mi,se))
table(1,i)=l
table(2,i)=b
table(3,i)=paaxis
table(4,i)=palimb
i=i+1
if (i-1 gt nBIG) then begin
    print,'nBIG is too small!'
    stop
endif
endwhile
close,68
table=table(*,0:i-1)
donethis=1
call_table,table,jd,l_out,b_out,paaxis_out,palimb_out
endif

if (donethis ne 314) then begin
    call_table,table,jd,l_out,b_out,paaxis_out,palimb_out
endif
return
end


FUNCTION removehotpixels,map
; removes pixels above a limit
idx=where(map gt 0.9*max(map),count)
  if (count GT 0) then map(idx)=0.3*map(idx)
return,map
end


PRO generateCCDimage,IN,OUT

common stuff,imsize,image,icount,x1,y1,x2,y2,if_show,device_str,if_poisson
LOCAL=double(IN)
; generates an image with counts between 0 and 60000, simulating a
; well exposed 16-bit exposed image, NB: 2^16 = 65536....
;
;  First scale the input image
maxval=60000.0d0
LOCAL=(LOCAL+min(LOCAL))      ; ; all values positive or 0
LOCAL=LOCAL/max(LOCAL)  ; all values between 0 and 1
LOCAL=LOCAL*maxval  ; all values between 0 and maxval
if (if_show eq 1) then begin
    window,1
    autohist,LOCAL;,xtitle='Pixel value (counts)', ytitle='N';,title='Simulated CCD image'
    wait,3
    window,0
endif
; then add Poison noise
old_LOCAL=LOCAL
l=size(LOCAL,/dimensions)
if (if_poisson eq 1) then begin
	for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin

		if (LOCAL(i,j) ne 0.0) then local(i,j)=RANDOMU(seed,poisson=LOCAL(i,j))

	endfor
	endfor
endif
; then set up the image as a sum of bias, sky background and readout noise...
biaslevel=100.
bias=LOCAL+biaslevel
skylevel=10.
sky =randomu(seed,l,poisson=skylevel)
; readoutnoise=LOCAL*0.0+readoutnoiselevel
; finally make the image into a long integer file
OUT=long(LOCAL+bias+sky)
return
end


PRO get_cursor,a,b,txt
; Reads the value of an image when the left mouse button is clicked
; returns coordinates of the click..

common stuff,imsize,image,icount,x1,y1,x2,y2,if_show,device_str,if_poisson
print,'Now click on '+txt
Cursor,a,b,/normal
a=imsize*a
b=imsize*b
print,txt+' coords:',a,b
print,'value:',image[a,b]
wait,1
return
end


FUNCTION SUNEARTHMOON_ANGLE,jd_in
; returns the angle (in DEGREES) between Sun-Earth-Moon - i.e. as seen from Earth
; code taken from a VB script at http://www.paulsadowski.com/WSH/moonphase.htm
;     ' Calculate illumination (synodic) phase
jd=jd_in+29.530588853/2.d0
V=(jd-2451550.1)/29.530588853
V=V-fix(V)
if (V lt 0) then  V=V+1
V=V*360. ; this is the angle as seen from the Moon between Sun and Earth
; V=360.-V    ; this is the angle as seen from Earth between Sun and Moon, i.e. the 'phase angle'
V = V - 180.0  ; nu blir det fasvinkeln sett från jorden
return,V
end




;===============================================================================
;
; PRO eshine_11
;
; Ver. 11
;
; A code to simulate Earthshine on the Moon as seen from Earth.
; This version sets the phase angle from the calendar, as well as
; librations (l,b), and distance to Sun and Moon and looks at
; local conditions affecting vissibility.
; Also adds Poisson counting statistics to pixels in CCD image
;
;===============================================================================
;
; Input:    - JD, the julian day (use double precision!)
;           - moon_albedo, moon_BRDF - specification of Moon's reflective properties
;           - earth_albedo, earth_BRDF - specification of Earth's reflective properties
;           - filter properties
;
; Ouput:    - outputimage, the resulting image
;
; Settings: - switches for output
;
; Common blocks:
; 'stuff':
;           - imsize, the image width (or height, it's quadratic)
;           - image, the rendered image, i.e. with Earthshine
;           - icount, a counter flag
;           - x1,y1,x2,y2, the coordinates of the two fiducial patches on the Moon, as set by cursor clicks
;           - if_show, control flag for display of lunar image
;           - device_str, either 'X' or 'Win' - for Unix and Windows systems, respectively
;           - if_poisson, flag to turn realistic counting statistics nise on (if 1) /off (if not 1)
;-----------------------------------------------------------

PRO eshine_core, JD, moon_albedo, moon_BRDF, earth_albedo, earth_BRDF, $
                 filter, filterfact, imagetoanalyse

common stuff,imsize,image,icount,x1,y1,x2,y2,if_show,device_str,if_poisson
common settings,Earth_Albedo_factor,factor,if_moon_visible,if_librate,if_variable_distances
common vars,phase_angle_E,illum_ratio,illum_ratio_err,k,doy,am

pixelscale=2.5*factor   ; arc seconds per pixel (small increases Moon size)
imsize=1025/factor

;--------------------------
; Set various constants.
;--------------------------
RADEG  = 180.0/!PI
DRADEG = 180.0D/!DPI





;-------------------------------------------------------------------
; Assign two image arrays: one real-valued and one with 8-bit pixels.
;-------------------------------------------------------------------
image = dblarr(imsize,imsize) * 0.0d0
image_8bit = bytarr(imsize,imsize) * byte(0)
image_16bitCCD=image




;===============================================================================
;=                                                                             =
;=  PART 1: Sun-Earth-Moon geometry incl. libration.                           =
;=          Observer's location.                                               =
;=          Matrixes to go between coordinate systems.                         =
;=                                                                             =
;===============================================================================


;------------------------------------------------------------------------
; Moon's and Sun's equatorial coordinates
; Earth-Moon distance
; Sun-Earth distance
; phase angles (elongations)
; Moon's illumination
;------------------------------------------------------------------------
AU = 149.6d+6       ; mean Sun-Earth distance     [km]
Rearth = 6365.0D    ; Earth radius                [km]
Rmoon = 1737.4D     ; Moon radius                 [km]
Dse = AU            ; default Sun-Earth distance  [km]
moonpos, JD, RAmoon, DECmoon, Dem
Dem = 384400.0D     ; default Earth-Moon distance [km]
sunpos, JD, RAsun, DECsun
xyz, JD-2400000.0, Xs, Ys, Zs, equinox=2000
Dse = AU
if (if_variable_distances eq 1) then begin
    Dse = sqrt(Xs^2 + Ys^2 + Zs^2)*AU
    moonpos, JD, RAmoon, DECmoon, Dem
endif
phase_angle_E = SUNEARTHMOON_ANGLE(JD)   ; Sun-Moon angle as seen from Earth
phase_angle_M = 180.0 - phase_angle_E    ; Sun-Earth angle as seen from Moon
illum_frac = (1 + cos(phase_angle_M/DRADEG))/2.0
;
; ALTERNATIV BERÄKNING AV FASVINKLAR OCH MÅNENS ILLUMINATION
; RAdiff = RAmoon - RAsun
; sign = +1
; if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then sign = -1
; phase_angle_E = sign*acos( sin(DECsun/DRADEG)*sin(DECmoon/DRADEG) + cos(DECsun/DRADEG)*cos(DECmoon/DRADEG)*cos(RAdiff/DRADEG) ) * DRADEG
; phase_angle_M = -atan( Dse*sin(phase_angle_E/DRADEG), Dem - Dse*cos(phase_angle_E/DRADEG) ) * DRADEG
; illum_frac = (1 + cos(phase_angle_M/DRADEG))/2.0


;--------------------------------------------------------
; Calculate the LHA at Greenwich for the vernal equinox.
; This is used to compute the GEO transformation matrixes.
;--------------------------------------------------------
ct2lst, LST, 0.0, 0, JD
GHAaries = 15.0D*LST


;-------------------------------------------------------
; Moon's libration - either from JD or specified by user.
;-------------------------------------------------------
if (JD GT 0.0 AND if_librate eq 1) then begin
  lon_lib = 0.0
  lat_lib = 0.0
  PAaxis_lib = 0.0
  PAlimb_lib = 0.0
  get_libration,jd,lon_lib,lat_lib,PAaxis_lib,PAlimb_lib
endif else begin
  lat_lib = 0.0
  lon_lib = 0.0
  PAaxis_lib = 0.0
  PAlimb_lib = 0.0
endelse


;------------------------------------------------------
; Transformation matrixes amongst MEEQ, EQ, SEL and GEO.
;------------------------------------------------------
ROTmeeq2sel  = CalcTransformMatrix('meeq2sel',  lat_lib, lon_lib, PAaxis_lib, 0.0, 0.0, 0.0)
ROTeq2meeq   = CalcTransformMatrix('eq2meeq',  DECmoon, RAmoon, 0.0, Dem, 0.0, 0.0)
ROTeq2geo    = CalcTransformMatrix('eq2geo',  0.0, GHAaries, 0.0, 0.0, 0.0, 0.0)


;--------------------------------------------------------
; Observatory location, description, and airmass for Moon.
;--------------------------------------------------------
observatory, 'lapalma', obs
observatory_longitude = obs.longitude
observatory_latitude  = obs.latitude
observatory_altitude  = obs.altitude
eq2hor, RAmoon, DECmoon, JD, moon_altitude, az, ha, LAT=observatory_latitude , LON=observatory_longitude , OBSNAME='lapalma' , $
        PRECESS_= 1, NUTATE_= 1, REFRACT_= 1, ABERRATION_= 1, ALTITUDE=observatory_altitude
am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, observatory_latitude*!dtor, observatory_longitude*!dtor)


;---------------------------------------------
; Observer's location in MEEQ coordinates [km].
;---------------------------------------------
if (if_variable_distances ne 1) then begin
; FORTFARANDE VID JORDENS CENTRUM
Xobs = double(Dem)
Yobs = double(0.0)
Zobs = double(0.0)
endif
;print,'old :',Xobs,Yobs,Zobs
;
;-- ALTERNATIV BERÆKNING OM MAN KÄNNER MÅNENS LOKALA TIMVINKEL OCH DEKLINATION --
if (if_variable_distances eq 1) then begin
hangle, JD, RAmoon*!dtor, DECmoon*!dtor, observatory_latitude, observatory_longitude, HAm, lst
; INPUTS:
;   JD  - Julian date (must be double precision to get nearest second).
;   RA  - Right ascension (of date) in radians.
;   DEC - Declination (of date) in radians.
;   LAT - Latitude of observatory in radians.
;   LON - West longitude of observatory in radians.
Xobs = Dem - Rearth*cos(HAm)*cos(DECmoon*!dtor)
Yobs = Rearth*sin(HAm)
Zobs = Rearth*cos(HAm)*sin(DECmoon*!dtor)
endif


;--------------------------------------------------------
; More transformation matrixes: MEEQ and IMEQ coordinates
;--------------------------------------------------------
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
;=  PART 2: Reflectance properties of Earth and Moon.                          =
;=          Sunshine incident on the Earth-Moon system.                        =
;=                                                                             =
;===============================================================================


;-------------
; Moon albedos
;-------------
; 0=uniform albedo (0.0720)
if (moon_albedo EQ 0) then begin
  ALBmoon = fltarr(1080,540) + 0.0720
; 1=Clementine albedos from file
endif else if (moon_albedo EQ 1) then begin
  X = read_ascii('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\moonalbedo.dat',data_start=0)
  ALBmoon = fix(X.field0001)
  ALBmoon = removehotpixels(ALBmoon)
endif


;--------------
; Earth albedos
;--------------
; 0=uniform albedo (0.3000)
if (earth_albedo EQ 0) then begin
  ALBearth = fltarr(360,180) + 0.300
; 1=albedo climatology from file
endif else if (earth_albedo EQ 1) then begin
  ;X = read_ascii('earth_climatology.alb',data_start=0)
  X = read_ascii('C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\earth.alb',data_start=0)
  ALBearth = X.field001
endif else if (earth_albedo EQ 2) then begin
 ALBearth = fltarr(360,180) + 0.5+0.5*sin(JD/1.0d0*2.0*!pi)
 print,' JD, ALBearth:',jd,mean(ALBearth)
endif


;------------
; Earth BRDFs
;------------
; 0=uniform BRDF (Lambert)
if (earth_BRDF EQ 0) then begin
  BRDFearth = intarr(360,180)
; 1=BRDF climatology from file
endif else if (earth_BRDF EQ 1) then begin
  X = read_ascii('earth_climatology.brdf',data_start=0)
  BRDFearth = fix(X.field001)
endif


;------------------------------------------------
; Compute the sunshine incident on Earth and Moon.
;------------------------------------------------
Isun_1AU = 1368.0
Isun     = Isun_1AU*(AU/Dse)^2




;===============================================================================
;=                                                                             =
;=  PART 3: For a given Sun-Earth-Moon geometry, determine the sunshine        =
;=          reflected off the Earth in the direction of the Moon. This         =
;=          reflected light forms the earthshine incident on the Moon.         =
;=                                                                             =
;===============================================================================


;--------------------------------------------
; Compute the earthshine incident on the Moon.
; Work in equatorial (EQ) coordinates.
;--------------------------------------------
Iearth = 0.0

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

  ; albedo for the sunshine incident on the Earth
  ALBe = ALBearth[ilon,ilat]*Earth_Albedo_factor

  ; BRDF for the sunshine incident on the Earth
  if (BRDFearth[ilon,ilat] EQ 0) then begin
    ; Lambertian surface
    if AoI LE !DPI/2 AND AoR LE !DPI/2 then begin
      BRDFse = cos(AoI)/(2*!DPI)
    endif else begin
      BRDFse = 0.0
    endelse
  endif else begin
    stop,'ERROR: BRDF for sunshine incident on the Earth.'
  endelse

  Iearth = Iearth + Isun*ALBe*BRDFse*surfarea*1.0/(Dem*Dem*1.0e6)

endfor
endfor

; fudge here
Iearth = Iearth*2.0

print, 'Isun, Iearth = ', Isun, Iearth




;===============================================================================
;=                                                                             =
;=  PART 4: Form the image pixel by pixel by adding the contributions from the =
;=          Moon and any other light in the field of view. Each pixel collects =
;=          light in a certain direction, and the light sources contributing   =
;=          to the pixel value are found by a simple form of ray tracing.      =
;=                                                                             =
;===============================================================================


;----------------------------------------------------------------------------
; For each CCD pixel, compute the incident light.
; Each pixel receives light from a certain solid angle in a certain direction.
;----------------------------------------------------------------------------
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

  ; if the ray from pixel {iy,iz} hits the Moon
  if hitMoon then begin

    ; lunar surface normal (in MEEQ)
    surfnormal = [1.0*cos(lonMEEQ/DRADEG)*cos(latMEEQ/DRADEG) , 1.0*sin(lonMEEQ/DRADEG)*cos(latMEEQ/DRADEG) , 1.0*sin(latMEEQ/DRADEG)]

    ; direction to the sun (in MEEQ)
    ; sundir = [cos(phase_angle_M/DRADEG) , sin(phase_angle_M/DRADEG) , 0.0]
    sundir = moon2sundir_MEEQ

    ; direction to the earth (MEEQ)
    earthdir = [1.0 , 0.0 , 0.0]

    ; direction to the observer (MEEQ)
    observdir = [Xobs , Yobs , Zobs] / sqrt(Xobs^2+Yobs^2+Zobs^2)

    ; get AoIs, AoIe, and AoR from scalar products with the lunar surface normal
    AoIs = acos(surfnormal##transpose(sundir))
    AoIe = acos(surfnormal##transpose(earthdir))
    AoR = acos(surfnormal##transpose(observdir))
    phi = acos(sundir##transpose(observdir))

    ; approximate width of pixel in SEL latitudes and longitudes
    res0 = 360.0*xIMEQ*tan(pixelscale/(3600.0*DRADEG)) / (2*!DPI*Rmoon)
    dlat = (res0/cos(AoR))*cos(lonSEL/DRADEG)
    dlon = res0/cos(AoR)
    Nabox_lat = max([1,round(dlat/0.3333333D)])
    Nabox_lon = max([1,round(dlon/0.3333333D)])

    ; mean albedo within the pixel field of view
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
    ALBm = mean(ALBmoon[jj,ii_min:ii_max])

    ; retrodirective function for the sunshine incident on the Moon
    g = 0.6
    if (phi EQ 0.0D) then begin
      B = 2.0
    endif else if (phi GT 0.0D AND phi LT (!DPI/2.0-0.00001)) then begin
      B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
    endif else if (phi GE (!DPI/2.0-0.00001)) then begin
      B = 1.0
    endif

    ; scattering function for the sunshine incident on the Moon
    t = 0.1
    S = (2.0/(3*!DPI)) * (sin(abs(phi)) + (!DPI-abs(phi)) * cos(abs(phi)))/!DPI + t*(1.0 - 0.5*cos(abs(phi)))^2

    ; BRDF for the sunshine incident on the Moon and reflected in the direction of the observer
    if (moon_BRDF EQ 0) then begin
      ; Lambertian surface
      if AoIs LE !DPI/2 AND AoR LE !DPI/2 then begin
        BRDFsm = cos(AoIs)/(2*!DPI)
      endif else begin
        BRDFsm = 0.0
      endelse
    endif else if (moon_BRDF EQ 1) then begin
      ; Hapke
      if AoIs LT !DPI/2 AND AoR LT !DPI/2 then begin
        BRDFsm =  B * S * 1.0/(1.0+cos(AoR)/cos(AoIs))
      endif else begin
        BRDFsm = 0.0
      endelse
    endif

    ; BRDF for the earthshine incident on the Moon and reflected in the direction of the observer
    if (moon_BRDF EQ 0) then begin
      ; Lambertian surface
      if AoIe LE !DPI/2 AND AoR LE !DPI/2 then begin
        BRDFem = cos(AoIe)/!DPI
      endif else begin
        BRDFem = 0.0
      endelse
    endif else if (moon_BRDF EQ 1) then begin
      ; Hapke
      if AoIe LT !DPI/2 AND AoR LT !DPI/2 then begin
        BRDFem =  2.0 * 0.2372 * 1.0/(1.0+cos(AoR)/cos(AoIe))
      endif else begin
        BRDFem = 0.0
      endelse
    endif

    ; form the image by adding the two components of the moonshine
    image[imsize/2+iy,imsize/2+iz] = double(Isun*ALBm*BRDFsm) + double(Iearth*ALBm*BRDFem)

  endif

endfor
endfor




;===============================================================================
;=                                                                             =
;=  PART 5: Discretize the real-valued intensity image to 8-bit pixels.        =
;=          Add CCD effects such as saturation, noise, etc.                    =
;=          Add filters.                                                       =
;=                                                                             =
;===============================================================================


if (icount eq 0) then begin

set_plot,device_str

if (device_str ne 'ps') then begin
window,0,xpos=0,ypos=0,xsize=imsize,ysize=imsize
tvscl,alog10(image+0.01)
endif
; Interim fixed settings for cursor positions
;get_cursor,x1,y1,'Grimaldi'
;get_cursor,x2,y2,'Crisium'
x1=55*factor/3
y1=157*factor/3
x2=271*factor/3
y2=206*factor/3

endif


;-------------------------------------------
; Create a new image array with 8-bit pixels.
;--------------------------------------------
imsaved=image
mphase,jd,k ; get the illuminated fraction of the Moon, if less than 50% filter the rhs, if more, thelhs
if (filter GE 1 and phase_angle_E le 180.0) then begin
  for iy=imsize/2,imsize-1 do image[iy,*] = image[iy,*]/float(filterfact)
endif
if (filter GE 1 and phase_angle_E gt 180.0) then begin
  for iy=0,imsize/2-1 do image[iy,*] = image[iy,*]/float(filterfact)
endif
generateCCDimage,image,CCDimage
image_8bit = bytscl(CCDimage)




;===============================================================================
;=                                                                             =
;=  PART 6: Analyze and plot.                                                  =
;=                                                                             =
;===============================================================================


imagetoanalyse=CCDimage

;--------------
; Analyze image
;--------------
hist = histogram(imagetoanalyse)


;-----
; Plot.
;-----

; windows on screen
if (if_show eq 1) then begin

set_plot,device_str

if (device_str ne 'ps') then  begin
    window,0,xpos=0,ypos=0,xsize=imsize,ysize=imsize
    tvscl,imagetoanalyse
endif
endif

;------------
; Perform photometry on the simulated image
;------------

;------------
; get the illumination ratio near points chosen with cursor, above
;------------
blockwidth=3
patch1=imagetoanalyse(x1-blockwidth:x1+blockwidth,y1-blockwidth:y1+blockwidth)
patch2=imagetoanalyse(x2-blockwidth:x2+blockwidth,y2-blockwidth:y2+blockwidth)
counts1=mean(patch1)
counts2=mean(patch2)
std1=stddev(patch1)
std2=stddev(patch2)
illum_ratio=counts1/counts2
illum_ratio_err=sqrt((std1/counts1)^2+(std2/counts2)^2)
fmt='(6(1x,f15.4))'
caldat,jd,mm,dd,yy,hh,mm,ss
doy=double(jd)-double(julday(1,1,yy))

if (if_moon_visible eq 1) then begin
    openw,33,'ratio.dat',/append
    printf,33,format=fmt,phase_angle_E,illum_ratio,illum_ratio_err,k,doy,am
    print,format='((a,1x,f6.1),2(a,1x,f8.1),3(a,1x,g9.3),a,1x,f9.3)','Ph.A.: ',phase_angle_E,' Gri: ',counts1,' Cri: ',counts2,' Gri/Cri: ',illum_ratio,' +/-: ',illum_ratio_err,' Ill.frac.: ',k,' doy: ',doy
    close,33
endif



;write_jpeg,strcompress('JPEGS/Moon_simulated_'+string(100+icount)+'.jpg',/remove_all),bytscl(imsaved)
icount=icount+1

return


END





;============================================
;    CALLING ROUTINE FOR eshine_10.pro
;============================================
;

common stuff,imsize,image,icount,x1,y1,x2,y2,if_show,device_str,if_poisson
common remember,donethis,table
common settings,Earth_Albedo_factor,factor,if_moon_visible,if_librate,if_variable_distances
common julian,mm,dd,yy,hh,mnt,sec,jd

Earth_Albedo_factor=3.00            ; Scaling factor for Earth albedo
if_show=1                                       ; see a picture of the Moon
factor=3.                                             ; a scaling-down factor for the picture
if_moon_visible=1                            ; produce a printout if 1
if_librate=0                                        ; =1 to enable an ephemeris-based libration calculation
if_variable_distances=0                 ; =1 to enable ephemeris-driven distances
donethis=314                                    ; a flag to control reading of libration table

; Moon reflectance specification
moon_albedo  = 1     ; 0=uniform (0.0720) , 1=Clementine albedos from file
moon_BRDF    = 1     ; 0=uniform (Lambert), 1=uniform(Hapke), 2=from file

; Earth reflectance specification
earth_albedo = 2     ; 0=uniform (0.3000) ,  1=albedo climatology from file, 2=time-dependent globally uniform albedo variation
earth_BRDF   = 0     ; 0=uniform (Lambert),  1=BRDF climatology from file

; earthshine filter
filter = 0
filterfact = 10000

; Poisson noise or not
if_poisson=0

icount=0

;--------------------------------------------
; Set the graphics device 'win', 'X', or 'ps'
;--------------------------------------------

device_str='win'
;device_str='X'

; observation time - julian date
mm  = 7            ; Observing month
dd  = 31           ; Observing day of that month
yy  = 2006         ; Observing year
hh  = 09           ; Observing hour UT
mnt = 19            ; Observing minute past that hour
sec = 0.0          ; Observing second past that minute
JD  = double(julday(mm,dd,yy,hh,mnt,sec))      ; the Julian date - watch out for rounding problems beyond 1/10'th day



jdstart = JD
jdstep =  1.0/24.
for JD=jdstart,jdstart+31.0,jdstep do begin

    print, 'JD = ', JD
    eshine_core, JD, moon_albedo, moon_BRDF, earth_albedo, earth_BRDF, filter, filterfact,outputimage
    writefits,strcompress('Moon_simulated_'+string(icount)+'.FIT',/remove_all),outputimage
endfor

end
