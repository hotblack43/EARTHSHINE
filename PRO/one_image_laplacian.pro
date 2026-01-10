PRO goget_answer_lapimage,y,val,err
 ; y is an array with a 'derivative of edge signature' in it 
 ; find max-min of this signature
 val=(max(y)-min(y))/2.0	; divide by 2 due to +h,-h nature of signature of edge
 err=911.
 return
 end
 
 PRO goget_answer_rawimage,y,val,err,eststep,uncert
 ; y is an array with a 'step' in it - find step heightand uncertainty from first and last third of array y
 n=n_elements(y)
 meanfirst=median(y(0:n/3.))
 errfirst=stddev(y(0:n/3.))/sqrt(n/3.)
 meansecond=median(y(n*2./3.:n-1))
 errsecond=stddev(y(n*2./3.:n-1))/sqrt(n/3.)
 val=abs(meanfirst-meansecond)
 err=sqrt(errfirst^2+errsecond^2)
 ; also fit lines to first and last half and extrapolate to midpoint
 ; first half
 z=y(0:n*4./10.) & nz=n_elements(z) & x=findgen(nz)+0
 res1=robust_linefit(x,z,yhat,sig,csig)
 valueatmidpoint=res1(0)+res1(1)*n/2.
	oplot,x,yhat,color=fsc_color('red')
 ; last half
 z=y(n*6./10.:n-1) & nz=n_elements(z) & x=findgen(nz)+n*6./10.
 res2=robust_linefit(x,z,yhat,sig,csig)
 othervalueatmidpoint=res2(0)+res2(1)*n/2.
	oplot,x,yhat,color=fsc_color('red')
 uncert=sqrt(csig(0)^2+csig(1)^2*(n/2.)^2)
	eststep=abs(othervalueatmidpoint-valueatmidpoint)
	print,'diff at extr. edge: ',eststep,' +/- ',uncert
 return
 end
 
 PRO gofindradiusandcenter_fromheader,header,x0,y0,radius
 ; Will take a header and read out DISCX0, DISCY0 and RADIUS
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     x0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     y0=float(strmid(header(jdx),15,9))
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=134.327880000
     endif else begin
     radius=float(strmid(header(jdx),15,9))
     endelse
 return
 end
 
 obs=readfits('/data/pth/DARKCURRENTREDUCED/2456095.1175415MOON_VE1_AIR_DCR.fits')
 efm=readfits('EFMCLEANED_0p7MASKED/2456095.1175415MOON_VE1_AIR_DCR.fits',header)
 ;idx=where(obs gt 2)
 ;obs=obs*0
 ;obs(idx)=10
 ;efm=efm*0
 ;efm(idx)=10
 openw,4,'results.dat'
 print,'--------------------------------------------------------------------------'
 for f_factor=0,3,1 do begin
     f=2^f_factor
     print,'Image scaling factor applied in rebinning: ',f
     obs=rebin(obs,512/f,512/f)
     efm=rebin(efm,512/f,512/f)
     lap_efm=laplacian(efm)
     lap_obs=laplacian(obs)
     gofindradiusandcenter_fromheader,header,x0,y0,radius
     y0=y0+1
     x0=x0+3.6
     x0=x0/f
     y0=y0/f
     radius=radius/f
     !P.MULTI=[0,2,4]
     !P.CHARSIZE=2
     print,'x0: ',x0
     print,'y0: ',y0
     print,'Radius: ',radius
     ;
     contour,xstyle=3,ystyle=3,hist_equal(obs),/isotropic,/cell_fill,title='OBS'
     contour,xstyle=3,ystyle=3,hist_equal(efm),/isotropic,/cell_fill,title='EFM'
     contour,xstyle=3,ystyle=3,hist_equal(lap_efm),/isotropic,/cell_fill,title='Laplacian of OBS'
     contour,xstyle=3,ystyle=3,hist_equal(lap_obs),/isotropic,/cell_fill,title='Laplacian of EFM'
     ;
     ic=0
     w=40/f
     for y=320/f,100/f,-1 do begin
         alfa=asin((y-y0)/radius)
         x=x0-radius*cos(alfa)
         plots,x,y,psym=3
         xlo=x-w
         xhi=x+w
         plots,xlo,y,psym=3
         plots,xhi,y,psym=3
	 bit1=efm(xlo:xhi,y)
         if (ic eq 0) then     sum_efm=bit1
         if (ic gt 0) then     sum_efm=sum_efm+bit1
         bit2=obs(xlo:xhi,y)
         if (ic eq 0) then     sum_obs=bit2
         if (ic gt 0) then     sum_obs=sum_obs+bit2
         bit3=lap_obs(xlo:xhi,y)
         if (ic eq 0) then sum_lap_obs=bit3
         if (ic gt 0) then sum_lap_obs=sum_lap_obs+bit3
         bit4=lap_efm(xlo:xhi,y)
         if (ic eq 0) then sum_lap_efm=bit4
         if (ic gt 0) then sum_lap_efm=sum_lap_efm+bit4
         ic=ic+1
         endfor
     print,ic,' rows were coadded.'
     fmt='(a32,f9.3,a,f9.4)'
     fmt2='(a32,f9.3,a,f9.4,a,f6.2,a)'
     plot,ytitle='edge-avgs',sum_obs/float(ic),psym=-7,xtitle='Columns by disc edge',title='OBS'
     goget_answer_rawimage,sum_obs/float(ic),val1,err,val1b,err1b
     print,format=fmt2,'RAW image, step height:',val1,' +/- ',err,' or ',abs(err)/abs(val1)*100.,' %.'
     plot,ytitle='edge-avgs',sum_lap_obs/float(ic),psym=-7,xtitle='Columns by disc edge',title='Lap(OBS)'
     goget_answer_lapimage,sum_obs/float(ic),val2,err
     print,format=fmt,'Laplacian of RAW image, max-min:',val2,' +/- ',err
     plot,ytitle='edge-avgs',sum_efm/float(ic),psym=-7,xtitle='Columns by disc edge',title='EFM'
     goget_answer_rawimage,sum_efm/float(ic),val3,err,val3b,err3b
     print,format=fmt2,'EFM image, step height:',val3,' +/- ',err,' or ',abs(err)/abs(val3)*100.,' %.'
     plot,ytitle='edge-avgs',sum_lap_efm/float(ic),psym=-7,xtitle='Columns by disc edge',title='Lap(EFM)'
     goget_answer_lapimage,sum_efm/float(ic),val4,err
     print,format=fmt,'Laplacian of EFM image, max-min:',val4,' +/- ',err
     printf,4,f,val1,val2,val3,val4,val1b,val3b
     print,'--------------------------------------------------------------------------'
     endfor
 close,4
 end
