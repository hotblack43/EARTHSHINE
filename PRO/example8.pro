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
; Forumual is from eq (7) og Briegleb et al 1986 paper i J Clim App Met vol 25, pp 214-226. Note the typo there!
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
     help,regrid
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
 print,'Infile : ',file
 existflag=314
 if (file_test(file) ne 1) then stop
 if (file_test(file)) then begin
     print,'File exists'
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

 ;====================================================================================================
 ; Code to read hdf files of SAL, TIS, TRS and CFC
 ; Builds a regression model of various factors - such as SAL and CFC against TRS/TIS
 ;====================================================================================================
 ; Version 8 - performs the solar zenith angle correction needed to turn SAL (at nomial SZA=60) into
 ; SAL at the actual SZA for each pixel.
 ;====================================================================================================
 common wantedgrid,dlon,dlat,nlon,nlat
 common displays,if_display
 ; set the Model type
 modeltype=1	; User can set 1 or two here - model is shown further down
 if_display=0	; leave at 0. If set to 1 will display data histograms
 !P.CHARSIZE=2
 get_lun,w
 openw,w,strcompress('regression_results_Model'+string(modeltype)+'.dat',/remove_all)
 ; go and get the Land-Sea mask
 file='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/AUXILLIARY/lsmask.nc'
 get_lsmask_gridded,file,lsmask,lsmasklon,lsmasklat
 ; name the CMSAF data files needed mm and MA/CD
 CFCfile='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/CFC/CFCmm200801010000300070023201MA.hdf'
 TISfile='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/TIS/TISmm200801010000300020011501CD.hdf'
 TRSfile='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/TRS/TRSmm200801010000300020026001CD.hdf'
 SALfile='/cmsaf/cmsaf-cld3/pthejll/CMSAFDATA/SAL/SALmm200801010000300070024201MA.hdf'
 ; set up the lon/lat grid we wish to work on
 dlon=1.0
 dlat=1.0
 nlon=120
 nlat=121
 ; open the files with the lists of file names
 openr,1,'CFCliste.txt'
 openr,2,'TISliste.txt'
 openr,3,'TRSliste.txt'
 openr,4,'SALliste.txt'
 !P.MULTI=[0,4,3]
 if (if_display eq 1) then !P.MULTI=[0,2,3]
 ; loop over the 32 names given in each of the 4 lists
 for ifile=1,32,1 do begin
     readf,1,CFCfile
     readf,2,TISfile
     readf,3,TRSfile
     readf,4,SALfile
     ; get and regrid all data for this year and month, scale SAL and CFC to interval 0->1
     get_one_file,SALfile,SALgridded,longrid,latgrid,SALexist & SALgridded=SALgridded/100.0
     get_one_file,TRSfile,TRSgridded,longrid,latgrid,TRSexist
     get_one_file,TISfile,TISgridded,longrid,latgrid,TISexist
     get_one_file,CFCfile,CFCgridded,longrid,latgrid,CFCexist & CFCgridded=CFCgridded/100.0
     ; calculate the albedo
     albedo=(TRSgridded/TISgridded)
     ; make som labels from the file names : WARNING - HARDWIRED TO PATHS ETC FIXX!!!!!!!!!!!!!!
     tstr_type=strmid(CFCfile,40,5)
     tstr=strcompress(strmid(CFCfile,45,6)+' , land, Model='+string(modeltype))
     ; get the mean(cos(SZA)) file for this year and month
     yyyymm_str=strmid(CFCfile,45,6)
     ; Since SAL is normaliyed to SZA=60 degrees we need to use the formula
     ; to convert to other SZAs. This menas getting the Briegleb or Dickinson 'd' factor
     ; which depends on the surface type, given by the IGBP data
     get_cossza_file,meanCosSZAgrid,londummy,latdummy,yyyymm_str
     ; get the IGBP land_surface type array
     get_landsurface_type,IGBPgrid,dummylon,dummylat
     ; get the 'd' parameter for each pixel
     get_d_factor,IGBPgrid,longrid,latgrid,meanCosSZAgrid,dgrid,factorgrid
     ; NOTE - the two arrays above are inside the loop over files (time, really) this is fine if they are time-dependent
     ; at the moment, they are not - but leave as is as readin is fast
     ;
     ; Now correct the SAL from nominal 60 degrees SZA to whatever it really is,
     ; which we, at the moment, assume to be given by the array meanCosSZAgrid
     ; CHECK THAT!!!
     SALgridded=SALgridded*factorgrid
     if (SALexist*TRSexist*TISexist*CFCexist eq 1) then begin
         ; get the land points
         idx=where(lsmask eq 1 and CFCgridded lt 0.1) 
         ; build regression model
         if (modeltype eq 1 ) then begin
             ; Model 1
             yy=albedo(idx)
             xx=transpose([[SALgridded(idx)],[CFCgridded(idx)]])
             endif
         if (modeltype eq 2 ) then begin
             ; Model 2
             yy=albedo(idx)
             xx=transpose([[SALgridded(idx)*(1.0-CFCgridded(idx))],[CFCgridded(idx)]])
             endif
         ; perform regression
         res=REGRESS(xx,yy,/double,sigma=sigs,yfit=yhat,const=const)
         ; calculate the residuals
         residuals=yy-yhat
         ; calculate the albedo error for each month - per pixel
         RMSE=sqrt(total(residuals^2))/n_elements(idx)
         ; plot the model against the regressand, overplot a diagonal
         scatter_col,yhat,albedo(idx),minx=0.,miny=0.,maxx=1.0,maxy=1.0,binx=0.02,biny=0.02, 	$
         color_bar=color_bar,ytitle='TRS/TIS',xtitle='Albedo model',title=strcompress(tstr)
         oplot,[0,1],[0,1]
         ; print out the regression results on screen and in a file for later plotting with "plot_regression_results.pro"
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
