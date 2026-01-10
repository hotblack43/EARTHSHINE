names=['B','V','VE1','VE2','IRCUT']
times=[13.,1.7,.23,.165,.26]
openw,33,'LAMPFLATND.middle'
for i=0,20,1 do begin
for ifilter=0,4,1 do begin
expt_factor=randomu(seed)*0.9+0.1	; random numbers between 0.1 and 1.0
printf,33,'SETFILTERCOLORDENSITY,'+names(ifilter)+',AIR,,,,,,,'
printf,33,'SETFOCUSPOSITION,'+names(ifilter)+'_AIR_SKE,,,,,,,,'
printf,33,'SHOOTDARKFRAME,0.01,1,512,512,DARK,,,,'
printf,33,strcompress('SHOOTKINETIC,'+string(times(ifilter)*expt_factor)+',20,512,512,LAMP_FLAT_'+names(ifilter)+'_AIR,,,,',/remove_all)
printf,33,'SHOOTDARKFRAME,0.01,1,512,512,DARK,,,,'
endfor
endfor
close,33
spawn,'cat LAMPFLATND.bit1 > all.out'
spawn,'cat LAMPFLATND.middle >> all.out'
spawn,'cat LAMPFLATND.bit2 >> all.out'
print,'insepct and edit all.out, then'
print,' mv all.out ~/INIandCSVfiles/LAMPFLATnoND.csv'
end
