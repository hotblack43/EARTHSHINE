PRO is_moon_vissible,lon,lat,jd,ianswer,ianswer2,ianswer3,ianswer4
common limits,max_alt_sun,min_alt_moon,min_dis_moon_sun
; returns a '1' if the Moon canbe seen from lon,lat at time jd
; where is the Moon in the sky
MOONPOS, jd, ra_moon, dec_moon, dis
eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon, lon=lon, lat=lat
; Where is the Sun in the local sky?
SUNPOS, jd, ra_sun, dec_sun
eq2hor, ra_sun, dec_sun, jd, alt_sun, az, ha,  obslon=lon, lat=lat
u=0.0	; i.e. use radians everywhere
gcirc,u,ra_moon*!dtor, dec_moon*!dtor,ra_sun*!dtor, dec_sun*!dtor,dis
dis=dis/!pi*180.
; ianswer  : all conditions met
; ianswer2 : sun below horizon condition met
; ianswer3 : moon above limit condition met
; ianswer4 : Sun-moon angle limit condition met
ianswer=0
ianswer2=1
ianswer3=1
ianswer4=1
if (alt_sun gt max_alt_sun) then ianswer2=0
if (alt_moon lt min_alt_moon) then ianswer3=0
if (dis lt min_dis_moon_sun) then ianswer4=0
if((alt_sun lt max_alt_sun) and $
   (alt_moon gt min_alt_moon) and $
   (dis gt min_dis_moon_sun)) then ianswer=1
print,format='(f20.2,3(1x,f6.2),4(1x,i),2(1x,f8.2))',jd,alt_sun,alt_moon,dis,ianswer,ianswer2,ianswer3,ianswer4,lon,lat
return
end

; Code to evaluate Moon vissibility from various sites
;
common limits,max_alt_sun,min_alt_moon,min_dis_moon_sun
count=0
loadct,33
openw,44,'results_vissibility.dat'
max_alt_sun=-5
min_alt_moon=45
min_dis_moon_sun=30
jdstart=double(julday(1,1,2010))
jdstop=double(julday(12,31,2011))
step=2./24.d0
lonstep=360./20.
latstep=180./20.
!P.MULTI=[0,4,3]
for jd=jdstart,jdstop,step do begin
print,format='(f20.2)',jd
map_set,title=strcompress(string(jd)+' Sun alt< '+string(max_alt_sun)+'. Moon alt> '+string(min_alt_moon)+'. Sun-Moon >: '+string(min_dis_moon_sun)),/advance,charsize=0.8
map_continents,/overplot
for lon=-180.,180.,lonstep do begin
for lat=-90,90,latstep do begin
is_moon_vissible,lon,lat,jd,ianswer,ianswer2,ianswer3,ianswer4
if (ianswer4 eq 0) then plots,lon,lat,psym=3,color=fsc_color('orange')
if (ianswer3 eq 0) then plots,lon,lat,psym=3,color=fsc_color('blue')
if (ianswer2 eq 0) then plots,lon,lat,psym=3,color=fsc_color('yellow')
if (ianswer eq 1) then begin
	plots,lon,lat,psym=4,color=fsc_color('blue')
	printf,44,lon,lat
endif
endfor
endfor
; create a gif file
count=count+1
if (fix(count/12.) eq count/12.) then begin
;print,long(jd*100)
im=tvrd()
write_gif,strcompress('GIFs/'+string(long(jd*100))+'.gif',/remove_all),im
count=0
;a=get_kbrd()
endif
endfor
close,44
end
