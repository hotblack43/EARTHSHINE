for mean_galaxyflux=0.0,1.0,0.1 do begin
print,'G: ',mean_galaxyflux
var_RON=2.2^2
mean_Moonflux=4.8
var_Moon=2.9^2
var_sky=2.7^2
;
;
mean_atmosphereflux1 = - var_RON + var_sky - mean_galaxyflux
mean_atmosphereflux2 = - var_RON + var_Moon - mean_Moonflux
print,'Mean atmospheric flux 1: ',mean_atmosphereflux1
print,'Mean atmospheric flux 2: ',mean_atmosphereflux2
endfor
end
