PRO setupSEs,xin,yin,x,y
 types=xin(sort(xin))
 types=types(uniq(types))
 x=[]
 y=[]
 for ityp=0,n_elements(types)-1,1 do begin
     idx=where(xin eq types(ityp))
     if (idx(0) ne -1 and n_elements(idx) gt 1) then begin
         x=[x,types(ityp)]
         y=[y,stddev(yin(idx))/mean(yin(idx))*100.];/sqrt(n_elements(yin(idx)))]
;        y=[y,stddev(yin(idx))/mean(yin(idx))*100./sqrt(n_elements(yin(idx)))]
         endif
     endfor
 return
 end
 
 PRO goplot2,x,y,xx,yy,xxx,yyy,xtitstr,ytitstr,tstr,othercolor1,othercolor2,yran
 csize=1.4
 common legendpos,x1,y1,x2,y2
 plot_oi,xrange=[1,100],yrange=[min([y,yy,yyy]),max([y,yy,yyy])],title=tstr,xstyle=3,ystyle=3,x,y,psym=7,xtitle=xtitstr,ytitle=ytitstr
 ;
 oplot,xx,yy,color=othercolor1,psym=7
 ;
 oplot,xxx,yyy,color=othercolor2,psym=7
 return
 end
 
 PRO goplot1,x_in,y_in,xx_in,yy_in,xxx_in,yyy_in,xtitstr,ytitstr,tstr,othercolor1,othercolor2,yran
 csize=1.4
 common legendpos,x1,y1,x2,y2
 idx=sort(x_in)
 x=x_in(idx)
 y=y_in(idx)
 idx=sort(xx_in)
 xx=xx_in(idx)
 yy=yy_in(idx)
 idx=sort(xxx_in)
 xxx=xxx_in(idx)
 yyy=yyy_in(idx)
 yhere=[y,yy,yyy] 
 idx=where(yhere gt 0)
 ;yran=[min([min(yran),yhere(idx)]),max([yran,y,yy,yyy])]
 plot_oo,xrange=[1,100],yrange=yran,title=tstr,xstyle=3,ystyle=3,x,y,psym=7,xtitle=xtitstr,ytitle=ytitstr
 res=ladfit(alog10(x),alog10(y))
 res=robust_linefit(alog10(x),alog10(y))
 print,'Slope: ',res(1)
 yhat=res(0)+res(1)*alog10(x)
 oplot,(x),10^yhat
 ;
 oplot,xx,yy,color=othercolor1,psym=7
 res=ladfit(alog10(xx),alog10(yy))
 res=robust_linefit(alog10(xx),alog10(yy))
 print,'Slope: ',res(1)
 yhat=res(0)+res(1)*alog10(xx)
 oplot,(xx),10^yhat,color=othercolor1
 ;
 oplot,xxx,yyy,color=othercolor2,psym=7
 res=ladfit(alog10(xxx),alog10(yyy))
 res=robust_linefit(alog10(xxx),alog10(yyy))
 print,'Slope: ',res(1)
 yhat=res(0)+res(1)*alog10(xxx)
 oplot,(xxx),10^yhat,color=othercolor2
 return
 end
 PRO goplot3,x_in,y_in,xx_in,yy_in,xxx_in,yyy_in,xtitstr,ytitstr,tstr,othercolor1,othercolor2,yran
 csize=1.4
 common legendpos,x1,y1,x2,y2
 idx=sort(x_in)
 x=x_in(idx)
 y=y_in(idx)
 idx=sort(xx_in)
 xx=xx_in(idx)
 yy=yy_in(idx)
 idx=sort(xxx_in)
 xxx=xxx_in(idx)
 yyy=yyy_in(idx)
 yhere=[y,yy,yyy]
 idx=where(yhere gt 0)
 ;yran=[min(yhere(idx)),max([y,yy,yyy])]
 plot_oi,xrange=[1,100],yrange=yran,title=tstr,xstyle=3,ystyle=3,x,y,psym=7,xtitle=xtitstr,ytitle=ytitstr
 res=ladfit(alog10(x),alog10(y))
 res=robust_linefit(alog10(x),alog10(y))
 print,'Slope: ',res(1)
 yhat=res(0)+res(1)*alog10(x)
 oplot,(x),10^yhat
 ;
 oplot,xx,yy,color=othercolor1,psym=7
 res=ladfit(alog10(xx),alog10(yy))
 res=robust_linefit(alog10(xx),alog10(yy))
 print,'Slope: ',res(1)
 yhat=res(0)+res(1)*alog10(xx)
 oplot,(xx),10^yhat,color=othercolor1
 ;
 oplot,xxx,yyy,color=othercolor2,psym=7
 res=ladfit(alog10(xxx),alog10(yyy))
 res=robust_linefit(alog10(xxx),alog10(yyy))
 print,'Slope: ',res(1)
 yhat=res(0)+res(1)*alog10(xxx)
 oplot,(xxx),10^yhat,color=othercolor2
 return
 end
 
 ;------------------------------------------------------
 
 common legendpos,x1,y1,x2,y2
 ; want S.E: or S.E. of the mean?
 ifwantsemean=0
 ;------------------------------------------------------
 ; SETUP code for later plotting of results from CLEM files with 3 sorts 
 ; of data: unaligned, aligned with integer shiufts and aligned with subshift shifts
 
 CLEMfiles=[ 'CLEM.testing_sep26_2014.txt','CLEM.testing_OCT6_2014.txt','CLEM.testing_OCT8_2014.txt','CLEM.testing_OCT10_2014.txt','CLEM.testing_OCT13_2014.txt','CLEM.testing_OCT15_2014b.txt']
 for iCLEM=0,n_elements(CLEMfiles)-1,1 do begin
 file=CLEMfiles(iCLEM)
 ;
 spawn,"rm aha oho jaja data_unaligned.dat"
 spawn,"awk '{print $1}' "+file+" | sort | uniq > CLEM_JDnumber"
 spawn,"grep sum_of "+file+" |  grep -i UNaligned | awk '{print $2,$3,$11,$15}' > aha"
 spawn,"awk '{print $4}' aha | sed 's/_/ /g' | awk '{print $7}' > oho"
 spawn,"awk '{print $1,$2,$3}' aha > jaja"
 spawn,"paste jaja oho > data_unaligned.dat"
 data=get_data('data_unaligned.dat')
 albedo=reform(data(0,*))
 delta_albedo=(reform(data(1,*)))
 RMSE=(reform(data(2,*)))
 nframes=(reform(data(3,*)))
 
 
 spawn,"rm aha oho jaja data_aligned_intshift.dat"
 spawn,"grep sum_of "+file+" | grep aligned | grep integershift |  awk '{print $2,$3,$11,$15}' > aha"
 spawn,"awk '{print $4}' aha | sed 's/_/ /g' | awk '{print $(NF-3)}'  > oho"
 spawn,"awk '{print $1,$2,$3}' aha > jaja"
 spawn,"paste jaja oho > data_aligned_intshift.dat"
 intshift_data=get_data('data_aligned_intshift.dat')
 intshift_albedo=reform(intshift_data(0,*))
 intshift_delta_albedo=(reform(intshift_data(1,*)))
 intshift_RMSE=(reform(intshift_data(2,*)))
 intshift_nframes=(reform(intshift_data(3,*)))
 
 spawn,"rm aha oho jaja data_aligned_subshift.dat"
 spawn,"grep sum_of "+file+" | grep aligned | grep subpix| awk '{print $2,$3,$11,$15}' > aha"
 spawn,"awk '{print $4}' aha | sed 's/_/ /g' | awk '{print $(NF-3)}'  > oho"
 spawn,"awk '{print $1,$2,$3}' aha > jaja"
 spawn,"paste jaja oho > data_aligned_subshift.dat"
 aligned_subshift_data=get_data('data_aligned_subshift.dat')
 subshift_albedo=reform(aligned_subshift_data(0,*))
 subshift_delta_albedo=(reform(aligned_subshift_data(1,*)))
 subshift_RMSE=(reform(aligned_subshift_data(2,*)))
 subshift_nframes=(reform(aligned_subshift_data(3,*)))
 ;
 ; PLOTTING PART
 data=get_data('data_unaligned.dat')
 idx=where(data(1,*) gt 0)
 data=data(*,idx)
 albedo=reform(data(0,*))
 delta_albedo=(reform(data(1,*)))
 RMSE=(reform(data(2,*)))
 nframes=(reform(data(3,*)))
 
 intshift_data=get_data('data_aligned_intshift.dat')
 idx=where(intshift_data(1,*) gt 0)
 intshift_data=intshift_data(*,idx)
 intshift_albedo=reform(intshift_data(0,*))
 intshift_delta_albedo=(reform(intshift_data(1,*)))
 intshift_RMSE=(reform(intshift_data(2,*)))
 intshift_nframes=(reform(intshift_data(3,*)))
 
 aligned_subshift_data=get_data('data_aligned_subshift.dat')
 idx=where(aligned_subshift_data(1,*) gt 0)
 aligned_subshift_data=aligned_subshift_data(*,idx)
 subshift_albedo=reform(aligned_subshift_data(0,*))
 subshift_delta_albedo=(reform(aligned_subshift_data(1,*)))
 subshift_RMSE=(reform(aligned_subshift_data(2,*)))
 subshift_nframes=(reform(aligned_subshift_data(3,*)))
 ;
 ;
 !P.MULTI=[0,2,2]
 x1=0.8
 y1=-0.6
 x2=0.8
 y2=-0.7
 print,'RMSE:'
 goplot1,nframes,RMSE,intshift_nframes,intshift_RMSE,subshift_nframes,subshift_RMSE,'N-frames','RMSE','G: intshifts, O: sub, B: none',fsc_color('green'),fsc_color('orange'),[0.009,1.1]
 ; and the header ..
