PRO fit_2d_gauss,im_in
	im=im_in
	weights=1.0d0/im
	kdx=where(im le 0)
	weights(kdx)=0.0
if (file_exist('bs') eq 1) then begin
b=reform(get_data('bs'))
endif
	yfit = mpfit2dpeak(im, B,/MOFFAT,weights=weights)
openw,1,'bs'
printf,1,format='(10(1x,f20.8))',b
close,1
 residuals=im-yfit
	print,'total reisudal:',sqrt(total(residuals^2))
print,'Offset :',b(0)
print,'Scale  :',b(1)
print,'sigmas :',b(2),b(3)
print,'X0,Y0  :',b(4),b(5)
print,'tilt   :',b(6)
print,'power  :',b(7)
width=20
surface,residuals(b(4)-width:b(4)+width,b(5)-width:b(5)+width)
stop
return
end

PRO get_inner_circle,im,x0,y0,inner_radius,star_and_sky
 common radius,r
 idx=where(r le inner_radius)
 print,n_elements(idx),' pixels inside inner circle.'
 print,'Circle: min and max',min(im(idx)),max(im(idx))
 star_and_sky=total(im(idx))
 print,'star_and_sky=',star_and_sky
 return
 end
 
 PRO get_sky,im,x0,y0,outer_radius,inner_radius,medianval
 common radius,r
 idx=where(r gt inner_radius and r le outer_radius)
 print,n_elements(idx),' pixels inside anulus.'
 print,'Anulus: min and max',min(im(idx)),max(im(idx))
 medianval=median(im(idx))
 print,'MV=',medianval
 return
 end
 
 common radius,r
 r=dblarr(512,512)
 file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455845/*ALTAIR*.fits'
 starname='ALTAIR'
 files=file_search(file,count=n)
 openw,2,'photometry.dat'
 outer_radius=12.*1
 inner_radius=9.*1
	 ADU=3.78	; photons/ADU 
 for ii=0,n-1,1 do begin
     im=readfits(files(ii))*ADU
	im=im
     ;contour,im,/isotropic
	tvscl,im
	res=gauss2dfit(im,b)
	x0=b(4)
	y0=b(5)
	print,'Fitted x0,y0:',x0,y0
     if (ii eq 0 ) then begin
         for i=0,512-1,1 do begin
             for j=0,512-1,1 do begin
                 star_and_sky=sqrt(float(i-x0)^2+float(j-y0)^2)
                 r(i,j)=star_and_sky
                 endfor
             endfor
         endif
; plot  cursor 
     plots,[x0,x0],[!Y.crange]
     plots,[!x.crange],[y0,y0]
     get_sky,im,x0,y0,outer_radius,inner_radius,medianval
     sky=medianval*!pi*inner_radius^2
     get_inner_circle,im,x0,y0,inner_radius,star_and_sky
     star=star_and_sky-sky
     err_star=sqrt(star)
     err_sky=sqrt(sky)
     tot_err=sqrt(star+sky)
     print,star,sky,err_star,err_sky,tot_err,medianval
     printf,2,star,sqrt(star+sky),sky
     endfor
 close,2
 data=get_data('photometry.dat')
 f=reform(data(0,*))
 df=reform(data(1,*))
 sky_f=reform(data(2,*))
 set_plot,'ps'
 !P.CHARSIZE=1.7
 plot,f,psym=3,ytitle='Pixel count',xtitle='Image number',title='Anulus photometry of '+starname+' .',ystyle=1
 oploterr,f,df
 device,/close
 end
