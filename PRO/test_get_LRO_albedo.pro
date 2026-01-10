FUNCTION get_lro_albedo
 ; get the LRO albedo map. The 7 layers are the wavelength bands 
 ; 321, 360, 415, 566, 604, 643, 689 nm
 im=READ_TIFF('Eshine/1x1_70NS_7b_wbhs_albflt_grid_geirist_tcorrect_w.tif', R, G, B,geotiff=hejsa)
 im=rebin(im,7,1080,140*3)
 blanks=fltarr(7,1080,(540-420)/2)*!VALUES.F_NAN
 im=[[[blanks]],[[im]],[[blanks]]]
 return,im
 end
 
 PRO getlro,lambdas,lro,lon_lro,lat_lro
 lambdas=[321, 360, 415, 566, 604, 643, 689]
 lro=get_lro_albedo()
 lon_lro=findgen(1080)/3.
 lat_lro=findgen(540)/3.-90
 lat_lro=reverse(lat_lro)
 clem=get_data('./Eshine/data_eshine/HIRES_750_3ppd.alb')
 lon_clem=findgen(1080)/3.
 lat_clem=findgen(540)/3.-90
 return
 end
 
 PRO getclem,clem,lon_clem,lat_clem
 clem=get_data('./Eshine/data_eshine/HIRES_750_3ppd.alb')
 lon_clem=findgen(1080)/3.
 lat_clem=findgen(540)/3.-90
 return
 end
 
 ;
 getlro,lambdas,lro_org,lon_lro,lat_lro
 help,getlro,lambdas,lro,lon_lro,lat_lro
 getclem,clem_org,lon_clem,lat_clem
 help,getlro,lambdas,lro,lon_lro,lat_lro
 openw,44,'clem_lro_R.dat'
 for iband=0,6,1 do begin
	lro=lro_org
	clem=clem_org
	lr=reform(lro(iband,*,*))
        cl=shift(reverse(clem,2),-1,-1)
     openw,33,'albs.dat'
     for ilon=0,359,1 do begin
         for ilat=-70,69,1 do begin
             idx=where(lon_clem eq ilon)
             jdx=where(lat_clem eq ilat)
        ;    v1=clem(idx,jdx)
             v1=cl(idx,jdx)
        ;    idx=where(lon_lro eq ilon)
        ;    jdx=where(lat_lro eq ilat)
        ;    v2=lro(iband,idx,jdx)
             v2=lr(idx,jdx)
             printf,33,format='(2(1x,i4),3(1x,f9.5))',ilon,ilat,v1,v2,v1/v2
             endfor
         endfor
     close,33
     data=get_data('albs.dat')
     idx=sort(data(2,*))
     data=data(*,idx)
     print,'R: ',correlate(data(2,*),data(3,*)),iband
     printf,44,iband,correlate(data(2,*),data(3,*))
     plot,data(2,*),data(3,*),psym=7,ytitle='LRO',xtitle='CLEM'
     res=linfit(data(2,*),data(3,*),/double,yfit=yhat)
     result = POLY_FIT(data(2,*),data(3,*), 2, MEASURE_ERRORS=measure_errors, SIGMA=sigma,yfit=yhat2)
     print,format='(3(1x,f9.4),a,3(1x,f9.4))',result,' +/- ',sigma
     oplot,data(2,*),yhat,color=fsc_color('red')
     oplot,data(2,*),yhat2,color=fsc_color('blue')
;------------------------------------------------------------
;rmax=-1e22
; for ishift=-5,5,1 do begin
; for jshift=-5,5,1 do begin
;	lr=reform(lro(iband,*,*))
;        cl=shift(reverse(clem,2),ishift,jshift)
;	idx=where(finite(lr) eq 1)
;	rstar=''
;	r=correlate(lr(idx),cl(idx))
;	if (r gt rmax) then begin
;		rstar='   *'
;		rmax=r
;	endif
;	print,ishift,jshift,r,rstar
; endfor
; endfor
;------------------------------------------------------------
     endfor
 close,44
 data3=get_data('clem_lro_R.dat')
 plot,data3(0,*),data3(1,*),xstyle=3,ystyle=3,xtitle='LRO band',ytitle='R',title='Clementine 750 nm map vs LRO between +/-70 deg lat',psym=-7
 end
