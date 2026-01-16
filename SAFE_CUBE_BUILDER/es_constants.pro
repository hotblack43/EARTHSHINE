
;===============================================================================
;
; MODULE ES_Constants
;
;
; Version 1
;
; Authors: Hans Gleisner & Peter Thejll   (c) Danish Meteorological Institute
;
;===============================================================================


PRO ES_Constants

COMMON Constants, Rearth, Rmoon, AU, meanDse, meanDem, Isun_1AU, pi, RADEG, DRADEG, deg2rad

  Rearth   = 6365.0D        ; Earth radius             [km]
  Rmoon    = 1737.4D        ; Moon radius              [km]
  AU       = 149.6d+6       ; Astronomical Unit        [km]
  meanDse  = AU             ; mean Sun-Earth distance  [km]
  meanDem  = 384400.0D      ; mean Earth-Moon distance [km]
  Isun_1AU = 1368.0D        ; solar constant           [W/m2]

  pi       = 3.141592653589793d
  RADEG    = 180.0/!PI
  DRADEG   = 180.0D/!DPI
  deg2rad  = !DPI/180.0d0

END
