PRO get_cossza_file,mm,lon,lat,yyyymm_str
f=strcompress('/cmsaf/cmsaf-cld3/pthejll/meancosSZA_'+yyyymm_str+'overland.bin')
if (file_test(f) ne 1) then stop
mm=dblarr(120,121)
lon=fltarr(120,121)
lat=fltarr(120,121)
get_lun,ww
openu,ww,f
readu,ww,mm
readu,ww,lon
readu,ww,lat
close,ww
free_lun,ww
return
end
