;=================================
; Code to read hdf files of SAL, TIS, TRS and CFC
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
; calculate the albedo
albedo=TRSgridded/TISgridded
if (SALexist*TRSexist*TISexist*CFCexist eq 1) then begin
; get the good pixels in SAL and also pick only land points
;idx=where(SALgridded gt 0.15 and lsmask eq 1) 
;tstr=strmid(CFCfile,45,6)+' all good SAL pixels, over land'
; get the land points
idx=where(lsmask eq 1 and SALgridded gt 0.15 and latgrid ge 30) 
tstr=strmid(CFCfile,45,6)+' over land'
;plot,SALgridded(idx),albedo(idx),ytitle='TRS/TIS',xtitle='SAL',title=strcompress(tstr)	$
;		,psym=3,xrange=[0,1],yrange=[0,1],xstyle=1,ystyle=1
scatter_col,SALgridded(idx),albedo(idx),minx=0.,miny=0.,maxx=1.0,maxy=1.0,binx=0.01,biny=0.01,color_bar=color_bar,ytitle='Model albedo',xtitle='SAL',title=strcompress(tstr)
oplot,[0,1],[0,1]
endif
endfor
close,1
close,2
close,3
close,4
end
