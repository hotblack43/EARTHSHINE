PRO get_water,lonin,latin,yearin,dayin,hourin,waterout
common flags,currentyear,lon,lat,time,water,pr_wtr
if (yearin ne currentyear) then begin
file=strcompress('/data/pth/NETCDF/pr_wtr.eatm.'+string(fix(yearin))+'.nc',/remove_all)
;ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'time',   time
NCDF_VARGET, id, 'pr_wtr',   pr_wtr
water=pr_wtr*0.01+277.650
NCDF_CLOSE,  id
currentyear=yearin
endif
;----------------
timestep=fix(hourin/6)+4*(dayin-1)
idx=abs(lon-lonin)
idx=where(idx eq min(idx))
jdx=abs(lat-latin)
jdx=where(jdx eq min(idx))
if (pr_wtr(idx,jdx,timestep) eq 32766) then stop
waterout=water(idx,jdx,timestep)
;print,lon(idx),lat(jdx),fix(timestep/4),'days ',6.*(timestep-4*fix(timestep/4)),'hours'
return
end



common flags,currentyear,lon,lat,time,water,pr_wtr
currentyear=314
openw,12,'p'
; get all extinctions from La Palma
file='/data/pth/DATA/CAMC/all_observational_nights_La_Palma.noheader'
data=get_data(file)
yy=reform(data(0,*))
mm=reform(data(1,*))
dd=reform(data(2,*))
ext=reform(data(5,*))
err=reform(data(6,*))
; plot
lonin=18.0
latin=28.0
for i=0,n_elements(yy)-1,1 do begin
yearin=yy(i)
dayin=julday(mm(i),dd(i),yy(i))-julday(1,1,yy(i))+1
print,dayin
hourin=0.1
get_water,lonin,latin,yearin,dayin,hourin,waterout
printf,12,ext(i),waterout
endfor
close,12
data=get_data('p')
ext=reform(data(0,*))
water=reform(data(1,*))
plot_oi,ext,water,xtitle='Extinction',ytitle='Precipitable water',charsize=1.7,title='La Palma',psym=7
end

