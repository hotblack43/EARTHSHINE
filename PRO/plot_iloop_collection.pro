PRO getphase,jd,phase
day=jd-2455917.0d0
day=(day+11) 
day=day mod 29.7
phase=day*360/29.7-170.0
return
end

PRO getthealfa,file,alfafile
str=strmid(file,17,3)
strput,str,'.',1
alfafile=float(str)
return
end

array = ['iloop_collection_1p8_1image_boot_2455917p0.txt','iloop_collection_1p8_100images_boot_2455917p0.txt','iloop_collection_1p8_1image_boot_2455927p125.txt','iloop_collection_1p8_100images_boot_2455927p125.txt','iloop_collection_1p6_100images_boot_2455927p125.txt','iloop_collection_1p6_1image_boot_2455927p125.txt','iloop_collection_1p6_100images_boot_2455917p0.txt','iloop_collection_1p6_1image_boot_2455917p0.txt']
FOREACH element, array DO begin
PRINT, 'File = ', element
file=element
filestr=strmid(file,17,strlen(file)-1-3)
data=get_data(file)
l=size(data,/dimensions)
jd=reform(data(0,*))
alfa=reform(data(1,*))
offset=reform(data(2,*))
albedo=reform(data(3,*))
getphase,jd,phasearr
phase=reform(phasearr(0))
getthealfa,file,alfafile
!P.CHARSIZE=0.8
!P.MULTI=[0,2,2]
!X.STYLE=1
hstep=(max(alfa)-min(alfa))/21.
histo,alfa,alfafile-.0002,alfafile+.0006,hstep,xtitle='!7a!3',title=filestr
oplot,[alfafile,alfafile],[!Y.crange],linestyle=2
;--
hstep=(max(offset)-min(offset))/21.
histo,offset,399.99*0.9999,400.03*1.0001,hstep,xtitle='Offset',title=filestr
oplot,[400,400],[!Y.crange],linestyle=2
;..
hstep=(max(albedo)-min(albedo))/21.
histo,albedo,0.2955*0.98,0.2975*1.02,hstep,xtitle='Albedo',title=filestr
oplot,[.297,.297],[!Y.crange(0),!Y.crange(1)*0.7],linestyle=2
pct=stddev(albedo)/0.297*100.
xyouts,/normal,0.14,0.44,'S.D: '+string(stddev(albedo),format='(f9.6)')+' or '+string(pct,format='(f6.3)')+' (%)',charsize=1
pct2=(median(albedo)-0.297)/0.297*100.
xyouts,/normal,0.14,0.42,'Bias of median: '+string(pct2,format='(f6.3)')+' (%)',charsize=1
xyouts,/normal,0.14,0.40,'Lunar phase: '+string(phase,format='(f6.1)')+' (deg)',charsize=1
;--
print,'Alfa       :',mean(alfa),' +/- ',stddev(alfa)
print,'Offset     :',mean(offset),' +/- ',stddev(offset)
print,'Albedo     :',mean(albedo),' +/- ',stddev(albedo),' or ',stddev(albedo)/mean(albedo)*100.,' %. SD_m=',stddev(albedo)/mean(albedo)*100./sqrt(n_elements(alfa)),' %.'
print,'Phase      :',phase,' degrees.'
print,format='(f15.7,3(1x,f9.5,1x,g9.4))',jd(0),mean(alfa),stddev(alfa),mean(offset),stddev(offset),mean(albedo),stddev(albedo)
endforeach
end
