PRO go_analyse_clouds,yy
;
;
y=yy
n=n_elements(y)
;period=10.
;y=yy+sin(indgen(n)/period*!pi*2.)
z=fft(y,-1)
zz=conj(z)*z
periods=float(n)/(0.00001+indgen(n))
plot_oo,periods,zz,xrange=[2,250],yrange=[1e-12,max(zz)],charsize=1.4,xtitle='Period (years)',ytitle='Power'
return
end


!P.MULTI=[0,1,2]
file='/home/pth/DATA/NCfiles/CC_205_1500-2000.nc'

set_plot,'ps
device,/color
device,xsize=18,ysize=24.5,yoffset=2


loadct,39
;
Ystop=2000
ystart=1950
ystart=1500
Ystop=2000
runlength=Ystop-ystart
;
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'time',   time
NCDF_VARGET, id, 'var164',   clouds
NCDF_CLOSE,  id
;
clouds=rebin(clouds,128,64,6012./12.)
l=size(clouds,/dimensions)
nlon=l(0)
nlat=l(1)
years=indgen(l(2))+1500
idx=where(years ge ystart and years le Ystop)
map_TSI_coef=fltarr(nlon,nlat)
map_CO2_coef=fltarr(nlon,nlat)
map_CORR_TSI=fltarr(nlon,nlat)
map_CORR_CO2=fltarr(nlon,nlat)
map_CORR_YHAT=fltarr(nlon,nlat)
weighted_cloud=fltarr(nlon,nlat)
zonal_corr_TSI=fltarr(nlat)
zonal_corr_CO2=fltarr(nlat)
;
file='ROBERTSON_2001_IRRADIANCE'
data=get_data(file)
TSI=reform(data(1,*))
;
file='ROBERTSON_2001_GHG'
data=get_data(file)
CO2=alog(reform(data(1,*)))
;
xx=[transpose(TSI(idx)),transpose(CO2(idx))]
for ilat=0,nlat-1,1 do begin
print,ilat
for ilon=0,nlon-1,1 do begin
yy=reform(clouds(ilon,ilat,idx))
res=REGRESS(XX,YY,MCORRELATION=MCORR,CORRELATION=corr,/double,yfit=yfit,const=const)
map_TSI_coef(ilon,ilat)=res(0)
map_CO2_coef(ilon,ilat)=res(1)
map_CORR_TSI(ilon,ilat)=corr(0)
map_CORR_CO2(ilon,ilat)=corr(1)
map_CORR_YHAT(ilon,ilat)=MCORR
endfor
z=reform(clouds(*,ilat,idx))
yyy=total(z,1)
res=REGRESS(XX,YYY,MCORRELATION=MCORR,CORRELATION=corr,/double,yfit=yfit,const=const)
zonal_corr_TSI(ilat)=CORR(0)
zonal_corr_CO2(ilat)=CORR(1)
endfor
;
weighted_cloud=clouds*0.0
for ilon=0,nlon-1,1 do begin
for ilat=0,nlat-1,1 do begin
weighted_cloud(ilon,ilat,*)=clouds(ilon,ilat,*)*cos(lat(ilat)/180.*!pi)
endfor
endfor
; clip
weighted_cloud=weighted_cloud(*,*,idx)
;
l=size(weighted_cloud,/dimensions)
global_mean_cloud=fltarr(l(2))
for i=0,l(2)-1,1 do begin
global_mean_cloud(i)=mean(weighted_cloud(*,*,i))
endfor
plot,years(idx),global_mean_cloud,xtitle='Year',ytitle='Global weighted mean cloud',charsize=1.4,ystyle=1,yrange=[0.378,0.385]
oplot,years(idx),smooth(global_mean_cloud,5),thick=6, color=254
res=linfit(TSI(idx),global_mean_cloud,yfit=yfit)
oplot,years(idx),yfit,thick=4
print,'AR1 of residuals of TSI:',a_correlate(global_mean_cloud-yfit,1)
res=linfit(CO2(idx),global_mean_cloud,yfit=yfit)
oplot,years(idx),yfit,thick=4,linestyle=3
print,'AR1 of residuals of CO2:',a_correlate(global_mean_cloud-yfit,1)
array1=TSI(idx)
array2=global_mean_cloud
n_MC=100
iflag=1
MC_correlate_AR1,array1,array2,MC_siglevel,n_MC,R,iflag
print,'R(TSI,cloud)=',R,' at siglevel=',100.-MC_siglevel,' %.'
help,array1,global_mean_cloud
array1=CO2(idx)
array2=global_mean_cloud
n_MC=100
iflag=1
MC_correlate_AR1,array1,array2,MC_siglevel,n_MC,R,iflag
print,'R(CO2,cloud)=',R,' at siglevel=',100.-MC_siglevel,' %.'
help,array1,global_mean_cloud
go_analyse_clouds,global_mean_cloud
;
plot,zonal_corr_TSI,lat,xtitle='Zonal R - TSI',ytitle='Latitude'
;
map_set,title='GLIMSPE '+string(fix(runlength))+' year run: R - TSI [0.1 spacing, 0 bold]',/advance
print,'Max,min of R-TSI:',max(map_CORR_TSI),min(map_CORR_TSI)
levels = [-0.80,-0.75,-0.70,-0.65,-0.60,-0.55,-0.50,-0.45,-0.40,-0.35,-0.30,-0.25,-0.20,-0.15,-0.10,-0.05,0.00 ,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50,0.55,0.60,0.65,0.70,0.75]
colours = [19,19,37,37,56,56,65,65,74,74,84,84, 93,93,112,112, 186,186,191,191, 200,200,210,210,220,220,225,225,235,235,245,245]
contour,map_CORR_TSI,lon,lat,levels=levels,c_colors=colours,/cell_fill,/overplot
levels=indgen(21)*0.1-1.0
c_thick=indgen(n_elements(levels))*0+1
c_thick(where(levels eq 0))=3
contour,map_CORR_TSI,lon,lat,levels=levels,c_thick=c_thick,/overplot
map_continents,/overplot

