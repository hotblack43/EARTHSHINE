 FUNCTION get_exptime,duskdawnflag,timesinceFFstart,filterNumber
 ; estimate the correct exposure time given info on the filter and the time
 ; This is the order of the color filters : B,V,VE1,VE2,Ircut,None
 ;
 factor=get_data('exposure_factors')
 k=0.091	; sky-darkening factor (See Tyson & Gal paper)
 tau=1.0    ; twilight scale factor	(See Tyson & Gal paper)
 ; First work out the DUSK case
 if (duskdawnflag eq 1) then begin
     t0=0.1	; Exposure time at start of dusk FF session in seconds
     time=timesinceFFstart*24.0d0*60.0d0	; minutes 
     a=10^(k/tau)
     exposuretime=t0*a^(time)	; in seconds since t0 is in seconds
     ; through a filter, relative to filter 'None' which is the 'White Light' case.
     exptime=exposuretime*factor(filterNumber-1)	; in seconds
     endif
 ; Then do the dawn case
 if (duskdawnflag eq 2) then begin
     t0=5.0	; Exposure time at start of dawn FF session in seconds
     time=timesinceFFstart*24.0d0*60.0d0	; minutes 
     a=10^(k/tau)
     exposuretime=t0*a^(-time)	; in seconds since t0 is in seconds
     ; through a filter, relative to filter 'None' which is the 'White Light' case.
     exptime=exposuretime*factor(filterNumber-1)	; in seconds
     endif
 return,exptime
 end
