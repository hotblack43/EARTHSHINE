PRO determineoffsetfactor,im,blurred,factor,offset
 ; Find the place in the image where the center of gravity lies
 ; and set up the 'force-fit patch' there.
 ;................
 ; Version 2
 ;................
 data=get_data('coords.dat')
 x0=reform(data(0,*))
 y0=reform(data(1,*))
 radius=reform(data(2,*))
 ;...............
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)   
 cg_y=total(y*im)/total(im)
 ;...............
 fittop=cg_x
 colwhere=cg_y
 fitsky=x0-radius-20              ; middle of sky force-fit patch in x 
 wid=2  ; width of patch to force image to fit in
 ;...............
 BSim=im(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)
 DSim=im(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)
 BSbl=blurred(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)
 DSbl=blurred(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)
 mnBSim=mean(BSim,/double)
 mnDSim=mean(DSim,/double)
 mnBSbl=mean(BSbl,/double)
 mnDSbl=mean(DSbl,/double)
 factor=mean((BSim-DSim)/(BSbl-DSbl),/double)
 ;factor=((mnBSim-mnDSim)/(mnBSbl-mnDSbl))
 ;factor=((mnBSim-mnDSim)/mean(blurred(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)-blurred(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid),/double))
 ;...............
 offset=mnDSim-mnDSbl*factor
;	print,'factor, offset = ',factor,offset
 openw,49,'factor_offset_andFourTimes25.dat'
	printf,49,'factor, offset = ',factor,offset
	printf,49,'25 target BS values:',im(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)
	printf,49,'25 target DS values:',im(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)
	printf,49,'25 blurred BS values:',blurred(fittop-wid:fittop+wid,colwhere-wid:colwhere+wid)
	printf,49,'25 blurred DS values:',blurred(fitsky-wid:fitsky+wid,colwhere-wid:colwhere+wid)
 close,49
 ;...............
 get_lun,uu
 openw,uu,'a_b_c_wid.dat'
 printf,uu,fittop
 printf,uu,fitsky
 printf,uu,colwhere
 printf,uu,wid
 close,uu
 free_lun,uu
 return
 end
