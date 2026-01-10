G=6.67e-11	; SI units
M=5.97e24	; kg
r=6371+253	; km
r=r*1000.
period=2.*!pi*sqrt(r^3/g/m)
print,'Period:',period/60.,' minutes'
end
