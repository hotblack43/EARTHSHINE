PRO extractmeansabcd,strflag,idx,obs,lon,lat,eza,sza,xx,res,Ameanlon,Ameanlat,Amean,Ameanezas,Ameanszas,Bmeanlon,Bmeanlat,Bmean,Bmeanezas,Bmeanszas
	filename=strcompress(strflag+'.dat',/remove_all)
             openw,44,filename
             Ax=min(xx)
             Bx=max(xx)
             Ay=res(0)+res(1)*Ax
             By=res(0)+res(1)*Bx
             for k=0,n_elements(idx)-1,1 do begin
                 coords=array_indices(obs,idx(k))
                 Cx=coords(0)
                 Cy=coords(1)
                 whichside,Ax,Ay,Bx,By,Cx,Cy,iside
                 printf,44,format='(i3,1x,f10.1,4(1x,f7.2))',iside,obs(idx(k)),lon(idx(k)),lat(idx(k)),eza(idx(k)),sza(idx(k))
                 endfor
             close,44
             data=get_data(filename)
             iside=reform(data(0,*))
             obse=reform(data(1,*))
             lons=reform(data(2,*))
             lats=reform(data(3,*))
             ezas=reform(data(4,*))
             szas=reform(data(5,*))
             Adx=where(iside lt 0)
             Bdx=where(iside gt 0)
             if (n_elements(Adx) gt 2 and n_elements(Bdx)) then begin
                 ; group A (or C) mean properties
                 Amean=mean(obse(Adx))
                 Ameanlon=mean(lons(Adx))
                 Ameanlat=mean(lats(Adx))
                 Ameanezas=mean(ezas(Adx))
                 Ameanszas=mean(szas(Adx))
                 ; group B (or D)
                 Bmean=mean(obse(Bdx))
                 Bmeanlon=mean(lons(Bdx))
                 Bmeanlat=mean(lats(Bdx))
                 Bmeanezas=mean(ezas(Bdx))
                 Bmeanszas=mean(szas(Bdx))
	         if (strflag eq 'AorB') then begin	
                 print,'A: ',Ameanlon,Ameanlat,Amean,Ameanezas,Ameanszas
                 print,'B: ',Bmeanlon,Bmeanlat,Bmean,Bmeanezas,Bmeanszas
                 endif
	         if (strflag eq 'CorD') then begin	
                 print,'C: ',Ameanlon,Ameanlat,Amean,Ameanezas,Ameanszas
                 print,'D: ',Bmeanlon,Bmeanlat,Bmean,Bmeanezas,Bmeanszas
                 endif
             endif
     return
 end
