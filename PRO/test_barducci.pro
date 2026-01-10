FUNCTION Snowprofile,r,k,A,r_sun
; Barducci et al (1990) equation 20
; Plot the Barducci et al (1990) aureola profile
; for the typical Snow telescope

Snowprofile=k*alog(a/(r-r_sun))
return,Snowprofile
end

r_sun=1.0
r=findgen(100)/100.*5.+1.0
k=1.0
A=2.3
profile=Snowprofile(r,k,A,r_sun)
plot_oo,r,profile
end