JD=get_data('CLEM_JDnumber')
xyouts,/normal,0.2,1.02,'JD: '+string(JD,format='(f15.7)')
 print,'delta_albedo:'
 goplot1,nframes,delta_albedo,intshift_nframes,intshift_delta_albedo,subshift_nframes,subshift_delta_albedo,'N-frames','!7D!3n A','G: intshifts, O: sub, B: none',fsc_color('green'),fsc_color('orange'),[0.0009,0.09]
 ;
 print,'albedo:'
 goplot3,nframes,albedo,intshift_nframes,intshift_albedo,subshift_nframes,subshift_albedo,'N-frames','Terr. Albedo','G: intshifts, O: sub, B: none',fsc_color('green'),fsc_color('orange'),[min([albedo,intshift_albedo,subshift_albedo]),max([albedo,intshift_albedo,subshift_albedo])]
 ;
 setupSEs,nframes,albedo,x,y
 setupSEs,intshift_nframes,intshift_albedo,xx,yy
 setupSEs,subshift_nframes,subshift_albedo,xxx,yyy
 print,'S.E.m:'
 goplot1,x,y,xx,yy,xxx,yyy,'N-frames','S.E.m of A in %',$
 'G: intshifts, O: sub, B: none',fsc_color('green'),$
 fsc_color('orange'),[0.01,1.1]
 endfor;
 end
