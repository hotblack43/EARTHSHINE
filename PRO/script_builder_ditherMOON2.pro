PRO parsestr,str_in,hh,mm,ss,deg,mi,sec
str=strcompress(' '+str_in+' ')
idx=strsplit(str,' ')
idx=[idx,strlen(str)]
hh=fix(strmid(str,idx(0),idx(1)-idx(0)))
mm=fix(strmid(str,idx(1),idx(2)-idx(1)))
ss=fix(strmid(str,idx(2),idx(3)-idx(2)))
deg=fix(strmid(str,idx(3),idx(4)-idx(3)))
mi=fix(strmid(str,idx(4),idx(5)-idx(4)))
sec=fix(strmid(str,idx(5),idx(6)-idx(5)))
return
end

PRO ditherMOON,JD
; will write out the RA and DEC of N telescope pointings
; starting at time JD, suitable for 'dither mode' work.
; getthe offsets from the prepared file of Releaux triangles
triang=get_data('triangle.dat')
delta_RA=reform(triang(0,*))
delta_DEC=reform(triang(1,*))
N=n_elements(delta_DEC)
openw,44,'MIDDLE_PART'
filtername=['B','V','VE1','VE2','IRCUT']
nfilters=n_elements(filtername)
thing=get_data('SETUP/exposure_factors.MOON')
times=thing(0:4)
estimate=0.0123*2.
MOONPOS, jd, ra_moon, DEC_moon
; to fix some JPL problem
RAoffset=+0.80	; degrees
DECoffset=-0.33	; degrees
; model passage of time during observations
timehaspassed=0.0	; days
nrepeats=11	; number of frames in each filter to take
for i=0,N-1,1 do begin
for ifilter=0,nfilters-1,1 do begin
fname=filtername(ifilter)
expt=times(ifilter)*estimate	; seconds
printf,44,'SETFILTERCOLORDENSITY,'+fname+',AIR,,,,,,,'
printf,44,'SETFOCUSPOSITION,'+fname+'_AIR_SKE,,,,,,,,'
timehaspassed=timehaspassed+1./60./24.	; days
MOONPOS, jd+timehaspassed, ra_moon, DEC_moon
RArnd=delta_RA(i)
DECrnd=delta_DEC(i)
;RArnd=0
;DECrnd=0
str_in=adstring(ra_moon+RArnd+RAoffset,dec_moon+DECrnd+DECoffset,1)
parsestr,str_in,hh,mm,ss,deg,mi,sec
linetxt=strcompress('SETMOUNTRADEC,'+string(hh)+','+string(mm)+','+string(ss)+','+string(deg)+','+string(mi)+','+string(sec)+',,,',/remove_all)
printf,44,linetxt
printf,44,'MOVETOCOORDS,,,,,,,,,,,,,,,,,,,'
printf,44,'WARMSHUTTER,,,,,,,,,,,,,,,,,,,'
timehaspassed=timehaspassed+.93/60./24.	; days
printf,44,'SHOOTDARKFRAME,'+string(expt,format='(f6.4)')+',1,512,512,DARK,,,,'
for kl=0,nrepeats-1,1 do printf,44,'SHOOTSINGLES,'+string(expt,format='(f6.4)')+',1,512,512,MOON_DITHER_'+fname+'_AIR,,,,'
;printf,44,'SHOOTDARKFRAME,'+string(expt,format='(f6.4)')+',1,512,512,DARK,,,,'
timehaspassed=timehaspassed+float(nrepeats+1)*(expt+.3)/3600.0/24.0	;days
endfor
print,'Time has passed: ',timehaspassed*24.*60.,' minutes'	; minutes
endfor
close,44
return
end


jd=systime(/utc,/julian)+3./60./24.d0
 spawn,'cat MOON_part1b > SCRIPT.out'
ditherMOON,JD
 spawn,'cat MIDDLE_PART >> SCRIPT.out'
 spawn,'cat separator.txt >> SCRIPT.out'
 spawn,'cat MOON_part2 >> SCRIPT.out'
 spawn,'fromdos SCRIPT.out'
 print,'Output script is in "SCRIPT.out", edit and rename before use.'
 print,'Remember to note in the screen-listing above which is the last useful exposure.'
 print,' mv SCRIPT.out ~/INIandCSVfiles/DITHERMOON.csv'

end
