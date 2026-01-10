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
     radius=float(strmid(header(jdx),11,19))
     endelse
 x0=x0(0)
 y0=y0(0)
 radius=radius(0)
 return
 end

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
 
;---------------------------------------------------------------------------------
; Code that compares symmetric points on the lunar surface obs vs ideal
; Version 2.  Based on 'drizzling points'
;---------------------------------------------------------------------------------
;
 !P.CHARSIZE=1.2
 !P.thick=3
 !x.thick=2
 !y.thick=2
 lowpath='/data/pth/CUBES/'
 imname='cube_2455945.1776847_V_.fits'
 imname='cube_2456104.8348311_B_.fits'
 imname='cube_2455938.8451638_V_.fits'
 imname='cube_2456029.0366521_V_.fits'
 cube=readfits(lowpath+imname,h)
 gofindradiusandcenter_fromheader,h,x0,y0,radius
 obs=reform(cube(*,*,0))
 ideal=reform(cube(*,*,4))
 lon=reform(cube(*,*,5))
 lat=reform(cube(*,*,6))
 sza=reform(cube(*,*,7))
 eza=reform(cube(*,*,8))
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
     coords=array_indices(show,idx(jdx))
     printf,33,format=fmt1,eza(idx(jdx)),sza(idx(jdx)),coords(0),coords(1)
     endfor
 close,33
 !P.MULTI=[0,2,1]
 ;tvscl,[[show/total(show)],[ideal/total(ideal)]]
 data=get_data('photoequator.dat')
 x=reform(data(2,*))
 y=reform(data(3,*))
 res=linfit(x,y)
 xx=findgen(512)
 yhat=res(0)+res(1)*xx
 ; nowpick a point
 epsi=0.005
 fmt3='(2(1x,f9.4),4(1x,f9.4))'


     show=obs
 ldx=where(obs gt 3000)
 nldx=n_elements(ldx)
 ndrizzle=1000
     openw,77,'symmetricstoplot.dat'
 for idrizzle=0,ndrizzle-1,1 do begin
 ipt=randomu(seed)*512.*512.
 while (obs(ipt) lt 1000) do begin
 ipt=randomu(seed)*512.*512.
 endwhile
 coords=array_indices(obs,ipt)
 icol=coords(0)
 irow=coords(1)
         eza_got_A=eza(icol,irow)
         sza_got_A=sza(icol,irow)
         if (sza_got_A lt !pi/2.-epsi and eza_got_A lt !pi/2.-epsi) then begin
             ideal_got_A=ideal(icol,irow)
             obs_got_A=obs(icol,irow)
             ; now find the other point(s) with same eza and sza
             idx=where(abs(eza - eza_got_A) lt epsi and abs(sza - sza_got_A) lt epsi)
             if (idx(0) ne -1) then begin
                 show(idx)=max(show)
                 ;sort them into which side they are according to the phgotoequator
                 openw,44,'sides.dat'
                 Ax=min(xx)
                 Bx=max(xx)
                 Ay=res(0)+res(1)*Ax
                 By=res(0)+res(1)*Bx
                 for k=0,n_elements(idx)-1,1 do begin
                     coords=array_indices(obs,idx(k))
                     Cx=coords(0)
                     Cy=coords(1)
                     whichside,Ax,Ay,Bx,By,Cx,Cy,iside
                     printf,44,format='(i3,2(1x,f10.1),4(1x,f9.4))',iside,obs(idx(k)),ideal(idx(k)),lon(idx(k)),lat(idx(k)),eza(idx(k)),sza(idx(k))
                     endfor
                 close,44
                 data=get_data('sides.dat')
                 isides=reform(data(0,*))
                 obsvals=reform(data(1,*))
                 idealvals=reform(data(2,*))
                 lonvals=reform(data(3,*))
                 latvals=reform(data(4,*))
                 ezavals=reform(data(5,*))
                 szavals=reform(data(6,*))
                 A_idx=where(isides gt 0)
                 B_idx=where(isides lt 0)
                 if (n_elements(A_idx) gt 1 and n_elements(B_idx) gt 1) then begin
                     ; redefine group A
                     A_obs_got=median(obsvals(A_idx))
                     A_ideal_got=median(idealvals(A_idx))
                     A_ezas_got=median(ezavals(A_idx))
                     A_szas_got=median(szavals(A_idx))
                     ; define group B
                     B_obs_got=median(obsvals(B_idx))
                     B_ideal_got=median(idealvals(B_idx))
                     B_ezas_got=median(ezavals(B_idx))
                     B_szas_got=median(szavals(B_idx))
                     if (finite(A_obs_got/B_obs_got) and finite(A_ideal_got/B_ideal_got)) then begin
                         printf,format=fmt3,77,A_obs_got/B_obs_got,A_ideal_got/B_ideal_got,A_ezas_got,B_ezas_got,A_szas_got,B_szas_got
                         endif
                     endif else begin
                     print,'Not enough points found.'
                     endelse
                 endif
             endif; end of if for sza above hoiurozon
         endfor	; loop over ndrizzle
     close,77
     ; plot it
     data=get_data('symmetricstoplot.dat')
;    obsratio=reform(data(0,*))
;    idealratio=reform(data(1,*))
;    ezaA=reform(data(2,*))
;    szaA=reform(data(4,*))
;    mndx=sort(szaA)
;    data=data(*,mndx)
     obsratio=reform(data(0,*))
     idealratio=reform(data(1,*))
     ezaA=reform(data(2,*))
     ezaB=reform(data(3,*))
     szaA=reform(data(4,*))
     szaB=reform(data(5,*))
     mean_eza=(ezaA+ezaB)/2.0
     mean_sza=(szaA+szaB)/2.0
     !P.MULTI=[0,1,3]
     !P.CHARSIZE=1.5
     !P.thick=3
     !x.thick=2
     !y.thick=2
     plot,title='Black: observed ratio, Red: ideal ratio',xstyle=3,ystyle=3,yrange=[min([obsratio,idealratio]),max([obsratio,idealratio])],mean_eza,obsratio,xtitle='EZA',ytitle='A/B and A*/B*',psym=7
     oplot,mean_eza,idealratio,psym=7,color=fsc_color('red')
     plot,xstyle=3,ystyle=3,yrange=[min([obsratio,idealratio]),max([obsratio,idealratio])],mean_sza,obsratio,xtitle='SZA',ytitle='A/B and A*/B*',psym=7,title='Blue curve: model for obs based on ideal'
     oplot,mean_sza,idealratio,psym=7,color=fsc_color('red')
;    res2=linfit(idealratio,obsratio,/double,yfit=yhat2)
;    oplot,mean_sza,yhat2,color=fsc_color('blue')
     plot,/isotropic,idealratio,obsratio,psym=7,xtitle='A/B ideal',ytitle='A/B observed'
     res=ladfit(idealratio,obsratio)
     yhat4=res(0)+res(1)*idealratio
     oplot,idealratio,yhat4,color=fsc_color('green')
     x1=min([idealratio,obsratio])
     x2=max([idealratio,obsratio])
     oplot,[x1,x2],[x1,x2],color=fsc_color('blue')
     print,'R= ',correlate(idealratio,obsratio)
     xyouts,/data,x1+(x2-x1)/5.,x1-(x2-x1)/5.,'R='+string(correlate(idealratio,obsratio),format='(f4.2)')
     !P.MULTI=[1,3,1]
     contour,/isotropic,show,xstyle=3,ystyle=3,/cell_fill,nlevels=11
 end
