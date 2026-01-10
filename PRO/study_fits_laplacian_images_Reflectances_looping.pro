PRO applyLaplacian,file1,obs_ratio,ifuse
common normalize,obs_total
 obs=readfits(file1,header,/silent)
 print,'Total: ',total(obs,/double)
 if (ifuse eq 1) then obs_total=total(obs,/double)
 if (ifuse eq 2) then obs=obs/total(obs,/double)*obs_total
 obslap=laplacian(obs)
 getcoordsfromheader,header,x0,y0,radius
 gogetratios,x0,y0,radius,obslap,minval,file1
 data=get_data('laplacian_range.dat')
 if (ifuse eq 1) then plot_io,yrange=[0.01,1e6],xstyle=3,charsize=1.9,$
 ystyle=3,data(0,*),data(1,*),xtitle='Theta',$
 ytitle='max - min of Laplacian on edge',title=name
 if (ifuse eq 2) then oplot,data(0,*),data(1,*),color=fsc_color('red')
 gfindlowandhighvalues,data(0,*),data(1,*),lowvalue,highvalue
 obs_ratio=highvalue/lowvalue
 if (ifuse eq 1) then print,'Observed high/low: ',obs_ratio
 if (ifuse eq 2) then begin
     print,'Model high/low: ',obs_ratio
    ; w=5
    ; printf,58,obs_ratio,mean(obs(369-w:369+w,312-w:312+w))/mean(obs(140-w:140+w,248-w:248+w))
     endif
     w=5
     printf,58,obs_ratio,mean(obs(369-w:369+w,312-w:312+w))/mean(obs(140-w:140+w,248-w:248+w))
 return
 end
 
 PRO gfindlowandhighvalues,x,y,lowvalue,highvalue
 range=max(y)-min(y)
 midpoint=10^(alog10(range)/2.)+min(y)
 idx=where(y gt midpoint)
 jdx=where(y le midpoint)
 lowvalue=median(y(jdx))
 highvalue=median(y(idx))
 oplot,[!X.crange],[lowvalue,lowvalue],linestyle=2
 oplot,[!X.crange],[highvalue,highvalue],linestyle=2
 return
 end
 
 FUNCTION ls,i,e
 ; i and e are angle sin DEGREES
 value=cos(i*!dtor)/(cos(i*!dtor)+cos(e*!dtor))
 help,value,i,e
 return,value
 end
 
 ;------------------------------------
 PRO getcoordsfromheader,header,x0,y0,radius
 idx=strpos(header,'DISCX0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCX0 not in header. Assigning dummy value'
     x0=256.
     endif else begin
     bits=strsplit(header(jdx),' ',/extract)
     x0=bits(2)
     endelse
 idx=strpos(header,'DISCY0')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'DISCY0 not in header. Assigning dummy value'
     y0=256.
     endif else begin
     bits=strsplit(header(jdx),' ',/extract)
     y0=bits(2)
     endelse
 idx=strpos(header,'RADIUS')
 jdx=where(idx eq 0)
 if(jdx(0) eq -1) then begin
     print,'RADIUS not in header. Assigning dummy value'
     radius=138.327880000
     endif else begin
     bits=strsplit(header(jdx),' ',/extract)
     radius=bits(2)
     endelse
 return
 end
 
 PRO goget_radii_angles,x0,y0,lap,radii,angle
 ; find radii of all pixels
 l=size(lap,/dimensions)
 x=findgen(l(0))
 y=findgen(l(1))
 xx=rebin(x,[l(0),l(1)])
 yy=transpose(rebin(y,[l(1),l(0)]))
 radii=sqrt((xx-x0)^2+(yy-y0)^2)
 angle=atan((xx-x0),-(yy-y0))/!dtor + 180
 return
 end
 
 PRO gogetratios,x0,y0,radius,lap,minval,name
 ; find (r,theta) of all pixels
 goget_radii_angles,x0,y0,lap,radii,angle
 ;contour,/isotropic,angle,/cell_fill,nlevels=101
 levs=findgen(9)*40.
 openw,33,'laplacian_range.dat'
 step=4
 rstep=1
 for theta=0,360-step,step do begin
     xx=[]
     yy=[]
     zz=[]
     for r=radius-20,radius+20,rstep do begin
         idx=where(angle gt theta and angle le theta+step and radii gt r and radii le r+rstep)
         x=mean(radii(idx))
         y=mean(lap(idx))
         z=stddev(lap(idx))
         xx=[xx,x]
         yy=[yy,y]
         zz=[zz,z]
         endfor
     printf,33,theta,max(yy)-min(yy)
     endfor
 close,33
 return
 end
 
 ;=============================================================
 ; Study Laplacian of images
 ; first show the observed image
common normalize,obs_total
 !P.MULTI=[0,1,1]
 files=file_search('Almost_Full_Moon*alfa*')
 nfiles=n_elements(files)
 openw,58,'Almost_low_high_ratio.dat'
 for ifil=0,nfiles-1,1 do begin
     file1=files(ifil)
	print,files(ifil)
	printf,58,files(ifil)
     if (ifil eq 0) then applyLaplacian,file1,modl_ratio,1
     if (ifil gt 0) then applyLaplacian,file1,modl_ratio,2
     endfor
 close,58
end
