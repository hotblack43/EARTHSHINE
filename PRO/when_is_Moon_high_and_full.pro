!P.CHARSIZE=2
!P.THICK=4
!X.THICK=3
!y.THICK=3
openw,33,'plotme.dat'
        obsname='lund'
for jd=julday(1,1,2013,12,0,0),julday(1,1,2014),0.025d0 do begin
        SUNPOS, jd, ra_sun, dec_sun
        eq2hor, ra_sun, dec_sun, jd, alt_sun, az_sun, ha_sun,  OBSNAME=obsname
        MOONPOS, jd, ra_moon, dec_moon, dis, geolon,geolat
        eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
	mphase,jd,k
	if (alt_sun lt 0) then printf,33,format='(f15.7,2(1x,f6.2),1x,f6.2)',jd,alt_moon,k,az_moon
endfor
close,33
data=get_data('plotme.dat')
jd=reform(data(0,*))
fracyear=(jd-min(jd))/365.25+2013.0
alt=reform(data(1,*))
k=reform(data(2,*))
azi=reform(data(3,*))
!P.MULTI=[0,1,3]
plot,yrange=[0,1],xstyle=3,ystyle=3,psym=7,fracyear,alt/max(alt),xtitle='Year',ytitle='Altitude'
oplot,fracyear,k,color=fsc_color('red')
;
for i=0,12,1 do begin
oplot,[fracyear(0)+i*1./12.,fracyear(0)+i*1./12.],[!Y.crange],linestyle=2
endfor
plot,yrange=[0,1],xstyle=3,ystyle=3,psym=7,fracyear,alt/max(alt),xtitle='Year',ytitle='Altitude'
for i=0,12,1 do begin
oplot,[fracyear(0)+i*1./12.,fracyear(0)+i*1./12.],[!Y.crange],linestyle=2
endfor
plot,/nodata,xstyle=3,fracyear,k,ytitle='Phase [1=Full,0=New]'
oplot,fracyear,k,color=fsc_color('red')
for i=0,12,1 do begin
oplot,[fracyear(0)+i*1./12.,fracyear(0)+i*1./12.],[!Y.crange],linestyle=2
endfor
;
kdx=where(fracyear gt 2013+8./12. and fracyear lt 2013+9./12.)
plot,yrange=[0,90],xstyle=3,xtitle='Azimuth',ytitle='Altitude',azi(kdx),alt(kdx),psym=3,title='2013, September'
kdx=where(fracyear gt 2013+8./12. and fracyear lt 2013+12./12. and k gt 0.9 and alt gt 25)
oplot,azi(kdx),alt(kdx),psym=7
for l=0,n_elements(kdx)-1,1 do begin
caldat,jd(kdx(l)),mm,dd,yy,hh,mi,se
dayofmonth=dd
xyouts,azi(kdx(l)),alt(kdx(l)),string(fix(dd))
print,format='(i2,1x,i2,1x,i2,1x,i2,1x,i4,1x,f4.0,1x,f3.0,1x,f4.2)',hh,mi,dd,mm,yy,azi(kdx(l)),alt(kdx(l)),k(kdx(l))
endfor
end

