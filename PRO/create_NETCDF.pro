PRO PT_NCDF_PUT_3D,id,x,x_str,identity
l=size(x)
dim1=l(1)
dim2=l(2)
dim3=l(3)
londim=NCDF_DIMDEF(id,'londim',dim1)
latdim=NCDF_DIMDEF(id,'latdim',dim2)
daydim=NCDF_DIMDEF(id,'days',dim3)
identity=NCDF_VARDEF(id,x_str,[londim,latdim,daydim])
NCDF_ATTPUT,id,identity,'long_name',x_str
return
end

PRO PT_NCDF_PUT_1D,id,x,x_str,identity
londim=NCDF_DIMDEF(id,x_str,n_elements(x))
identity=NCDF_VARDEF(id,x_str,[londim])
NCDF_ATTPUT,id,identity,'long_name',x_str
return
end

PRO write_netcdf,lon,lat,rel_vort,iyear,wanted_ilev,fromstr
filename=strcompress('/data/pth/NETCDF/'+'VORTICITIES_'+fromstr+string(fix(iyear))+'_LEVEL_'+string(fix(wanted_ilev))+'_NCEP.nc',/remove_all)
id=NCDF_CREATE(filename,/CLOBBER)
NCDF_CONTROL,id,/FILL
PT_NCDF_PUT_1D,id,lon,'longitude',lonid
PT_NCDF_PUT_1D,id,lat,'latitude',latid
PT_NCDF_PUT_3D,id,reform(rel_vort(*,*,wanted_ilev,*)),'relative_vorticity',rvid

NCDF_CONTROL,id,/ENDEF
NCDF_VARPUT,id,lonid,lon
NCDF_VARPUT,id,latid,lat
NCDF_VARPUT,id,rvid,reform(rel_vort(*,*,wanted_ilev,*))

NCDF_CLOSE,id
return
end
