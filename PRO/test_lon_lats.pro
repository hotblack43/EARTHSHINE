jd1=systime(/julian)
for jd=jd1,jd1+365.,1 do begin
getmoon_ecliptic_lonfromsun_and_lat,jd,moonheliolon,moonecllat
 print,jd,moonheliolon,moonecllat
endfor
end
