FUNCTION Pilletprofile,r,pars
common names,varname
varname=['k: ','B: ','r_d: ','bias: ','p: ']
; Pillet (1992) eqn 5c
k=pars(0)
B=pars(1)
r_disc=pars(2)	; mainly keep fixed
bias=pars(3)
power=pars(4)
Pilletprofile=k/(abs(r-r_disc)^power+B)+bias
return,Pilletprofile
end
