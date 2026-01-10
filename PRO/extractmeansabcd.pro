PRO extractmeansabcd,strflag,idx,obs,lon,lat,xx,res,Ameanlon,Ameanlat,Amean,Bmeanlon,Bmeanlat,Bmean
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
                 printf,44,format='(i3,1x,f10.1,2(1x,f7.2))',iside,obs(idx(k)),lon(idx(k)),lat(idx(k))
                 endfor
             close,44
             data=get_data(filename)
             iside=reform(data(0,*))
             obse=reform(data(1,*))
             lons=reform(data(2,*))
             lats=reform(data(3,*))
             Adx=where(iside lt 0)
             Bdx=where(iside gt 0)
             if (n_elements(Adx) gt 2 and n_elements(Bdx)) then begin
                 ; group A (or C) mean properties
                 Amean=mean(obse(Adx))
                 Ameanlon=mean(lons(Adx))
                 Ameanlat=mean(lats(Adx))
                 ; group B (or D)
                 Bmean=mean(obse(Bdx))
                 Bmeanlon=mean(lons(Bdx))
                 Bmeanlat=mean(lats(Bdx))
	         if (strflag eq 'AorB') then begin	
                 print,'A: ',Ameanlon,Ameanlat,Amean
                 print,'B: ',Bmeanlon,Bmeanlat,Bmean
                 endif
	         if (strflag eq 'CorD') then begin	
                 print,'C: ',Ameanlon,Ameanlat,Amean
                 print,'D: ',Bmeanlon,Bmeanlat,Bmean
                 endif
             endif
     return
 end
