jd1 = 1.0d0*julday(12,01,2022,12,0,0.0d0)
jd2 = 1.0d0*julday(12,01,2027,12,0,0.0d0)
dt=1./24.d0
for jd=jd1,jd2,dt do begin
;for jd=1,10,1 do begin
        print,jd
endfor
end
