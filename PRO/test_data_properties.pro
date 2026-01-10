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
!P.MULTI=[0,2,3]
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
tstr_date=strmid(SALfile,45,6)
; calculate the albedo
albedo=TRSgridded/TISgridded
printf,5,tstr_date,mean(TISgridded)
if (SALexist*TRSexist*TISexist*CFCexist eq 1) then begin
; get the good pixels in SAL and also pick only land points
idx=where(SALgridded gt 0.15 and lsmask eq 1 and abs(latgrid) lt 10.) 
; TEST SECTION
; test for cross-correlations
n=n_elements(idx)
arrays=fltarr(4,n)
titarr=['SAL','TRS','TIS','CFC']
arrays(0,*)=SALgridded(idx)
arrays(1,*)=TRSgridded(idx)
arrays(2,*)=TISgridded(idx)
arrays(3,*)=CFCgridded(idx)
; now test all for correlation
n_MC=341
       iflag=1
	print,tstr_date
	printf,5,tstr_date
	for i=0,3,1 do begin
	for j=i,3,1 do begin
	if (i ne j) then begin
       array1=arrays(i,*)
       array2=arrays(j,*)
       mc_correlate,array1,array2,MC_siglevel,n_MC,R,iflag
	Rstr=' R is not significant'
	if (100.-MC_siglevel gt 95) then begin
	print,titarr(i),' vs ',titarr(j),' R = ',R,' at S.L. = ',100.-MC_siglevel
	printf,5,titarr(i),' vs ',titarr(j),' R = ',R,' at S.L. = ',100.-MC_siglevel
	Rstr=strcompress(' R='+string(R)+' S.L.='+string(100.-MC_siglevel))
	endif
	plot,array1,array2,psym=3,xtitle=titarr(i),ytitle=titarr(j),xstyle=1,ystyle=1,title=tstr_date+Rstr
	endif
	endfor
	endfor
endif
endfor	; end of loop over list of filenames
end
