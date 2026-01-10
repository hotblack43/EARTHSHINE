nyears=25
ntries=300
!P.MULTI=[0,1,3]
file='DATA/pres.mon.mean.nc'
ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'pres',   slp
slp=slp(*,*,indgen(12*nyears))
l=size(slp,/dimensions)
nlon=l(0)
nlat=l(1)
ntime=l(2)
NCDF_VARGET, id, 'time',   time
NCDF_CLOSE,  id
;
slope=fltarr(ntries)
residual_std=fltarr(ntries)
for itry=0,ntries-1,1 do begin
nsample=3*4500	; a suitable number of RO profiles in one month
mean_slp=fltarr(ntime)
slp_sample=fltarr(nsample)
ilat=fix(randomu(seed,nsample)*73)
ilon=fix(randomu(seed,nsample)*144)
for itime=0,ntime-1,1 do begin
for iran=0,nsample-1,1 do begin
ila=ilat(iran)
ilo=ilon(iran)
slp_sample(iran)=slp(ilo,ila,itime)
endfor
mean_slp(itime)=mean(slp_sample(*))
endfor
plot,mean_slp,ystyle=1
res=linfit(indgen(ntime),mean_slp,yfit=yfit)
print,itry,res(1)
slope(itry)=res(1)
residual_std(itry)=stddev(mean_slp-yfit)
if (itry eq 0) then concat_residuals=mean_slp-yfit
concat_residuals=[concat_residuals,mean_slp-yfit]
endfor	; end of itries loop
print,'concatenated residuals std:',stddev(concat_residuals)
print,'Mean slope:',mean(slope)
print,'STD slope:',stddev(slope)
print,'STD_m slope:',stddev(slope)/sqrt(float(ntries)-1)
print,'slope is significant to:',abs(mean(slope)/stddev(slope)/sqrt(float(ntries)-1)),' sigma_m'
;
print,nyears,'&'
print,stddev(concat_residuals),'&'
print,mean(slope),'&'
print,stddev(slope),'&'
print,stddev(slope)/sqrt(float(ntries)-1),'&'
print,abs(mean(slope)/stddev(slope)/sqrt(float(ntries)-1)),'&'
end

