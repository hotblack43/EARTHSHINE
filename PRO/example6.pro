; Shows contour plot of residuals
;=================================
; Code to read hdf files of SAL, TIS, TRS and CFC
;=================================
common wantedgrid,dlon,dlat,nlon,nlat
common displays,if_display
get_lun,w
openw,w,'regression_results_Model1.dat'
if_display=0
!P.CHARSIZE=2
; go and get the Land-Sea mask
file='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/AUXILLIARY/lsmask.nc'
get_lsmask_gridded,file,lsmask,lsmasklon,lsmasklat
;
CFCfile='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/CFC/CFCmm200801010000300070023201MA.hdf'
TISfile='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/TIS/TISmm200801010000300020011501CD.hdf'
TRSfile='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/TRS/TRSmm200801010000300020026001CD.hdf'
SALfile='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/SAL/SALmm200801010000300070024201MA.hdf'
dlon=1.0
dlat=1.0
nlon=120
nlat=121
;; NOTE the above 4 lines have consequences in the subroutine get_lsmask_gridded.pro
;; look at how the land-sea mask is set up in that subroutine. If you make changes
;; to the settings of the dlon,dlat etc then there must be similar changes made on
;; get_lsmask_gridded.pro. (ask Peter Thejll, pth@dmi.dk about this).
openr,1,'CFCliste.txt'
openr,2,'TISliste.txt'
openr,3,'TRSliste.txt'
openr,4,'SALliste.txt'
!P.MULTI=[0,4,3]
!P.MULTI=[0,1,1]
if (if_display eq 1) then !P.MULTI=[0,2,3]
for ifile=1,32,1 do begin
readf,1,CFCfile
readf,2,TISfile
readf,3,TRSfile
readf,4,SALfile
; get and regrid all data for this year and month
get_one_file,SALfile,SALgridded,longrid,latgrid,SALexist
SALgridded=SALgridded/100.0
get_one_file,TRSfile,TRSgridded,longrid,latgrid,TRSexist
get_one_file,TISfile,TISgridded,longrid,latgrid,TISexist
get_one_file,CFCfile,CFCgridded,longrid,latgrid,CFCexist
CFCgridded=CFCgridded/100.0
tstr_type=strmid(CFCfile,40,5)
; calculate the albedo
albedo=TRSgridded/TISgridded
if (SALexist*TRSexist*TISexist*CFCexist eq 1) then begin
; get the good pixels in SAL and also pick only land points
idx=where(SALgridded gt 0. and lsmask eq 1) 
; build regression model
; Model 2
yy=albedo(idx)
xx=transpose([[SALgridded(idx)*(1.0-CFCgridded(idx))],[CFCgridded(idx)]])
; Model 1
yy=albedo(idx)
xx=transpose([[SALgridded(idx)],[CFCgridded(idx)]])
; perform regression
res=REGRESS(xx,yy,/double,sigma=sigs,yfit=yhat,const=const)
residuals=yy-yhat
;histo,residuals,min(residuals),max(residuals),(max(residuals)-min(residuals))/100.
map_set,/isotropic,/advance,limit=[-60,-60,60,60],title=strmid(CFCfile,45,6),/satellite,sat_p=[6,0,0]
lonuse=longrid(idx)
latuse=latgrid(idx)
loadct,0
contour,residuals,lonuse,latuse,/overplot,/irregular,/cell_fill,nlevels=31
nlevels=8
levels=findgen(nlevels)/(4.*nlevels)-1./4./2.
print,levels
cthick=indgen(nlevels)*0+1
cstyle=indgen(nlevels)*0
cthick(where(levels eq 0))=2
cstyle(where(levels lt 0))=3
contour,residuals,lonuse,latuse,/overplot,/irregular,levels=levels,c_thick=cthick,c_linestyle=cstyle,c_colors=indgen(nlevels)*0+255
map_continents,/overplot
map_grid,/overplot
RMSE=sqrt(total(residuals^2))/n_elements(idx)
print,"regression coefficients"
        print,const
        printf,w,const,0.0
for k=0,n_elements(res)-1,1 do begin
	print,res(k),' +/- ',sigs(k)
	printf,w,res(k),sigs(k)
endfor
printf,w,RMSE,911
endif
endfor
close,1
close,2
close,3
close,4
close,w
free_lun,w
end
