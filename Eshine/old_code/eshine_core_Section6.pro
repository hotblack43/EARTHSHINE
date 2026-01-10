
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

image_info = {info, JD:JD,                                                  $
                    obsname:obsname+fill, Xobs:Xobs, Yobs:Yobs, Zobs:Zobs,  $
                    pixelscale:pixelscale,                                  $
                    RAmoon:RAmoon, DECmoon:DECmoon, Dem:Dem,                $
                    RAsun:RAsun, DECsun:DECsun, Dse:Dse,                    $
                    lat_lib:lat_lib, lon_lib:lon_lib, PA_lib:PA_lib,        $
                    GHAaries:GHAaries,                                      $
                    Isun:Isun, Iearth:Iearth }


