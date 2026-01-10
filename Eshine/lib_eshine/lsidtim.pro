;+
; NAME: 
;  lsidtim
; PURPOSE: 
;  Compute local sidereal time at a given longitude and time.
; DESCRIPTION:
;  This routine is based on the algorithms from p. 39 of "Astronomical
;  Formulae for Calculators" by J. Meeus.
; CATEGORY:
;  Astronomy
; CALLING SEQUENCE:
;  lsidtim,jd,lon,sidtim [,UT=ut]
; INPUTS:
;  jd  - Julian Date (double precision), scalar or vector.
;  lon - West longitude of observatory in radians (scalar).
; OPTIONAL INPUT PARAMETERS:
; KEYWORD INPUT PARAMETERS:
;  UT  - Time, in hours to add to JD to get the correct Universal Time.
;           That the same as Universal Time minus the Local Time.
; OUTPUTS:
;  lst - Local sidereal time for each of the input times (radians).
; KEYWORD OUTPUT PARAMETERS:
; COMMON BLOCKS:
; SIDE EFFECTS:
; RESTRICTIONS:
; PROCEDURE:
; MODIFICATION HISTORY:
;  94/05/05 - Written by Marc W. Buie, Lowell Observatory
;-
pro lsidtim,in_jd,lon,lst,UT=ut

   if badpar(in_jd,[5],[0,1],CALLER='lsidtim: (jd) ') then return
   if badpar(lon,[4,5],0,CALLER='lsidtim: (lon) ') then return
   if badpar(ut,[0,2,3,4,5],0,CALLER='lsidtim: (UT) ',DEFAULT=0) then return

   jd = in_jd + double(ut)/24.0d0

   t = (jd-2415020.0d0)/36525.0d0

   gst = 0.276919398d0 + t*(100.0021359d0+0.000001075d0*t)
   gst = (gst - long(gst))*2.0d0*!pi

   hour = ((jd + 0.5d0) - long(jd+0.5d0)) * 2.0 * !pi
   st = gst + hour*1.002737908d0

   lst = st - lon

end
