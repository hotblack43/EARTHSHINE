for i=1950,2060,1 do begin
name=strcompress('RR_'+string(i)+'.nc',/remove_all)
print,name

ncdvarget.... precip
precip_a=total(precip,3)
if (i eq 1950) then samlet_precip=precip_a
if (i gt 1950) then samlet_precip=[[[samlet_precip]],precip_a]
help,samlet_precip

endfor
tidsakse=indgen(2060-1950+1)+1950
end
