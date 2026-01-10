data=get_data('mean_sw_allsky.dat')
jd=reform(data(0,*))
sw=reform(data(1,*))
doy=(jd-min(jd)) mod 365
openw,55,'annual_sw_cycle.dat'
for i=0,366,1 do begin
idx=where(doy eq i)
if (idx(0) ne -1) then printf,55,i,median(sw(idx))
endfor
close,55
d=get_data('annual_sw_cycle.dat')
ddoy=reform(d(0,*))
sw_cy=reform(d(1,*))
plot,ddoy,sw_cy
;
plot,jd-min(jd),sw-[sw_cy,sw_cy,sw_cy,sw_cy]
xx=jd-min(jd)
yy=sw-[sw_cy,sw_cy,sw_cy,sw_cy]
idx=where(xx lt 155 or (xx gt 171 and xx lt 467) or (xx gt 493))
plot,xx(idx),yy(idx)
print,'SD(sw)/mean(sw)*100 : ',stddev(yy(idx))/mean(sw)*100.0,' %'
print,0.3*stddev(yy(idx))/mean(sw),'is 1 SD in albedo'
end
