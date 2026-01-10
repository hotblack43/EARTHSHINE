FUNCTION scatter_Iso,angle
; angle is the angle (in degrees) to the scattered 
; ray from the incident direction
; Isotropic scattering
scatter_Iso=1.0d0
return,scatter_Iso
end

FUNCTION scatter_Ray,angle
; angle is the angle (in degrees) to the scattered 
; ray from the incident direction
; Rayleigh scattering
scatter_Ray=1.0d0+cos(angle*!dtor)^2
return,scatter_Ray
end

FUNCTION rho,rho0,h0,h
; h is height in meters
; rho is the density of scattering particles
; rho0 is the density of scattering particles at h=0
; h0 is the scale height
rho=rho0*exp(-h/h0)
return,rho
end

PRO goscatter,N,h
; must scatter N particles
h0=7000.0
rho0=1e5
SSP=0.1
nscat=n*rho(rho0,h0,h)/rho0*SSP
; so, nscat particles will be scattered according to the function scatter(angle)
rnd1=randomu(seed,nscat)*2.*!pi
rnd2=randomu(seed,nscat)*2.
idx=where(rnd2 lt scatter_Iso(rnd1/!dtor))
;idx=where(rnd2 lt scatter_Ray(rnd1/!dtor))
openw,55,'scatt.dat'
for k=0L,n_elements(idx)-1,1 do begin
printf,55,rnd1(idx(k))
endfor
close,55
return
end

;................
; Model of what a laser beam shot straight up in the air would 
; look like seen from some distance on the ground
;................
; Models particles propagating upwards and scattering into a detector
; by Monte Carlo idea
;................
d=100.			; distance to foot of beam (meters)
nparticles=1000000.	; number of particles to model
top=100.*1000.	; meters (100km)
step=1
openw,99,'beam_Iso.dat'
for h=0L,top-step,step do begin
goscatter,nparticles,h
data=get_data('scatt.dat')
alfa=atan(h/d)
alfa2=atan((h+step)/d)
kdx=where(data ge alfa and data le alfa2)
print,h,alfa/!dtor,n_elements(kdx)
printf,99,h,alfa/!dtor,n_elements(kdx)
endfor
close,99
end