PRO whichside,Ax,Ay,Bx,By,Cx,Cy,iside
 ; A coordinates of left end of line
 ; B other end of line
 ; C - coordinates of a point
 ; iside = -1 or +1 according to which sid eo fline point is
 side=(Bx - Ax) * (Cy - Ay) - (By - Ay) * (Cx - Ax)
 if (side gt 0) then iside=+1
 if (side lt 0) then iside=-1
 if (side eq 0) then iside=0
 return
 end
 
 PRO phaseanglefromheader,h,angle
 iptr=strpos(h,'PHSAN_N')
 str=h(where(iptr eq 0))
 angle=float(strmid(str,10,20))/180.*!pi
 angle=angle(0)
 return
 end
 
 lowpath='/data/pth/CUBES/'
 cube=readfits(lowpath+'cube_2455945.1776847_V_.fits',h)
 obs=reform(cube(*,*,0))
 ideal=reform(cube(*,*,4))
 lon=reform(cube(*,*,5))
 lat=reform(cube(*,*,6))
 sza=reform(cube(*,*,7))
 eza=reform(cube(*,*,8))
 !P.CHARSIZE=1.2
 !P.thick=3
 !x.thick=2
 !y.thick=2
 !P.MULTI=[0,2,2]
 contour,xstyle=3,title='Longitude',ystyle=3,obs,/isotropic,/cell_fill
 contour,/overplot,lon,levels=findgen(11)/10.*180-90,/downhill
 contour,xstyle=3,ystyle=3,/isotropic,lat,title='latitudes',levels=findgen(11)/10.*180-90,/downhill
 contour,xstyle=3,ystyle=3,/isotropic,sza/!dtor,title='SZA',levels=findgen(8)/7.*90,/downhill
 contour,xstyle=3,ystyle=3,/isotropic,eza/!dtor,title='EZA',levels=findgen(6)/5.*90,/downhill
 show=obs
 ;show=ideal
 epsi=0.01
 phaseanglefromheader,h,angle
 print,'Phase angle S-M-E: ',angle,' radians.'
 ; set the mirror meridan solar zenith angle
 za=angle/2.
 ; now consder offsets from the MM
 ; loop over all SZA and all EZA
 ;
 ; first find the photo-equator - you need this to later find points around symmetry axis
 ; the photo-equator is the eza_line of minimum EZA for fixed SZA
 ;
 openw,33,'photoequator.dat'
 fmt1='(2(1x,f18.12),2(1x,i4))'
 eza_step=1*!dtor
 for eza_find=!pi/2.-eza_step,eza_step,-eza_step do begin
     idx=where(eza gt eza_find-eza_step/2. and  eza le eza_find+eza_step/2.)
     jdx=where(sza(idx) eq min(sza(idx)))
     show(idx(jdx))=max(show)
     tvscl,show
     coords=array_indices(show,idx(jdx))
     print,format=fmt1,eza(idx(jdx)),sza(idx(jdx)),coords(0),coords(1)
     printf,33,format=fmt1,eza(idx(jdx)),sza(idx(jdx)),coords(0),coords(1)
     endfor
 close,33
 data=get_data('photoequator.dat')
 x=reform(data(2,*))
 y=reform(data(3,*))
 res=linfit(x,y)
 xx=findgen(512)
 yhat=res(0)+res(1)*xx
 oplot,xx,yhat,color=fsc_color('red')
 ;
 contour,xstyle=3,title='Longitude',ystyle=3,obs,/isotropic,/cell_fill
 contour,/overplot,lon,levels=findgen(11)/10.*180-90,/downhill
 oplot,xx,yhat,color=fsc_color('red')
 contour,xstyle=3,ystyle=3,/isotropic,lat,title='latitudes',levels=findgen(11)/10.*180-90,/downhill
 oplot,xx,yhat,color=fsc_color('red')
 contour,xstyle=3,ystyle=3,/isotropic,sza/!dtor,title='SZA',levels=findgen(8)/7.*90,/downhill
 oplot,xx,yhat,color=fsc_color('red')
 contour,xstyle=3,ystyle=3,/isotropic,eza/!dtor,title='EZA',levels=findgen(6)/5.*90,/downhill
 oplot,xx,yhat,color=fsc_color('red')
 ; now find points A and B and C and D and write 4x4 matrix
 sza_step=1.*!dtor
 openw,55,'ABCD_means.dat'
 fmt2='(4(1x,f7.2,1x,f7.2,1x,f9.2,1x,f7.2,1x,f7.2))'
 for sza_find=epsi,!pi/2-epsi,sza_step do begin
     for eza_find=!pi/2.-eza_step,eza_step,-eza_step do begin
         Amean=-999
         Bmean=-999
         Cmean=-999
         Dmean=-999

         ; A and B symmetric about photoequator
         idx=where(sza ge sza_find-sza_step/2. and sza lt sza_find+sza_step/2. and eza ge eza_find-eza_step/2. and eza lt eza_find+eza_step/2.)
         if (n_elements(idx) gt 10) then extractmeansabcd,'AorB',idx,obs,lon,lat,eza,sza,xx,res,Ameanlon,Ameanlat,Amean,Ameanezas,Ameanszas,Bmeanlon,Bmeanlat,Bmean,Bmeanezas,Bmeanszas

         ; C and D symmetric about photoequator and MM
         idx=where(eza ge sza_find-sza_step/2. and eza lt sza_find+sza_step/2. and sza ge eza_find-eza_step/2. and sza lt eza_find+eza_step/2.)
         if (n_elements(idx) gt 10) then extractmeansabcd,'CorD',idx,obs,lon,lat,eza,sza,xx,res,Cmeanlon,Cmeanlat,Cmean,Cmeanezas,Cmeanszas,Dmeanlon,Dmeanlat,Dmean,Dmeanezas,Dmeanszas
;
         if (Amean ne -999 and Bmean ne -999 and Cmean ne -999 and Dmean ne -999) then begin
		printf,55,format=fmt2,Ameanlon,Ameanlat,Amean,Ameanezas,Ameanszas,Bmeanlon,Bmeanlat,Bmean,Bmeanezas,Bmeanszas,Cmeanlon,Cmeanlat,Cmean,Bmeanezas,Bmeanszas,Dmeanlon,Dmeanlat,Dmean,Bmeanezas,Bmeanszas
         endif
     endfor
     endfor
 close,55
 end
