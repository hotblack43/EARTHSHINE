FUNCTION Snowprofile,r,pars
; Barducci et al (1990) equation 20
; Plot the Barducci et al (1990) aureola profile
; for the typical Snow telescope
k=pars(0)
a=pars(1)
r_disc=pars(2)	; mainly keep fixed
bias=pars(3)
power=pars(4)
Snowprofile=k*alog(a/(abs(r^power)-r_disc))+bias
return,Snowprofile
end
