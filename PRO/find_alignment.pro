FUNCTION alignment,pars
;common stuff,lon,rot,lat
lon=pars(0) ; logitude of axis
rot=pars(1) ; angle of rotation about that axis
lat=pars(2) ; latitude of axis
;print,lon,rot,lat
; loop over data calculating the error between old shifted and new positions
getradecstrings,arr,n
tot_err=0.0d0
for ipos=0,n-1,1 do begin
    RA1=arr(0,ipos)
    DEC1=arr(1,ipos)
    RA2=arr(2,ipos)
    DEC2=arr(3,ipos)
    geterr,RA1,DEC1,lon,rot,lat,RA2,DEC2,e
    tot_err=tot_err+e
    endfor
return,tot_err
end

; Code to find rotation of the mount coord system by using observations of
; fixed fields. Socalled 'Drift Alignment' method.
; Store data in file 'pos.txt'
; Note that this oughtto be done with star fields and astrometry.net
start_params=[randomn(seed,3)]
xi = TRANSPOSE([[0.0, 1.0, 0.0],[1.0, 0.0, 0.0],[0.0, 0.0, 1.0]])
ftol=1.0d-8
POWELL, start_params, xi, ftol, fmin, 'alignment',/DOUBLE
;print,'xi:',xi
print,'fmin: ',fmin
print,'Rot angle axis x',start_params(0),' Degrees'
print,'Rot angle axis y',start_params(1),' Degrees'
print,'Rot angle axis z',start_params(2),' Degrees'
;
getradecstrings,arr,n
rotforward,arr,start_params
end

