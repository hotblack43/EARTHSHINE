PRO get_moon_rise_set,obsstart,obsend
;-------------------------------------------------------------------------------------
; will give the JD when the Moon rises above a set altitude limit and sets below it
; The inputs obsstart and obssend are the suggested start and stop times from other
; constraints, such as Flat Fielding. The routine must decide whether it wants to
; change obsstart,obsend to a narrower window, or not
;-------------------------------------------------------------------------------------
common place,obsname,obslon,obslat,jd_offset
if (obsend le obsstart) then stop
alt_limit=30.0d0	; degrees above horizon
jd_step=(obsend-obsstart)/1440.0d0*5.0
ic=0
for jd=obsstart,obsend,jd_step do begin
MOONPOS, jd, ra_moon, dec_moon, dis
eq2hor, ra_moon, dec_moon, jd, alt_moon, az_moon, ha_moon,  OBSNAME=obsname
if (ic eq 0) then begin
jd_save=jd
alt_save=alt_moon
ic=ic+1
endif
if (ic gt 0) then begin
jd_save=[jd_save,jd]
alt_save=[alt_save,alt_moon]
ic=ic+1
endif
endfor
; find suitable altitudes
idx=where(alt_save ge alt_limit)
if (idx(0) ne -1) then begin
obsstart=min(jd_save(idx))
obsend=max(jd_save(idx))
print,'max alt:',max(alt_save(idx))
endif
return
end

;--------------------------------------------------
for id=1,310,1 do begin
obsstart=julday(11,id,2010,18,0,0)
obsend=julday(11,id+1,2010,6,0,0)
print,'old:',obsstart,obsend,obsend-obsstart
get_moon_rise_set,obsstart,obsend
print,'new     :',obsstart,obsend,obsend-obsstart
endfor
end
