phi=0.0
tvalue=0.1
g=0.6

B = 2.0 - (tan(phi)/(2*g)) * (1.0 - exp(-1.0*g/tan(phi))) * (3.0 - exp(-1.0*g/tan(phi)))
S = (2.0/(3*!DPI)) * ( (sin(phi) + (!DPI-phi)*cos(phi))/!DPI + tvalue*(1.0 - 0.5*cos(phi))^2 )
fphHapke63 = B*S
print,fphHapke63
end
