

; goto,plott


;---------------------------------
; Options: Moon albedos and BRDFs
;          Earth albedos and BRDFs
;---------------------------------
moon_albedo  = 1     ; 0=constant, 1=from Clementine images
moon_BRDF    = 1     ; 1=Hapke+Jensen, 2=Minnaert, 3=Lambert (perfectly diffusive)
earth_albedo = 0
earth_BRDF   = 0
number=180.
sunangle=number-65.47


;----------------------------
; Set various coefficients.
; Read albedo data from files.
;----------------------------
d_moon = 384400.0   ; km
r_moon = 1737.4     ; km
Isun_1AU = 1870.0   ; W/m2
;
if (moon_albedo EQ 0) then begin
  Amoon = 0.072
endif else if (moon_albedo EQ 1) then begin
  X = read_ascii('moonalbedo.dat',data_start=0)
  Aclementine = fix(X.field0001)
  goto,endtv
  ;
  set_plot,'win'
  window,0,xpos=0,ypos=0,xsize=1082,ysize=542
  tv,Aclementine
  indxLO = where(Aclementine LT 160,count)
  indxHI = where(Aclementine GE 160,count)
  Aclementine[indxLO] = 0
  Aclementine[indxHI] = 255
  window,1,xpos=0,ypos=560,xsize=1082,ysize=542
  tv,Aclementine
  stop
  ;
  endtv:
  indx = where(Aclementine GE 160,count)
  if (count GT 0) then Aclementine[indx] = 160
  Aclementine = Aclementine/1300.0
  X = 0
endif



;-------------------------------------------------------------
; Assign two image arrays: one real-valued and one byte-valued.
;-------------------------------------------------------------
image = fltarr(1025,1025) * 0.0
image_8bit = bytarr(1025,1025) * byte(0)



;------------------------------------------
; Compute the sunshine incident on the Moon.
;------------------------------------------
Isun = Isun_1AU



;--------------------------------------------
; Compute the earthshine incident on the Moon.
;--------------------------------------------
Iearth = Isun_1AU/1e-6



