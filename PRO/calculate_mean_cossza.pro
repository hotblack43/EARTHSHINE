;=================================
; Code to calculate the mean of the cos of the solar zenith angle, for each pixel in a mm product file
; do this by using TSI and scaling to the maximum value of the TSI for that month ...
; do the evaluation for the user-selected grid, not the one in the original hdf file
;=================================
common wantedgrid,dlon,dlat,nlon,nlat
common displays,if_display
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
openr,1,'CFCliste.txt'
openr,2,'TISliste.txt'
openr,3,'TRSliste.txt'
openr,4,'SALliste.txt'
!P.MULTI=[0,4,3]
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
tstr_type=strmid(CFCfile,40,5)
tstr=strmid(CFCfile,45,6)+' over land'
meancossza=TISgridded/max(TISgridded)
; write out as binary file
filename=strcompress('meancosSZA_'+tstr+'.bin',/remove_all)
print,filename
get_lun,w
openw,w,filename
writeu,w,meancossza
writeu,w,longrid
writeu,w,latgrid
help,meancossza,longrid,latgrid
close,w
free_lun,w
endfor
close,1
close,2
close,3
close,4
end
