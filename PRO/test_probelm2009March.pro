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
openr,1,'CFCliste_special.txt'
openr,2,'TISliste_special.txt'
openr,3,'TRSliste_special.txt'
openr,4,'SALliste_special.txt'
!P.MULTI=[0,4,3]
for ifile=1,3,1 do begin
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
tstr_date=strmid(SALfile,45,6)
; calculate the albedo
albedo=TRSgridded/TISgridded
printf,5,tstr_date,mean(TISgridded)
if (SALexist*TRSexist*TISexist*CFCexist eq 1) then begin
loadct,13
device,decomposed=0
map_set,/satellite,sat_p=[6,0,0],/isotropic,/advance
contour,albedo,longrid,latgrid,title=tstr_date+' TRS/TIS',/cell_fill,/overplot,nlevels=101
map_continents,/overplot
map_set,/satellite,sat_p=[6,0,0],/isotropic,/advance
contour,TRSgridded,longrid,latgrid,title=tstr_date+' TRS',/cell_fill,/overplot,nlevels=101
map_continents,/overplot
map_set,/satellite,sat_p=[6,0,0],/isotropic,/advance
contour,CFCgridded,longrid,latgrid,title=tstr_date+' CFC',/cell_fill,/overplot,nlevels=101
map_continents,/overplot
map_set,/satellite,sat_p=[6,0,0],/isotropic,/advance
contour,SALgridded,longrid,latgrid,title=tstr_date+' SAL',/cell_fill,/overplot,nlevels=101
map_continents,/overplot
endif
endfor
end
