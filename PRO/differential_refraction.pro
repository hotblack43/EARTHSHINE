;  zref = refrac(z,wave,pressure,temp,relhum)
; INPUTS:
;  z        - true zenith angle (as if there were no atmosphere), in radians
;       wave     - wavelength of light, in microns
;       pressure - atmospheric pressure in mm of Hg
;       temp     - atmospheric temperature in degrees C
;       relhum   - Relative humidity (in percent)

temp=10.
relhum=30.
pressure=600.
wave=0.55
for z=0.,90,1.0 do begin
ref1=z*!dtor-refrac(z*!dtor,wave,pressure,temp,relhum)
ref2=(z+1.)*!dtor-refrac((z+1.)*!dtor,wave,pressure,temp,relhum)
print,z,(ref1-ref2)/!dtor*60.*60.,1./cos(z*!dtor)
endfor
end
