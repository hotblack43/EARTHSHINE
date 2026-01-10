 ;====================================================================================================
 ; Code to read hdf files of SAL, TIS, TRS and CFC
 ; Builds a regression model of various factors - such as SAL and CFC against TRS/TIS
 ;====================================================================================================
 ; Version 10 - performs the solar zenith angle correction needed to turn SAL (at nomial SZA=60) into
 ; SAL at the actual SZA for each pixel.
 ; Version 10 is like version 9, but tries to eliminate the oceans from the contour plot
 ;====================================================================================================
 common wantedgrid,dlon,dlat,nlon,nlat
 common displays,if_display
 ; set the Model type
 modeltype=1	; User can set 1 or two here - model is shown further down
 if_display=0	; leave at 0. If set to 1 will display data histograms
 !P.CHARSIZE=1.2
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
     tstr_date=strmid(CFCfile,45,6)
     tstr=strcompress(tstr_date+', land, Model='+string(modeltype))
     tstr2=strcompress('Land, Model='+string(modeltype))
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
         ;idx=where(lsmask eq 1 and CFCgridded lt 0.2) 
         idx=where(lsmask eq 1) 
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
	 loadct,0
         !P.MULTI=[0,2,2]
	 ; plot SAL against albedo
         scatter_col,SALgridded(idx),albedo(idx),minx=0.,miny=0.,maxx=1.0,maxy=1.0,binx=0.02,biny=0.02, 	$
         color_bar=color_bar,ytitle='TRS/TIS',xtitle='SAL',/isotropic,n_lev=4,title=strcompress(tstr_date)
         oplot,[0,1],[0,1]
	 ; plot the fitted model against albedo
         scatter_col,yhat,albedo(idx),minx=0.,miny=0.,maxx=1.0,maxy=1.0,binx=0.02,biny=0.02, 	$
         color_bar=color_bar,ytitle='TRS/TIS',xtitle='Albedo model',title=strcompress(tstr2),/isotropic,n_lev=4
         oplot,[0,1],[0,1]
	 ; make a map of residuals
	loadct,13
         !P.MULTI=[1,1,2]
	map_set,/advance,/isotropic,/satellite,sat_p=[8,0,0],title='Residuals, contours step .05'
         lonuse=longrid(idx)
	 latuse=latgrid(idx)
         datuse=residuals
         go_interpolate,datuse,lonuse,latuse,residuals_gridded,longrid,latgrid
         ; set ocean pixels to something very small
         residuals_gridded(where(lsmask eq 0))=!VALUES.F_NAN
         contour,residuals_gridded,longrid,latgrid,/overplot,/cell_fill,nlevels=31
	; overplot residuals that are particulalrly large
	kdx=where(residuals_gridded gt 0.2)
	if (kdx(0) ne -1) then oplot,longrid(kdx),latgrid(kdx),psym=7
nlevels=8
levels=findgen(nlevels)/(4.*nlevels)-1./4./2.
levels=[-0.2,-0.15,-0.1,-0.05,0.0,0.05,0.1,0.15,0.2]
print,levels
cthick=indgen(nlevels)*0+1
cstyle=indgen(nlevels)*0
cthick(where(levels eq 0))=2
cstyle(where(levels lt 0))=3
contour,residuals_gridded,longrid,latgrid,/overplot,levels=levels,c_thick=cthick,c_linestyle=cstyle,c_colors=indgen(nlevels)*0+255
map_continents,/overplot
map_grid,/overplot
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