plot,zonal_corr_CO2,lat,xtitle='Zonal R - CO2',ytitle='Latitude'
;
map_set,title='GLIMSPE '+string(fix(runlength))+' year run: R - CO2 [0.1 spacing, 0 bold]',/advance
print,'Max,min of R-CO2:',max(map_CORR_CO2),min(map_CORR_CO2)
levels = [-0.80,-0.75,-0.70,-0.65,-0.60,-0.55,-0.50,-0.45,-0.40,-0.35,-0.30,-0.25,-0.20,-0.15,-0.10,-0.05,0.00 ,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50,0.55,0.60,0.65,0.70,0.75]
colours = [19,19,37,37,56,56,65,65,74,74,84,84, 93,93,112,112, 186,186,191,191, 200,200,210,210,220,220,225,225,235,235,245,245]
contour,map_CORR_CO2,lon,lat,levels=levels,c_colors=colours,/cell_fill,/overplot
levels=indgen(21)*0.1-1.0
c_thick=indgen(n_elements(levels))*0+1
c_thick(where(levels eq 0))=3
contour,map_CORR_CO2,lon,lat,levels=levels,c_thick=c_thick,/overplot
map_continents,/overplot

map_set,title='GLIMSPE '+string(fix(runlength))+' year run: R - YHAT [0.1 spacing, 0 bold]'
print,'Max,min of R-YHAT:',max(map_CORR_YHAT),min(map_CORR_YHAT)
levels = [-0.80,-0.75,-0.70,-0.65,-0.60,-0.55,-0.50,-0.45,-0.40,-0.35,-0.30,-0.25,-0.20,-0.15,-0.10,-0.05,0.00 ,0.05,0.10,0.15,0.20,0.25,0.30,0.35,0.40,0.45,0.50,0.55,0.60,0.65,0.70,0.75]
colours = [19,19,37,37,56,56,65,65,74,74,84,84, 93,93,112,112, 186,186,191,191, 200,200,210,210,220,220,225,225,235,235,245,245]
contour,map_CORR_YHAT,lon,lat,levels=levels,c_colors=colours,/cell_fill,/overplot
levels=indgen(21)*0.1-1.0
c_thick=indgen(n_elements(levels))*0+1
c_thick(where(levels eq 0))=3
contour,map_CORR_YHAT,lon,lat,levels=levels,c_thick=c_thick,/overplot
map_continents,/overplot
end

