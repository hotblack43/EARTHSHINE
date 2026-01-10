FUNCTION torben,teleALT,teleAZ
alt=teleALT
if (teleAZ lt 0) then stop
if (teleAZ ge 0 and teleAZ le  180) then az=teleAZ
if (teleAZ gt 180) then az=360-teleAZ
if (teleAZ gt 360) then stop
domeAz=143.0*tanh(0.0012*(alt+8.72)*(az-1.59)+37.9
return,domeAz
end



; first get the gridded Ben table
res