;-------------------------------------------------
; Compute the moonshine incident on the CCD pixels
; for an observer at the center of the Earth.
;-------------------------------------------------
for iy=-512,512 do begin
for iz=-512,512 do begin

  ; pixel locations in radians - measured from image center
  im_y = 2.5*(float(iy)/3600.0)/!RADEG
  im_z = 2.5*(float(iz)/3600.0)/!RADEG

  ; lunar surface in "seleno"-graphical coordinates
  lat_moon = !RADEG*asin( tan(im_z)*d_moon/r_moon )
  if finite(lat_moon) then begin
    lon_moon = !RADEG*asin( tan(im_y)*d_moon/(r_moon*cos(lat_moon/!RADEG)) )
  endif else begin
    lon_moon = !VALUES.F_NaN
  endelse


  ; if the ray from pixel {iy,iz} hits the Moon
  if finite(lat_moon) and finite(lon_moon) then begin

    ; lunar surface location in moon-centered rectangular coordinates
    Xmoon = r_moon * cos(lon_moon/!RADEG) * cos(lat_moon/!RADEG)
    Ymoon = r_moon * sin(lon_moon/!RADEG) * cos(lat_moon/!RADEG)
    Zmoon = r_moon * sin(lat_moon/!RADEG)

    ; lunar surface normal
    surfnormal = [1.0*cos(lon_moon/!RADEG)*cos(lat_moon/!RADEG) , 1.0*sin(lon_moon/!RADEG)*cos(lat_moon/!RADEG) , 1.0*sin(lat_moon/!RADEG)]

    ; direction to the sun
    sundir = [cos(sunangle/!RADEG) , sin(sunangle/!RADEG) , 0.0]

    ; direction to the observer
    observdir = [1.0 , 0.0 , 0.0]

    ; get AoI and AoR from scalar products with the lunar surface normal
    AoI = acos(surfnormal##transpose(sundir))
    AoR = acos(surfnormal##transpose(observdir))
    phi = acos(sundir##transpose(observdir))

    ; local albedo
    if (moon_albedo EQ 1) then begin
      ii = floor(3*(lat_moon+90.0))
      jj = floor(3*((360.0+lon_moon) MOD 360))
      Amoon = Aclementine[jj,ii]
    endif

    ; retrodirective function for the sunshine incident on the Moon
    g = 0.6
    if (phi EQ 0.0) then begin
      B = 2.0
    endif else if (phi GT 0.0 AND phi LT (!PI/2.0-0.00001)) then begin
      B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
    endif else if (phi GE (!PI/2.0-0.00001)) then begin
      B = 1.0
    endif

    ; scattering function for the sunshine incident on the Moon
    t = 0.1
    S = (2.0/(3*!PI)) * (sin(abs(phi)) + (!PI-abs(phi)) * cos(abs(phi)))/!PI + t*(1.0 - 0.5*cos(abs(phi)))^2

    ; BRDF for the sunshine incident on the Moon
    if (moon_BRDF EQ 1) then begin
      ; Hapke [1963] with extension described by Jensen et al. [2005]
      if AoI LT !PI/2 AND AoR LT !PI/2 then begin
        BRDFsm =  B * S * 1.0/(1.0+cos(AoR)/cos(AoI))
      endif else begin
        BRDFsm = 0.0
      endelse
    endif else if (moon_BRDF EQ 2) then begin
      ; Lambertian surface
      if AoI LT !PI/2 then begin
        BRDFsm = cos(AoI)/!PI
      endif else begin
        BRDFsm = 0.0
      endelse
    endif

    ; BRDF for the earthshine incident on the Moon
    if (moon_BRDF EQ 1) then begin
      BRDFem = 1.0
    endif else if (moon_BRDF EQ 2) then begin
      BRDFem = 1.0
    endif

    ; add together solar and earthshine irradiances
    image[512+iy,512+iz] = Isun*Amoon*BRDFsm  ; + Iearth*Amoon*BRDFem

  endif

endfor
endfor



;-------------------------------------------
; Create a new image array with 8-bit pixels.
; Some pixels should perhaps be saturated to
; get a better looking histogram.
;-------------------------------------------
; indx = where(image GT 45.0,count)
; print,count
; image[indx] = 45.0
image_8bit = byte( 255*(image-min(image))/(max(image)-min(image)) )



;--------------
; Analyze image
;--------------
hist = histogram(image_8bit)



plott:



; windows on screen
set_plot,'win'

window,0,xpos=0,ypos=0,xsize=1025,ysize=1025

tv,image_8bit

write_jpeg,'Moon.jpeg',image_8bit
writefits,'Moon.fit',double(image_8bit)

window,1,xpos=600,ypos=0,xsize=600,ysize=420
plot, indgen(1025)-512, image_8bit[*,512], xrange=[-512,512], yrange=[0,256], xstyle=1, ystyle=1, thick=2.0, xtitle='pixels', ytitle='E!Imoon!N', title='pixel values along Moon''s equator', charsize=1.8, charthick=1.3

window,2,xpos=600,ypos=410,xsize=600,ysize=420
plot, alog10(hist+0.000001), xrange=[0,256], yrange=[0,4.5], xstyle=1, ystyle=1, thick=2.0, xtitle='pixel value', ytitle='log(number of pixels)', title='histogram for pixel values', charsize=1.8, charthick=1.3

; window,3,xpos=700,ypos=610,xsize=680,ysize=600
; plot, indgen(1025)-512, Hapke[*], xrange=[-512,512], yrange=[-5.0,80.0], xstyle=1, ystyle=1, thick=2.0, xtitle='pixels', ytitle='E!Imoon!N', title='E!Imoon!N along z=0 according to Hapke', charsize=1.8, charthick=1.3



; PostScript file
; set_plot,'ps'
; device,color=1,bits=8,encapsulated=1,xsize=20,ysize=20,xoffset=0,yoffset=0
; device,file=strcompress('moon.eps',/remove_all)
; loadct,0
; !p.multi = 0
;
; contour,image,/fill,xtitle='Y [arcsec]',ytitle='Z [arcsec]'
;
; device,/close


ending:
end

