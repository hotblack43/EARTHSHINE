;+
;===================================================================================
;                               THERMEXP_SW
;===================================================================================
;
; PURPOSE:
; -------
;       Returns the thermal expansion of sea water
;
; CALLING SEQUENCE:
; ----------------
;       thermexp_sw( s, t [,p] )
;
; INPUTS:
; ------
;       s         : temperature in deg. Celcius
;       t         : salinity in p.s.u.
;       p        : pressure in bars (optional, if omitted = 0 is assumed )
;
; OUTPUTS:
; -------
;       None
;
; KEYWORD PARAMETERS:
; ------------------
;       None
;;
; COMMON BLOCKS:
; -------------
;       None.
;
; NOTES:
; -----
;
; EXAMPLE:
; -------
;
; AUTHOR:
; ------
;       Torben Schmith, 8/8-2002.
;
; REVISIONS:
; ---------
;
;===================================================================================
;-

function thermexp_sw, s, t, p

s = double( s )
t = double( t )


; Pure water.

alpha = - 6.793952d-2                                                              $
        + 2 * 9.095290d-3 * t - 3 * 1.001685d-4 * t^2                              $
        + 4 * 1.120083d-6 * t^3 - 5 * 6.536332d-9 * t^4


; Sea water at 1 atm (IES80)

alpha = alpha + ( + 4.0899d-3                                                      $
                  - 2 * 7.6438d-5 * t + 3 * 8.2467d-7 * t^2                        $
                  - 4 * 5.3875d-9 * t^3                     ) * s                  $
              + ( - 1.0227d-4  + 2 * 1.6546d-6 * t) * s^1.5


; Pressure correction

if n_params() eq 3 then begin

   print, "*** thermexp_sw error - p ne 0 not implemented"

endif

return, alpha

end

s=35.0
t=2.0
p=1
for depth=0,11000,1000 do begin	; depth in meters
p=depth/10.	; appriximate pressure in bars (10 m = 1 bar)
alfa=thermexp_sw( s, t ,p )
print, s, t ,p,alfa
endfor
end
