PRO mlo_airmass,jd,am
am=fltarr(n_elements(jd))
for i=0,n_elements(jd)-1,1 do begin
	get_mlo_airmass,jd(i),dummy
	am(i)=dummy
endfor
return
end
