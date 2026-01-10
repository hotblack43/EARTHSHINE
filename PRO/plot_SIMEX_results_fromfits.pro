PRO godobootstrap,x,y,boot_slope,boot_slope_sigma
 n=n_elements(x)
 nMC=100
 slopes=[]
 for iMC=0,nMC-1,1 do begin
     idx=long(randomu(seed,n)*n)
     xx=x(idx)
     yy=y(idx)
     res=robust_linefit(xx,yy)
     slopes=[slopes,res(1)]
     endfor
 !P.CHARSIZE=1.8
 !X.style=3
 !y.style=3
 histo,title='Bootstrap results',xtitle='Slope',slopes,min(slopes),max(slopes),(max(slopes)-min(slopes))/77.
 boot_slope=median(slopes)
 boot_slope_sigma=robust_sigma(slopes)
 oplot,[0,0],[!y.crange],linestyle=2
 oplot,[boot_slope,boot_slope],[!y.crange]
 Z=abs(boot_slope/boot_slope_sigma)
 if (z ge 3) then print,format='(a,1x,f4.1)','  Significant slope: Z=',Z
 if (z lt 3) then print,format='(a,1x,f4.1)','Insignificant slope: Z=',Z
 return
 end
 
 PRO plotthestuff,data_in,ytitstr
 d=2
 X = [-d, 0, d, 0, -d]
 Y = [0, d, 0, -d, 0]
 USERSYM, X, Y,/fill

 data=data_in
 plot,psym=1,xstyle=3,ystyle=3,data(0,*)+0.02*randomn(seed,n_elements(data(0,*))),data(1,*),xtitle='!7k!3',ytitle=ytitstr,title='SIMEX',charsize=1.7,xrange=[-1,max(data(0,*))]
 findreplicationsandreturnbinmeans,data,xx,yy,zz
 pcol=!P.COLOR
 !P.COLOR=fsc_color('red')
 oploterr,xx,yy,zz,8
 xxx=findgen(200)/199.*(max(xx)+1)-1
 ;
 res=robust_linefit(xx,yy,yfit,sig,sigs)
 print,ytitstr,' robust_linefit slope is: ',res(1),' +/- ',sigs(1)
 yhat=res(0)+res(1)*xxx
 oplot,xxx,yhat,color=fsc_color('red')
 res=ladfit(xx,yy)
 print,ytitstr,' ladfit slope is        : ',res(1)
 yhat=res(0)+res(1)*xxx
 oplot,xxx,yhat,color=fsc_color('gray')
 oplot,[-1,-1],[!Y.crange],linestyle=2
	degree=2
 res=robust_poly_fit(xx,yy,degree)
 yhat=0.0
 for order=0,degree,1 do yhat=yhat+res(order)*xxx^order
 oplot,xxx,yhat,color=fsc_color('green'),thick=2
 oplot,[-1,-1],[!Y.crange],linestyle=2
 !P.COLOR=pcol
 godobootstrap,xx,yy,boot_slope,boot_slope_sigma
 print,'Bootstrapping gives median slope: ',boot_slope,' +/- ',boot_slope_sigma
 return
 end
 
 PRO findreplicationsandreturnbinmeans,data,xx,yy,zz
 lambda=reform(data(0,*))
 simex=reform(data(1,*))
 sorted=lambda(sort(lambda))
 uniqlambdas=sorted(uniq(sorted))
 xx=[]
 yy=[]
 zz=[]
 for i=0,n_elements(uniqlambdas)-1,1 do begin
     idx=where(lambda eq uniqlambdas(i))
     if (n_elements(idx) ge 2) then begin
         print,'Found ',n_elements(idx),' for lambda=',uniqlambdas(i)
         xx=[xx,mean(lambda(idx),/double)]
         yy=[yy,mean(simex(idx),/double)]
         zz=[zz,stddev(simex(idx)/sqrt(n_elements(idx)),/double)]
         endif
     endfor
 return
 end
 
 data=get_data('SIMEX_results_fromfits.dat')
 lambda=reform(data(0,*))
 albedo=reform(data(4,*))
 alfa=reform(data(1,*))
 pedestal=reform(data(3,*))
 bbeta=reform(data(2,*))
 idx=where(abs(bbeta-median(bbeta)) lt 5*robust_sigma(bbeta) and abs(alfa-median(alfa)) lt 5*robust_sigma(alfa) and abs(pedestal-median(pedestal)) lt 5*robust_sigma(pedestal))
 ;idx=where(alfa le 2 and abs(pedestal-mean(pedestal)) lt 3.*robust_sigma(pedestal))
 data=data(*,idx)
 lambda=reform(data(0,*))
 albedo=reform(data(4,*))
 alfa=reform(data(1,*))
 bbeta=reform(data(2,*))
 pedestal=reform(data(3,*))
 ;
 !P.MULTI=[0,1,2]
 ;
 print,'------------------------------------------'
 plotthestuff,data([0,4],*),'Albedo'
 a12=get_kbrd()
 print,'------------------------------------------'
 plotthestuff,data([0,1],*),'!7a!3'
 a12=get_kbrd()
 print,'------------------------------------------'
 plotthestuff,data([0,2],*),'!7b!3'
 a12=get_kbrd()
 print,'------------------------------------------'
 plotthestuff,data([0,3],*),'Pedestal'
 a12=get_kbrd()
 print,'------------------------------------------'
 end
