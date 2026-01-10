!P.CHARSIZE=1.2
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,1,3]
data=get_data('ceres_albedo_daily_globalmean.dat')
jd=reform(data(0,*))
albedo=reform(data(1,*))
plot,xstyle=3,Ystyle=3,jd,albedo,xtitle='JD',ytitle='Global mean albedo',title='CERES albedo data'
doy=(jd-min(jd)) mod 365
plot,xstyle=3,ystyle=3,doy,albedo,psym=7,xtitle='doy',ytitle='Global mean albedo',title='CERES albedo data'
openw,55,'annual_albedo_cycle.dat'
for i=0,366,1 do begin
idx=where(doy eq i)
if (idx(0) ne -1) then printf,55,i,median(albedo(idx))
endfor
close,55
d=get_data('annual_albedo_cycle.dat')
ddoy=reform(d(0,*))
albedo_cy=reform(d(1,*))
oplot,ddoy,albedo_cy,color=fsc_color('red')
stop
;
plot,jd-min(jd),albedo-[albedo_cy,albedo_cy,albedo_cy,albedo_cy]
xx=jd-min(jd)
yy=albedo-[albedo_cy,albedo_cy,albedo_cy,albedo_cy]
idx=where(xx lt 155 or (xx gt 171 and xx lt 467) or (xx gt 493 and xx lt 1400))
xx=xx(idx)
yy=yy(idx)
plot,xx,yy
idx=where(yy gt -0.02)
xx=xx(idx)
yy=yy(idx)
print,'SD(albedo)/mean(albedo)*100 : ',stddev(yy)/mean(albedo)*100.0,' %'
print,0.3*stddev(yy)/mean(albedo),'is 1 SD in albedo'
end
