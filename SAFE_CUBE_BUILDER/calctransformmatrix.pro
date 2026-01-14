
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
