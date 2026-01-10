obsname1='lick'
obsname1='kpno'
obsname1='lapalma'
obsname1='holi'
obsname1='palomar'
obsname1='bbso'

obsname2='palomar'
obsname2='holi'
obsname2='saao'
obsname2='flagstaff'
obsname2='lapalma'

obsname3='saao'
obsname3='lapalma'
obsname3='flagstaff'
obsname3='mmto'
obsname3='eso'

jdstart=double(julday(1,1,2010))
jdstop=double(julday(12,31,2010))
jdstep=1./24.;/4.;/18.
alt_limit=40.
sunlimit=0.0
openw,2,'uniqueness_three.dat'
openw,1,'uniqueness_two.dat'
for jd=jdstart,jdstop,jdstep do begin
        MOONPOS, jd, ra_moon, dec_moon, dis
        eq2hor, ra_moon, dec_moon, jd, alt_moon1, az_moon, ha_moon,  OBSNAME=obsname1
        eq2hor, ra_moon, dec_moon, jd, alt_moon2, az_moon, ha_moon,  OBSNAME=obsname2
        eq2hor, ra_moon, dec_moon, jd, alt_moon3, az_moon, ha_moon,  OBSNAME=obsname3
	sunpos, JD, RAsun, DECsun
        eq2hor, RAsun, DECsun, jd, alt_sun1, d1, d2,  OBSNAME=obsname1
        eq2hor, RAsun, DECsun, jd, alt_sun2, d4, d3,  OBSNAME=obsname2
        eq2hor, RAsun, DECsun, jd, alt_sun3, d4, d3,  OBSNAME=obsname3
	darkskies_obs1=(alt_sun1 lt sunlimit)
	darkskies_obs2=(alt_sun2 lt sunlimit)
	darkskies_obs3=(alt_sun3 lt sunlimit)
 	moongood_obs1=(alt_moon1 gt alt_limit)
 	moongood_obs2=(alt_moon2 gt alt_limit)
 	moongood_obs3=(alt_moon3 gt alt_limit)
	allgood_obs1=darkskies_obs1*moongood_obs1
	allgood_obs2=darkskies_obs2*moongood_obs2
	allgood_obs3=darkskies_obs3*moongood_obs3
	;if (allgood_obs1*allgood_obs2) then print,allgood_obs1,allgood_obs2,allgood_obs1*allgood_obs2,' Both'
	;if (allgood_obs1 and not(allgood_obs2)) then print,allgood_obs1,allgood_obs2,allgood_obs1*allgood_obs2,' First'
	;if (allgood_obs2 and not(allgood_obs1)) then print,allgood_obs1,allgood_obs2,allgood_obs1*allgood_obs2,' Second'
; two observatories
	if (allgood_obs1 and not(allgood_obs2)) then printf,1,jd,1
	if (allgood_obs1*allgood_obs2) then printf,1,jd,2
	if (allgood_obs2 and not(allgood_obs1)) then printf,1,jd,3
; three observatories
	if (allgood_obs1 and allgood_obs2 and allgood_obs3) then printf,2,jd,123
	if (allgood_obs1 and not(allgood_obs2)and not(allgood_obs3)) then printf,2,jd,1
	if (allgood_obs2 and not(allgood_obs1)and not(allgood_obs3)) then printf,2,jd,2
	if (allgood_obs3 and not(allgood_obs1)and not(allgood_obs2)) then printf,2,jd,3
	if (allgood_obs1 and allgood_obs2 and not(allgood_obs3)) then printf,2,jd,12
	if (allgood_obs1 and allgood_obs3 and not(allgood_obs2)) then printf,2,jd,13
	if (not(allgood_obs1) and allgood_obs2 and allgood_obs3) then printf,2,jd,23
endfor
close,1
close,2
; analyse the two observatory situation
data=get_data('uniqueness_two.dat')
jd=reform(data(0,*))
tt=reform(data(1,*))
n=n_elements(jd)
first=n_elements(where(tt eq 1))
both=n_elements(where(tt eq 2))
last=n_elements(where(tt eq 3))
print,' '
print,obsname1,' vs ',obsname2
print,'Only first observatory :',float(first)/float(n)*100.0,' %.'
print,'Both observatories     :',float(both)/float(n)*100.0,' %.'
print,'Only second observatory:',float(last)/float(n)*100.0,' %.'
; analyse the three observatory situation
data=get_data('uniqueness_three.dat')
jd=reform(data(0,*))
tt=reform(data(1,*))
n=n_elements(jd)
first=n_elements(where(tt eq 1))
second=n_elements(where(tt eq 2))
third=n_elements(where(tt eq 3))
all3=n_elements(where(tt eq 123))
just12=n_elements(where(tt eq 12))
just13=n_elements(where(tt eq 13))
just23=n_elements(where(tt eq 23))
print,' '
print,obsname1,' vs ',obsname2,' and ',obsname3
print,'Only first observatory     :',float(first)/float(n)*100.0,' %.'
print,'Only second observatory    :',float(second)/float(n)*100.0,' %.'
print,'Only third observatory     :',float(third)/float(n)*100.0,' %.'
print,'All three observatories    :',float(all3)/float(n)*100.0,' %.'
print,'Only Observatories 1 and 2 :',float(just12)/float(n)*100.0,' %.'
print,'Only Observatories 1 and 3 :',float(just13)/float(n)*100.0,' %.'
print,'Only Observatories 2 and 3 :',float(just23)/float(n)*100.0,' %.'
end

