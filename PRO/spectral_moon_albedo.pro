 FUNCTION spectral_moon_albedo,wave
 ; INPUT 	wace (wavelength in nm)
 ;
 spectral_moon_albedo=0.000258*wave-0.0136
 return,spectral_moon_albedo
 end
