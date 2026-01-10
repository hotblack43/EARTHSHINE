FUNCTION RACINE,x_in,y,f
 d0=0.00053
 x=x_in/60.*!dtor
z=x/2./d0
 print,'min,max z:',min(z),max(z)
 print,'min,max atan(z):',min(atan(z)),max(atan(z))
value=f*max(y)*cos(atan(x/2./d0))^3
return,value
end

 ;-----------------------------------------------
 ; Does fitting of Moffat and Racine curves to the MARKAB/SIRIUS/ALTAIR PSF
 common names,name
 name='ALTAIR'
 name='SIRIUS'
 name='MARKAB'
 im=readfits(name+'_stacked_V.fits')
 ;im=readfits('MARKAB_stacked_V.fits')
 ;im=readfits('jupiter_stacked_V.fits')
 im=double(im)
 im=im-mean(im(0:10,0:10))
 idx=where(im eq max(im))
 coords=array_indices(im,idx)
 print,'Estimated peak: ',coords
 w=75
 subim=im(coords(0)-w:coords(0)+w,coords(1)-w:coords(1)+w)
 Result = GAUSS2DFIT( subim, A,/TILT); [, X, Y] [, FITA=vector] [, MASK=array] [, /NEGATIVE] [, /TILT] )
 x0=a(4)+coords(0)-w
 y0=a(5)+coords(1)-w
 print,'GAUSS 2d fit: ',x0,y0
 openw,44,'d.dat'
 for i=0,511,1 do begin
     for j=0,511,1 do begin
         d=6.67/60.*sqrt((i-x0)^2+(j-y0)^2) 
         printf,44,d,im(i,j)
         endfor
     endfor
 close,44
 data=get_data('d.dat')
 x=reform(data(0,*))
 y=reform(data(1,*))
 idx=sort(x)
 x=x(idx)
 y=y(idx)
 idx=where(x lt 0.42)
 yfit = mpfitpeak(x(idx), y(idx), a,moffat=moffat,nterms=6)
 print,'a:',a
 yfit = mpfitpeak(x(idx), y(idx), a,moffat=moffat,nterms=6)
 print,'a:',a
 print,'Peak height: ',a(0)
 print,'Shift      : ',a(1)
 print,'HWHM       : ',a(2)
 !P.MULTI=[0,1,1]
 plot_oo,title=name+' fitted w. Moffat and Racine profiles',x,y,psym=3,xrange=[0.01,100],yrange=[0.01,1e5],xtitle='R [arc min]'
 oplot,x(idx),yfit,color=fsc_color('red')
 oplot,[0.01,0.3],[a(0),a(0)],linestyle=2
 oplot,[a(2),a(2)],[1e2,1e5],linestyle=2
 xyouts,/data,a(2),1e2,'HWHM: '+string(a(2),format='(f5.3)')
;
raci=RACINE(x,y,0.00042)
 oplot,x,raci,color=fsc_color('orange')
stop
 plot_oo,title=name+' fitted w. Moffat and ...',x/a(2),y/a(0),psym=7,xrange=[0.1,100],yrange=[1e-5,1],ystyle=3,xtitle='R [1/HWHM]'
 end
