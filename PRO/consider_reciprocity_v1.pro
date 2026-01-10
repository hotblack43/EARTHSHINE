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
 show=obs
;show=ideal
 epsi=0.01
 !P.CHARSIZE=1.3
 !P.thick=4
 !x.thick=3
 !y.thick=3
 phaseanglefromheader,h,angle
 print,'Phase angle S-M-E: ',angle,' radians.'
 ; set the mirror meridan solar zenith angle
 za=angle/2.
 ; now consder offsets from the MM
 ; first one side
 for za_small=1.*!dtor,angle/5.,1.*!dtor do begin
     show=obs
;    show=ideal
     window,1
     tvscl,show
     print,'za_small is: ',za_small
     za1=za-za_small
     idx=where(sza le za1+epsi and sza ge za1-epsi and eza gt epsi)
     openw,44,'oneside_sza_eza.dat'
fmt='(2(1x,f7.3),1x,f8.1,2(1x,f8.2))'
     for k=0,n_elements(idx)-1,1 do begin
         printf,44,format=fmt,sza(idx(k)),eza(idx(k)),obs(idx(k)),lon(idx(k)),lat(idx(k))
         print,format=fmt,sza(idx(k)),eza(idx(k)),obs(idx(k)),lon(idx(k)),lat(idx(k))
         ; plot the pixel
         show(idx(k))=max(show)
         tvscl,show
         endfor	; end of k loop
     close,44
     ; Then the other side
     za2=za+za_small
     print,'left, right za: ',za1,za2
     idx=where(sza le za2+epsi and sza ge za2-epsi and eza gt epsi)
     openw,44,'otherside_sza_eza.dat'
     for k=0,n_elements(idx)-1,1 do begin
         printf,44,format=fmt,sza(idx(k)),eza(idx(k)),obs(idx(k)),lon(idx(k)),lat(idx(k))
         print,format=fmt,sza(idx(k)),eza(idx(k)),obs(idx(k)),lon(idx(k)),lat(idx(k))
         ; plot the pixel
         show(idx(k))=max(show)
         tvscl,show
         endfor	; end of k loop
     close,44
     data1=get_data('oneside_sza_eza.dat')
     solar1=reform(data1(0,*))
     earth1=reform(data1(1,*))
     inten1=reform(data1(2,*))
     data2=get_data('otherside_sza_eza.dat')
     solar2=reform(data2(0,*))
     earth2=reform(data2(1,*))
     inten2=reform(data2(2,*))
     xmin=min([earth1,earth2])
     xmax=max([earth1,earth2])
     ymax=max([inten1,inten2])
     window,2
     plot,xrange=[xmin,xmax],yrange=[0,ymax],xstyle=3,ystyle=3,/nodata,earth1,inten1*cos(earth1),psym=7,xtitle='EZA [radians]',ytitle='counts*cos(EZA)',title='SZA: '+string(mean(solar1))+' to '+string(mean(solar2))
     oplot,earth1,inten1*cos(earth1),psym=7,color=fsc_color('blue')
     oplot,earth2,inten2*cos(earth2),psym=7,color=fsc_color('red')
     wait,1
     ;stop
     endfor	; end of za_small loop
 end
