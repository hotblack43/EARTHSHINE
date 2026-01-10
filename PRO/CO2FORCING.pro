FUNCTION CO2FORCING,CO2ppmv,iflag
CO2_0=285.0
if (iflag eq 1) then alfa=6.3	; IPCC
if (iflag eq 2) then alfa=5.35	; Myhreteal GRL 1998
CO2FORCING=alfa*alog(CO2ppmv/CO2_0)
return,CO2FORCING
end
