data=get_data('Clem_on_othergrid.txt')
Clem=reform(data(0,*))
lonClem=reform(data(1,*))
latClem=reform(data(2,*))
data=get_data('Wildey_5map_average.txt')
lonWild=reform(data(0,*))
latWild=reform(data(1,*))
Wild=reform(data(2,*))
step=5
step=2.5
n=160./step+1
Clemmap=fltarr(n,n)
Wildmap=fltarr(n,n)
reldiff=fltarr(n,n)
ratiomap=fltarr(n,n)
get_lun,oiq
;openw,oiq,'lon_lat_clem_wild_5x5.txt'
openw,oiq,'lon_lat_clem_wild_2p5x2p5.txt'
ilon=0
for lon=-80.,80.,step do begin
ilat=0
for lat=-80.,80.,step do begin
idx=where(lonClem ge lon-step/2. and lonClem lt lon+step/2. and latClem ge lat-step/2. and latClem lt lat+step/2.)
jdx=where(lonWild ge lon-step/2. and lonWild lt lon+step/2. and latWild ge lat-step/2. and latWild lt lat+step/2.)
Clemmap(ilon,ilat)=mean(Clem(idx))
Wildmap(ilon,ilat)=mean(Wild(jdx))
reldiff(ilon,ilat)=(Clemmap(ilon,ilat)-Wildmap(ilon,ilat))/Wildmap(ilon,ilat)
ratiomap(ilon,ilat)=Clemmap(ilon,ilat)/Wildmap(ilon,ilat)
printf,oiq,lon,lat,Clemmap(ilon,ilat),Wildmap(ilon,ilat)
ilat=ilat+1
endfor
ilon=ilon+1
endfor
close,oiq
free_lun,oiq
writefits,'Clemmap.fits',Clemmap
writefits,'Wildmap.fits',Wildmap
writefits,'reldiff.fits',reldiff
writefits,'ratio.fits',ratiomap
;
!P.MULTI=[0,1,2]
plot,(reldiff(*,n/2))
plot,(reldiff(n/2,*))
end
