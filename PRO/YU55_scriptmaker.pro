data=get_data('YU55/YU_55_JD_RADEC.dat')
obsname='mlo'
l=size(data,/dimensions)
n=l(1)
for i=0,n-1,1 do begin
jd=reform(data(0,i))
hh=reform(data(1,i))
mm=reform(data(2,i))
ss=reform(data(3,i))
deg=reform(data(4,i))
mi=reform(data(5,i))
sec=reform(data(6,i))
hmstorad,hh,mm,ss,x
ra_yu55=x/!pi*180.d0
dec_yu55=deg+mi/60.d0+sec/3600.0d0
eq2hor, ra_yu55, dec_yu55, jd, alt_yu55, az_yu55, ha, obsname=obsname
sunpos,jd,ra_sun,dec_sun
eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha, obsname=obsname
str='  '
caldat,jd,month,day,year,hour,minute
if (alt_sun lt 0 and alt_yu55 gt 0 and jd ge 2455873.0 and az_yu55 gt 180) then begin
print,format='(a,1x,f20.7,1x,f5.1,1x,f5.1,1x,i2,1x,i2,1x,i4,1x,i2,1x,i2,1x,a)',str,jd,az_yu55,alt_yu55,month,day,year,hour,minute,' UTC'
coordstr=strcompress(string(fix(hh),format='(a)')+','+string(fix(mm),format='(a)')+','+string(fix(ss),format='(a)')+','+string(fix(deg),format='(a)')+','+string(fix(mi),format='(a)')+','+string(fix(sec),format='(a)'),/remove_all)
scriptname=strcompress(string(month)+'_'+string(day)+'_'+string(year)+'_'+string(hour)+'_'+string(minute)+'_UTC',/remove_all)
print,scriptname
if ((i mod 6) + 1 eq 1) then begin
print,'SETDATASOURCE,PROTOCOL,,,,,,,,'
print,'CCDCOOLERON,,,,,,,,,'
print,'SETDATASOURCE,PROTOCOL,,,,,,,,'
print,'CCDCONFIG,CCDCONFIGSETUP-DEFAULT,,,,,,,,'
print,'CCDINIT,,,,,,,,,'
print,'OPENEXTSHTR,,,,,,,,,'
print,'IRISOPENCLOSE,OPEN,,,,,,,,'
print,'TRACKSIDEREAL,,,,,,,,,'
endif
print,strcompress('PROTOSEGMENT'+string((i mod 6) + 1)+',,,,,,,,,,,,,,,,,',/remove_all)
print,strcompress('SETMOUNTRADEC,'+coordstr+',,,',/remove_all)
print,'MOVETOCOORDS,,,,,,,,,,,,,,,,,,,'
print,'SETFILTERCOLORDENSITY,V,AIR,,,,,,,'
print,'SETFOCUSPOSITION,V_AIR_SKE,,,,,,,,'
print,'STARTCYCLE1,10000,,,,,,,,,,,'
print,'SHOOTSINGLES,3,1,512,512,YU55,,,,'
print,'ENDCYCLE1,,,,,,,,,,,,,,'
endif
endfor
end
