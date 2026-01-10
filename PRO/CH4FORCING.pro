FUNCTION CH4FORCING,CH4ppbv,N2Oppbv,iflag
CH4_0=700.0	;ppbv
N2O_0=0.0
if (iflag eq 1) then alfa=0.036	; IPCC
if (iflag eq 2) then alfa=0.036	; Myhreteal GRL 1998
CH4FORCING=alfa*(sqrt(CH4ppbv)-sqrt(CH4_0)) - (func(CH4ppbv,N2O_0) - func(CH4_0,N2O_0))
return,CH4FORCING
end
