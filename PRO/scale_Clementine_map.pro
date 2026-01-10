datalib='Eshine/data_eshine'
X = read_ascii(datalib+'/'+'HIRES_750_3ppd.alb',data_start=0)
 PNORMmoon = float(X.field0001)
SPECIAL=PNORMmoon
; optionally, scale the Clementine map to Wildey levels using an empirical fit:
print,'Mean and SD of Hans Clementine map: ',mean(PNORMmoon),stddev(PNORMmoon)
PNORMmoon = 0.067509410 + PNORMmoon*0.50252315 + PNORMmoon*PNORMmoon*1.3644194
print,'Mean and SD of Clementine map after scaling to WIldey: ',mean(PNORMmoon),stddev(PNORMmoon)
;.......................
get_lun,ggy
openw,ggy,'HIRES_750_3ppd_scaled_to_WIldey.alb'
printf,ggy,format='(1080(f6.4,1x))',PNORMmoon
close,ggy
free_lun,ggy
;.......................
scalefactor=0.86
SPECIAL=(SPECIAL-mean(SPECIAL))*scalefactor+mean(SPECIAL)
print,'Mean and SD of SPECIAL: ',mean(SPECIAL),stddev(SPECIAL)
get_lun,ggy
openw,ggy,'SPECIAL.HIRES_750_3ppd_scaled_to_WIldey.alb'
printf,ggy,format='(1080(f6.4,1x))',SPECIAL
close,ggy
free_lun,ggy
end
