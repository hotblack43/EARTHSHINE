PRO annual_mean,x,fracyear
; clip to 1949-2004
year1=1949
year2=2004
n=year2-year1+1
years=fix(fracyear)
idx=where(years ge year1 and years le year2)
fracyear=fracyear(idx)
years=fix(fracyear)
fracyear=years(uniq(years))
x=x(*,*,*,idx)
; bin to annual
x=rebin(x,144,65,17,n)
stop
help
return
end




PRO get_data,file1,level,lon,lat,height,fracyear1
nlon=0L
nlat=0L
nlevels=0L
ntime=0L
openr,44,file1
readu,44,nlon
lon=fltarr(nlon)
readu,44,lon

readu,44,nlat
lat=fltarr(nlat)
readu,44,lat

readu,44,nlevels
level=fltarr(nlevels)
readu,44,level

readu,44,ntime
jd=dblarr(ntime)
readu,44,jd
fracyear1=fltarr(ntime)
readu,44,fracyear1
height=fltarr(nlon,nlat,nlevels,ntime)
readu,44,height
close,44
idx=where(abs(lat) le 80)
lat=lat(idx)
height=height(*,idx,*,*)
return
end

if_want_annual=0
file1='/home/pth/SCIENCEPROJECTS/EXTRATIONS/hgt.bin'
get_data,file1,level,lon,lat,height,fracyear1
if (if_want_annual eq 1) then annual_mean,height,fracyear1
idx=where(level eq 500)
surface_500=reform(height(*,*,idx,*))
idx=where(level eq 200)
surface_200=reform(height(*,*,idx,*))
thickness_500_200=surface_500*0.0
l=size(thickness_500_200,/dimensions)
nlon=l(0)
nlat=l(1)
ntime=l(2)
thickness_500_200=surface_200-surface_500
air=0.0
print,'Freed up some memory...'
file2='/home/pth/SCIENCEPROJECTS/EXTRATIONS/air.bin'
get_data,file2,level,lon,lat,air,fracyear2
if (if_want_annual eq 1) then annual_mean,air,fracyear2
idx=where(level ge 200 and level le 500)
weight=alog(level(idx))
l=size(air,/dimensions)
nlon=l(0)
nlat=l(1)
nlevel=l(2)
ntime=l(3)
mean_Temp_500_200=fltarr(nlon,nlat,ntime)
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
for itime=0,ntime-1,1 do begin
mean_Temp_500_200(ilon,ilat,itime)=total(weight*air(ilon,ilat,idx,itime))/total(weight)
endfor
endfor
endfor
end
