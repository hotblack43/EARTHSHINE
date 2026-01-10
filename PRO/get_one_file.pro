PRO get_one_file,file,gridded,longrid,latgrid,existflag
common wantedgrid,dlon1,dlat1,nlon1,nlat1
common displays,if_display
print,'Infile : ',file
existflag=314
if (file_test(file)) then begin
	print,'File exists'
data=CM_SAF_read_data(file)
full_res= *data.data.(0).data
regrid=lonlat2reg(full_res, (*data.geolocation.lon), (*data.geolocation.lat),$
        lat0=-60,lon0=-60.,dlon=dlon1,dlat=dlat1,nlat=nlat1,nlon=nlon1, $
	nodata_value=data.data.(0).nodata_value)
help,regrid
gridded=regrid.avg
latgrid=regrid.lat
longrid=regrid.lon
print,'Min, Max of gridded values :',min(gridded),max(gridded)
print,'Smallest not-zero value : ',min(gridded(where(gridded ne 0)))
;printf,5,min(gridded(where(gridded ne 0))),file
existflag=1
endif
if (if_display eq 1) then begin
	tstr_type=strmid(file,40,5)
	histo,gridded,min(gridded),max(gridded),(max(gridded)-min(gridded))/100.0,title=tstr_type
	;CM_SAF_display,data
endif
return
end
