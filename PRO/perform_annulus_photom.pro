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
 set_plot,'X'
 r=dblarr(64,64)
 file='/data/pth/DATA/ANDOR/OUTDATA/JD2455482/Capella_darkreduced_*.fits'
 starname='Capella'
 read,istar,prompt='What is the star number?'
 files=file_search(file,count=n)
 openw,2,strcompress('photometry_'+string(istar)+'.dat',/remove_all)
 outer_radius=25.*1
 inner_radius=20.*1
	 ADU=3.78	; photons/ADU 
     im=readfits(files(0),h,/NOSCALE)*ADU
 l=size(im,/dimensions)
 nrows=l(0)
	ncols=l(1)
     contour,im,/isotropic,xstyle=1,ystyle=1
 cursor,x0,y0
 for ii=0,n-1,1 do begin
     im=readfits(files(ii),h,/NOSCALE)*ADU
;actexp_str=h(where(strpos(h,'ACT-EXP') eq 0))
;ACTEXP=float(strmid(actexp_str,11,11))*1.0d-3	; actual exposure time in seconds
actexp=0.06
	im=im
     contour,im,/isotropic,xstyle=1,ystyle=1
res=gauss2dfit(im,b)
x0=b(4)
y0=b(5)
	print,'Using x0,y0:',x0,y0
     if (ii eq 0 ) then begin
         for i=0,ncols-1,1 do begin
             for j=0,nrows-1,1 do begin
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
     print,star,sky,err_star,err_sky,tot_err,medianval,actexp
     printf,2,istar,star,sqrt(star+sky),actexp
     endfor
 close,2
 data=get_data(strcompress('photometry_'+string(istar)+'.dat',/remove_all))
 f=reform(data(1,*))
 df=reform(data(2,*))
 actexp=reform(data(3,*))
 set_plot,'ps
 device,filename='figxyz.ps'
 !P.CHARSIZE=1.7
 plot,f,psym=3,ytitle='Pixel count',xtitle='Image number',title='Anulus photometry of '+starname+' .',ystyle=1
 oploterr,f,df
 device,/close
 set_plot,'ps
 device,filename='shutter_stability.ps'
 serie=[actexp(0:49),actexp(51:99)]
 plot,serie,ytitle='Measured exposure time',ystyle=1
 print,mean(serie),stddev(serie),stddev(serie)/mean(serie)*100.0,' %.'
 device,/close
 set_plot,'x
 end
