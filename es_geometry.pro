
;===============================================================================
;
; MODULE ES_Geometry
;
;
; Version 1
;
; Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute
;
;===============================================================================



;===============================================================================;
; Compute the phase angle at Earth, i.e. the angle between the Sun and the Moon ;
; as seen from the Earth. The phase angles are defined as negative before full  ;
; Earth, and positive after.                                                    ;
;                                                                               ;
; Input:   RAmoon  [deg]                                                        ;
;          DECmoon [deg]                                                        ;
;          RAsun   [deg]                                                        ;
;          DECsun  [deg]                                                        ;
;                                                                               ;
; Return:  phase_angle  [deg]                                                   ;
;===============================================================================;
FUNCTION getPhaseAngleAtEarth, RAmoon, DECmoon, RAsun, DECsun

objectvector1 = dblarr(3)
objectvector2 = dblarr(3)


;--- Direction from Earth to Moon
objectvector1[0] = cos(RAmoon*!dtor) * cos(DECmoon*!dtor)
objectvector1[1] = sin(RAmoon*!dtor) * cos(DECmoon*!dtor)
objectvector1[2] = sin(DECmoon*!dtor)

;--- Direction from Earth to Sun
objectvector2[0] = cos(RAsun*!dtor) * cos(DECsun*!dtor)
objectvector2[1] = sin(RAsun*!dtor) * cos(DECsun*!dtor)
objectvector2[2] = sin(DECsun*!dtor)

dotproduct = transpose(objectvector1)#objectvector2
phase_angle = acos(dotproduct)*!radeg

;--- reversed sign compared to the phase angle at Moon
RAdiff = RAmoon - RAsun
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then begin
  sign = -1
endif else begin
  sign = +1
endelse
phase_angle = sign*phase_angle

return, phase_angle

END




;===============================================================================;
; Compute the phase angle at Moon, i.e. the angle between the Sun and the Earth ;
; as seen from the Moon. The phase angles are defined as negative before full   ;
; Moon, and negative after.                                                     ;
;                                                                               ;
; Input:   Dem     [km]                                                         ;
;          RAmoon  [deg]                                                        ;
;          DECmoon [deg]                                                        ;
;          Dse     [km]                                                         ;
;          RAsun   [deg]                                                        ;
;          DECsun  [deg]                                                        ;
;                                                                               ;
; Return:  phase_angle  [deg]                                                   ;
;===============================================================================;
FUNCTION getPhaseAngleAtMoon, Dem, RAmoon, DECmoon, Dse, RAsun, DECsun

objectvector1 = dblarr(3)
objectvector2 = dblarr(3)


;--- Position vector from Moon to Earth
objectvector1[0] = -Dem * cos(RAmoon*!dtor) * cos(DECmoon*!dtor)
objectvector1[1] = -Dem * sin(RAmoon*!dtor) * cos(DECmoon*!dtor)
objectvector1[2] = -Dem * sin(DECmoon*!dtor)

;--- Position vector from Moon to Sun
objectvector2[0] = Dse * cos(RAsun*!dtor) * cos(DECsun*!dtor) + objectvector1[0]
objectvector2[1] = Dse * sin(RAsun*!dtor) * cos(DECsun*!dtor) + objectvector1[1]
objectvector2[2] = Dse * sin(DECsun*!dtor)                    + objectvector1[2]

abs1 = Dem
abs2 = sqrt(objectvector2[0]^2 + objectvector2[1]^2 + objectvector2[2]^2)

