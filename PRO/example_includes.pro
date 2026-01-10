PRO get_d_factor,IGBPgrid,longrid,latgrid,mugrid,d_grid,factorgrid
 ; will return, in 'factorgrid' the 'd' factor needed in (1+d)/(1+2*d*mugrid)
 ;
 ; translate the surface type index in IGBPgrid to a 'd' number
 ; excerpt from Fortran code that uses these factors - see Trentmann Jörg <joerg.trentmann@dwd.de> CMSAF about this
 ;   REAL, PARAMETER :: d ( nigbp) = &
 ;      (/ 0.40,  & ! ( 1) EVERGREEN NEEDLE FOR
 ;      0.44,  & ! ( 2) EVERGREEN BROAD FOR
 ;      0.32,  & ! ( 3) DECIDUOUS NEEDLE FOR
 ;      0.39,  & ! ( 4) DECIDUOUS BROAD FOR
 ;      0.22,  & ! ( 5) MIXED FOREST
 ;      0.28,  & ! ( 6) CLOSED SHRUBS
 ;      0.40,  & ! ( 7) OPEN/SHRUBS
 ;      0.15,  & ! ( 8) WOODY SAVANNA
 ;      0.27,  & ! ( 9) SAVANNA
 ;      0.22,  & ! (10) GRASSLAND
 ;      0.35,  & ! (11) WETLAND
 ;      0.24,  & ! (12) CROPLAND (CAGEX-APR)
 ;      0.10,  & ! (13) URBAN
 ;      0.12,  & ! (14) CROP MOSAIC
 ;      0.10,  & ! (15) ANTARCTIC SNOW
 ;      0.40,  & ! (16) BARREN/DESERT
 ;      0.41,  & ! (17) OCEAN WATER
 ;      0.58,  & ! (18) TUNDRA
 ;      0.10,  & ! (19) FRESH SNOW
 ;      0.10 /)  ! (20) SEA ICE
 dvals=[911,0.4,0.44,0.32,0.39,0.22,0.28,0.4,0.15,0.27,0.22,0.35,0.24,0.1,0.12,0.1,0.4,0.41,0.58,0.1,0.1,-911]
 d_grid=IGBPgrid*0.0+911
 for i=1,20,1 do begin
     idx=where(IGBPgrid eq i)
     if (idx(0) ne -1) then d_grid(idx)=dvals(i)
     endfor
 ; check that no pixels have not been assigned
 if (where(abs(d_grid) eq 911) ne -1) then stop
 ; Formula is from eq (7) of Briegleb et al 1986 paper in J Clim App Met vol 25, pp 214-226. Note the typo there!
 factorgrid=(1.0+d_grid)/(1.0+2.0*d_grid*mugrid)
 return
 end
 
 PRO get_landsurface_type,IGBP,lon,lat
 f='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/AUXILLIARY/CERES_IGBP_LandCover_1x1.nc'
 id = NCDF_OPEN(f)
 NCDF_VARGET, id, 'lon',    lon
 NCDF_VARGET, id, 'lat',    lat
 NCDF_VARGET, id, 'IGBP',   IGBP 
 NCDF_CLOSE,  id
 return
 end
 
 PRO get_cossza_file,mm,lon,lat,yyyymm_str
 ; These binary files were generated with the code "calculate_mean_cossza.pro"
 f=strcompress('/cmsaf/cmsaf-cld3/pthejll/meancosSZA_'+yyyymm_str+'overland.bin')
 if (file_test(f) ne 1) then stop
 mm=dblarr(120,121)
 lon=fltarr(120,121)
 lat=fltarr(120,121)
 get_lun,ww
 openu,ww,f
 readu,ww,mm
 readu,ww,lon
 readu,ww,lat
 close,ww
 free_lun,ww
 return
 end
 
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
     gridded=regrid.avg
     latgrid=regrid.lat
     longrid=regrid.lon
     print,'Min, Max of gridded values :',min(gridded),max(gridded)
     print,'Smallest not-zero value : ',min(gridded(where(gridded ne 0)))
     existflag=1
     endif
 if (if_display eq 1) then begin
     tstr_type=strmid(file,40,5)
     histo,gridded,min(gridded),max(gridded),(max(gridded)-min(gridded))/100.0,title=tstr_type
     endif
 return
 end
 
 PRO get_lsmask_gridded,file,lsmask,lon,lat
 common displays,if_display
 existflag=314
 if (file_test(file) ne 1) then stop
 if (file_test(file)) then begin
     print,'Land-Sea mask exists:',file
     ;----------- start of funny code to set up lsmask-------------------
     ;ncdf_cat,file
     id = NCDF_OPEN(file)
     NCDF_VARGET, id, 'lon',    lon
     NCDF_VARGET, id, 'lat',    lat
     NCDF_VARGET, id, 'mask',    lsmask
     NCDF_CLOSE,  id
     ;;
     ;; NOTE the following code is very hard-wired for the choice of grid !!! 
     ;; compare the below to code in e.g. example5.pro where dlon etc are set
     ;; ask Peter Thejll (pth@dmi.dk) about this.
     ; clip the mask so that it matches the -60/-60:60/60 choice elsewhere
     lsmask=shift(lsmask,60,1)
     lsmask=reverse(lsmask,2)
     lsmask=lsmask(0:120-1,30:150)
     lsmask=abs(1-lsmask)	; land is now =1, sea=0 
     lon=findgen(120)-60
     lat=findgen(121)-60 
     l=lon
     for k=0,119,1 do l=[[l],[lon]]
     lon=l
     l=lat
     for k=0,118,1 do l=[[l],[lat]]
     lat=transpose(l)
     ;----------- end of funny code to set up lsmask-------------------
     existflag=1
     endif
 return
 end

 PRO go_interpolate,array_in,lon_in,lat_in,array_gridded,longrid,latgrid
 ; will interpolate the data given as array_in,lon_in,lat_in onto the
 ; grid given by longrid,latgrid. The output data will be array_gridded
 datvector=array_in
 lonvector=lon_in
 latvector=lat_in
 l=size(array_in,/dimension)
 if (n_elements(l) ne 1) then begin
     datvector=reform(array_in,float(l(0)*l(1)))
     if (n_elements(lon_in) eq l(0)*l(1)) then begin
         lonvector=reform(lon_in,float(l(0)*l(1)))
         latvector=reform(lat_in,float(l(0)*l(1)))
         endif
     if (n_elements(lon_in) eq l(0)) then begin
         lonvector=lon_in
         latvector=lat_in
         for k=1,l(1)-1,1 do lonvector=[lonvector,lon_in]
         for k=1,l(0)-1,1 do latvector=[latvector,lat_in]
         endif
     endif
 l2=size(longrid,/dimension)
 xoutvector=reform(longrid,float(l2(0)*l2(1)))
 youtvector=reform(latgrid,float(l2(0)*l2(1)))
 Result = GRIDDATA( lonvector,  latvector,  datvector,  /SPHERE, /DEGREES, xout=xoutvector, yout=youtvector ) 
 array_gridded=reform(Result,l2(0),l2(1))
 return
 end
 
