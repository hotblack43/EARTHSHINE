PRO ffunct, X, A, F, pder
;-------------
; First the Voigt core
 idx=where(x le 1.0)
 damp=a(2)
 u=x(idx)/a(3)
 F=a(0)+a(1)*voigt(damp,u)
 Xnew=x(idx)
;-------------
 jdx=where(x gt 0.9 and x le 13)
 sum1=0.0
 for k=4,n_elements(a)-1,1 do sum1=sum1+a(k)/x(jdx)^(k-4)
 F = [F,sum1]
 Xnew=[Xnew,x(jdx)]
 Fnew=INTERPOL(F,Xnew,x)
 F=Fnew
 END

 PRO gomanuallyfitcore,im,coords
 a=''
 while (a ne 'q') do begin
 print,coords
 openw,55,'profile.dat'
 for i=0,511,1 do begin
 for j=0,511,1 do begin
 d=6.67/60.*sqrt((i-coords(0))^2+(j-coords(1))^2)
 printf,55,d,im(i,j)
 endfor
 endfor
 close,55
 data=get_data('profile.dat')
 plot_oo,yrange=[1e-2,1e5],data(0,*),data(1,*),$
     psym=3,xrange=[0.1,55],xstyle=3,ystyle=3
 print,'enter u d r l or q'
 a=get_kbrd()
 if (a eq 'r') then coords(0)=coords(0)+0.25
 if (a eq 'l') then coords(0)=coords(0)-0.21
 if (a eq 'u') then coords(1)=coords(1)+0.25
 if (a eq 'd') then coords(1)=coords(1)-0.21
 endwhile
 return
 end
 PRO gofitcurvestoPSF
 common names,name
 data=get_data(name+'_d.dat')
 x=reform(data(0,*))
 idx=where(x le 13 )
 x=reform(data(0,idx))
 y=reform(data(1,idx))
 idx=sort(x)
 x=x(idx)
 y=y(idx)
 plot_oo,$
 xtitle='Radius [arcmin]',x,y,psym=3,xstyle=3,$
 ystyle=3,xrange=[0.1,55],yrange=[1e-2,1e5]
;...............
 degree=8
 a=19.*randomu(seed,degree)
 a[0]=0.043
 a[1]=60000.0d0
 a[2]=0.045
 a[3]=0.15
 
 fita= findgen(degree)*0+1
 ;fita(0)=0
 fita(2)=0
 fita(3)=0
 yhat = CURVEFIT( x, Y, weights, A , sigs, /DOUBLE,$
 fita=fita,FUNCTION_NAME='ffunct', itmax=1000,$
 tol=1e-7,/NODERIVATIVE,STATUS=hej)
 print,'STATUS: ',hej
 for l=0,degree-1,1 do begin
     str=string(l)+': '+string(A(l))+' +/- '+string(sigs(l),format='(f7.3)')+' Z: '+string(a(l)/sigs(l),format='(f5.1)')
     xyouts,/normal,0.1,0.4-l*0.03,str
     endfor
 oplot,x,yhat,color=fsc_color('blue')
; save
 openw,33,'PSF_'+name+'.dat'
 for logr=alog10(min(x)),alog10(max(x)),(alog10(max(x))-alog10(min(x)))/100. do begin
 yy=INTERPOL(yhat,x,10^(logr))
 printf,33,10^logr,yy
 endfor
 close,33
 return
 end
 
 
 
 ;-----------------------------------------------
 ; Does fitting of curves to thge MARKAB PSF
 common names,name
 name='SIRIUS'
 name='ALTAIR'
 im=readfits(name+'_stacked_V.fits')
 ;im=readfits('MARKAB_stacked_V.fits')
 ;im=readfits('jupiter_stacked_V.fits')
 im=double(im)
 im=im-0.34;+0.2
 m1=median(im(0:100,0:100))
 m2=median(im(411:511,0:100))
 m3=median(im(411:511,411:511))
 m4=median(im(0:100,411:511))
 mm=mean([m1,m2,m3,m4])
 print,'Corner block mean: '+string(mm)
 idx=where(im eq max(im))
 coords=array_indices(im,idx)
 print,'Estimated peak: ',coords
 w=75
 subim=im(coords(0)-w:coords(0)+w,coords(1)-w:coords(1)+w)
 Result = GAUSS2DFIT( subim, A,/TILT); [, X, Y] [, FITA=vector] [, MASK=array] [, /NEGATIVE] [, /TILT] )
 x0=a(4)+coords(0)-w
 y0=a(5)+coords(1)-w
 print,'GAUSS 2d fit: ',x0,y0
 x0=177.130 
 y0=249.870
 ;coords=[x0,y0]
 ;gomanuallyfitcore,im,coords
 ;x0=coords(0)
 ;y0=coords(1)
 openw,44,name+'_d.dat'
 for i=0,511,1 do begin
     for j=0,511,1 do begin
         d=6.67/60.*sqrt((i-x0)^2+(j-y0)^2) 
         printf,44,d,im(i,j)
         endfor
     endfor
 close,44
 gofitcurvestoPSF
 end