dotproduct = (transpose(objectvector1)#objectvector2)
phase_angle = acos(dotproduct/(abs1*abs2)) * !radeg

;--- reversed sign compared to the phase angle at Earth
RAdiff = RAmoon - RAsun
if (RAdiff GT 180.0) OR (RAdiff LT 0.0 AND RAdiff GT -180.0) then begin
  sign = +1
endif else begin
  sign = -1
endelse
phase_angle = sign*phase_angle

return, phase_angle

END




;===============================================================================;
; Compute the angle between two vectors.                                        ;
;                                                                               ;
; Input:  obj1dir(3) [-]                                                        ;
;         obj2dir(3) [-]                                                        ;
;                                                                               ;
; Output: angle [rad]  (range=0,...,pi)                                         ;
;===============================================================================;
PRO getAngle, object1dir, object2dir, angle

; Output parameters
angle = 0.0D

; Local variables
abs1 = 0.0D
abs2 = 0.0D


abs1 = sqrt(object1dir(0)^2 + object1dir(1)^2 + object1dir(2)^2)
abs2 = sqrt(object2dir(0)^2 + object2dir(1)^2 + object2dir(2)^2)

angle = acos( (transpose(object1dir)#object2dir) / (abs1*abs2) )

END




;===============================================================================;
; Compute transformation matrixes for conversion of position vectors between    ;
; various coordinate systems.                                                   ;
;                                                                               ;
; EQ     Rectangular Equatorial coordinates                                     ;
; MEEQ   Moon-centred Earth-directed Equatorial coordinates                     ;
; GEO    Rectangular GEOgraphic coordinates                                     ;
; SEL    Rectangular SELenographic coordinates                                  ;
; EMEQ   Earth-centred Moon-directed Equatorial coordinates                     ;
; IMEQ   Image-centred Moon-directed Equatorial coordinates                     ;
;===============================================================================;

;===============================================================================;
; Transformation matrixes: MEEQ->SEL and SEL->MEEQ                              ;
;===============================================================================;
PRO MEEQ2SEL, lat_lib, lon_lib, PA_lib, R

  ; Input/output parameters
  ; lat_lib          ; libration, selenographic latitude [deg]
  ; lon_lib          ; libration, selenographic longitude [deg]
  ; PA_lib           ; libration, position axis [deg]
  R = dblarr(3,3)    ; transformation matrix MEEQ->SEL

  ; Local variables
  Rx = dblarr(3,3)
  Ry = dblarr(3,3)
  Rz = dblarr(3,3)
  thetaX = 0.0D
  thetaY = 0.0D
  thetaZ = 0.0D


  thetaZ = lon_lib*!dtor
  thetaY = -lat_lib*!dtor
  thetaX = -PA_lib*!dtor

  ;---------------------------------------------------------------------
  ; The following steps transform SEL axes into MEEQ axes.
  ; Assume initially that SEL and MEEQ Z-axes coincide.
  ;---------------------------------------------------------------------

  ;--- Rotation around the original Z-axis
  Rz[*,0] = [ cos(thetaZ) ,-sin(thetaZ) ,   0.0D   ]
  Rz[*,1] = [ sin(thetaZ) , cos(thetaZ) ,   0.0D   ]
  Rz[*,2] = [    0.0D     ,    0.0D     ,   1.0D   ]

  ;--- Rotation around the new Y-axis (observe the rotation direction)
  Ry[*,0] = [ cos(thetaY) ,   0.0d0  , sin(thetaY) ]
  Ry[*,1] = [    0.0d0    ,   1.0d0  ,     0.0d0   ]
  Ry[*,2] = [-sin(thetaY) ,   0.0d0  , cos(thetaY) ]

  ;--- Rotation around the new X-axis
  Rx[*,0] = [   1.0d0  ,    0.0d0    ,   0.0d0     ]
  Rx[*,1] = [   0.0d0  , cos(thetaX) ,-sin(thetaX) ]
  Rx[*,2] = [   0.0d0  , sin(thetaX) , cos(thetaX) ]

  R = ((Rz ## Ry) ## Rx)
  ; R = matmul(matmul(Rz, Ry),Rx)

END


PRO SEL2MEEQ, lat_lib, lon_lib, PA_lib, R

  ; Input/output parameters
  ; lat_lib            ; libration, selenographic latitude [deg]
  ; lon_lib            ; libration, selenographic longitude [deg]
  ; PA_lib             ; libration, position axis [deg]
  R = dblarr(3,3)      ; transformation matrix MEEQ->SEL

  ; Local variables
  Rx = dblarr(3,3)
  Ry = dblarr(3,3)
  Rz = dblarr(3,3)
  thetaX = 0.0D
  thetaY = 0.0D
  thetaZ = 0.0D


  thetaZ = -lon_lib*!dtor
  thetaY = lat_lib*!dtor
  thetaX = PA_lib*!dtor

  ;---------------------------------------------------------------------
  ; The following steps transform MEEQ axes into SEL axes.
  ;---------------------------------------------------------------------

  ;--- Rotation around the X-axis
  Rx[*,0] = [   1.0d0  ,    0.0d0    ,   0.0d0     ]
  Rx[*,1] = [   0.0d0  , cos(thetaX) ,-sin(thetaX) ]
  Rx[*,2] = [   0.0d0  , sin(thetaX) , cos(thetaX) ]

  ;--- Rotation around the Y-axis (observe the rotation direction)
  Ry[*,0] = [ cos(thetaY) ,   0.0d0  , sin(thetaY) ]
  Ry[*,1] = [    0.0d0    ,   1.0d0  ,     0.0d0   ]
  Ry[*,2] = [-sin(thetaY) ,   0.0d0  , cos(thetaY) ]

  ;--- Rotation around the Z-axis
  Rz[*,0] = [ cos(thetaZ) ,-sin(thetaZ) ,   0.0d0  ]
  Rz[*,1] = [ sin(thetaZ) , cos(thetaZ) ,   0.0d0  ]
  Rz[*,2] = [    0.0d0    ,    0.0d0    ,   1.0d0  ]

  R = ((Rx ## Ry) ## Rz)
  ; R = matmul(matmul(Rx, Ry),Rz)

END




PRO ES_Geometry
END
