PRO get_exposure_factor,days,factor
file='moonbrightness.tab'
data=get_data(file)
d=reform(data(0,*))
f=reform(data(2,*))
factor=1./interpol(f,d,days)
return
end

PRO gofindmaxima,x,y,xwhere
for i=1,n_elements(x)-2,1 do begin
if (y(i) gt y(i-1) and y(i) gt y(i+1)) then begin
	print,x(i)
	xwhere=x(i)
endif
endfor	
return
end

PRO days_since_last_fullmoon,jd,days
jds=jd-30+findgen(30*36)/36.
mphase,jds,phases
gofindmaxima,jds,phases,days
return
end

PRO estimateEXPtimes,jd,FILTERtimes
filters=get_data('SETUP/exposure_factors.MOON')
days_since_last_fullmoon,jd,days
daysago=days-jd
get_exposure_factor,daysago,factor
caldat,days,mm,dd,yy,hh,mi,se
print,'FM was ',abs(daysago),' days ago . So the exposure factor is now ',factor
scaling=0.85
FILTERtimes=filters*factor*scaling
end
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
; get the offsets from the prepared file of Releaux triangles
;
; first get the estiamted exposure times
estimateEXPtimes,jd,FILTERtimes
;
openw,44,'MIDDLE_PART'
filtername=['B','V','VE1','VE2','IRCUT']
nfilters=n_elements(filtername)
thing=get_data('SETUP/exposure_factors.MOON')
;times=thing(0:4)
;estimate=0.02/3.*4.
; model passage of time during observations
timehaspassed=0.0	; days
ncycle=1
for icycle=0,ncycle-1,1 do begin
nrepeats=1	; number of frames in each filter to take
printf,44,'OPENDOME,,,,,,,,,,,,,,,,,,,'
printf,44,'STARTCYCLE1,10,,,,,,,,'
printf,44,'GOTOMOON,,,,,,,,,,,,,,,,,,,'
printf,44,'SETIMAGEREF,-200,0,,,,,,,,,,,,,,,,,,,'
printf,44,'MOVEMOONTOREF,,,,,,,,,,,,,,,,,,,'
printf,44,'DOMEAZ,,,,,,,,,,,,,,,,,,,'
printf,44,'DOMEAZ,,,,,,,,,,,,,,,,,,,'
for ifilter=0,nfilters-1,1 do begin
fname=filtername(ifilter)
expt=FILTERtimes(ifilter)
;expt=times(ifilter)*estimate	; seconds
printf,44,'SETFILTERCOLORDENSITY,'+fname+',AIR,,,,,,,'
printf,44,'SETFOCUSPOSITION,'+fname+'_AIR_SKE,,,,,,,,'
timehaspassed=timehaspassed+1./60./24.	; days
;printf,44,'WARMSHUTTER,,,,,,,,,,,,,,,,,,,'
timehaspassed=timehaspassed+.93/60./24.	; days
printf,44,'SHOOTDARKFRAME,'+string(expt,format='(f6.4)')+',1,512,512,DARK,,,,'
for kl=0,nrepeats-1,1 do printf,44,'SHOOTKINETIC,'+string(expt,format='(f6.4)')+',100,512,512,MOON_'+fname+'_AIR,,,,'
;for kl=0,nrepeats-1,1 do printf,44,'SHOOTSINGLES,'+string(expt,format='(f6.4)')+',1,512,512,MOON_'+fname+'_AIR,,,,'
printf,44,'SHOOTDARKFRAME,'+string(expt,format='(f6.4)')+',1,512,512,DARK,,,,'
timehaspassed=timehaspassed+float(nrepeats+1)*(expt+.3)/3600.0/24.0	;days
endfor
printf,44,'ENDCYCLE1,,,,,,,,,'
printf,44,'CLOSEDOME,,,,,,,,,'
print,'Time has passed: ',timehaspassed*24.*60.,' minutes'	; minutes
endfor
close,44
return
end


jd=systime(/utc,/julian)+3./60./24.d0
 spawn,'cat MOON_part1bb > SCRIPT.out'
ditherMOON,JD
 spawn,'cat MIDDLE_PART >> SCRIPT.out'
; spawn,'cat separator.txt >> SCRIPT.out'
 spawn,'cat MOON_part2b >> SCRIPT.out'
 spawn,'fromdos SCRIPT.out'
 print,'Output script is in "SCRIPT.out", edit and rename before use.'
 print,'Remember to note in the screen-listing above which is the last useful exposure.'
 print,' mv SCRIPT.out ~/INIandCSVfiles/MOONb.csv'

end
