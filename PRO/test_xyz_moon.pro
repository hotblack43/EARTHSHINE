pro xyz_moon,jd,x,y,z
print,jd
;+
; NAME:
;       XYZ_MOON
; PURPOSE:
;       Calculate APPROXIMATE geocentric X,Y, and Z  and velocity coordinates of the Moon
; EXPLANATION:
;	Tries to implement the "Low-precision formulae for geocentric coordinates of the Moon" 
;	in the Nautical Almanac (1997) P. D46.
;	We do an in-between thing - we use the final formulae for xyz that depend on ra,dec,r but get these from IDL's MOONPOS.pro routine
;
; CALLING SEQUENCE:
;       XYZ_MOON, date, x, y, z
;
; INPUT:
;       JD: julian date, scalar or vector
;
; OUTPUT:
;       x,y,z: scalars or vectors giving rectangular coordinates relative to Earth
;                 for each date supplied.    Note that sqrt(x^2 + y^2
;                 + z^2) gives the Earth-Moon distance for the given date.
;
; EXAMPLE:
;       What were the rectangular coordinates and velocities of the Sun on 
;       Jan 22, 1999 0h UT (= JD 2451200.5) in J2000 coords? NOTE:
;       Astronomical Almanac (AA) is in TDT, so add 64 seconds to 
;       UT to convert.
;
;       IDL> xyz_moon,51200.5+64.d/86400.d,x,y,z,xv,yv,zv,equinox = 2000
;
;
; PROCEDURE CALLS:
;   i think not?       PRECESS_XYZ
; REVISION HISTORY
;-

   On_error,2
  
   if (n_params() eq 0) then begin
      print,'Syntax - XYZ_moon, jd, x, y, z'
      return
   endif
	
	moonpos,jd,ra,dec,r

	l = cos(dec)*cos(ra)
	m = cos(dec)*sin(ra)
	n = sin(dec)

	x = r*l
	y = r*m
	z = r*n

return
end

;==========================================
jd=systime(/julian)
print,jd
xyz_moon,jd,x,y,z
print,x,y,z,sqrt(x*x+y*y+z*z)
end
