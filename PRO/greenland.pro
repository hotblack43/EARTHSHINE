mg=30.0e6*1e9*1e3/8.	; kg ice on Greenland
mE=6.e24			; mass of earth in kg
r=6371.0*1000.0		; Earths radius in m
h=600.  ; ice's height in km
dh=indgen(100)/100.-.5+h
value=mE/r-mE/(r+dh)-mg/(h-dh)
plot,dh,value
end

