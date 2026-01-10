PRO get_am_fromJD,JD,am
 obsname='mlo'
 observatory,obsname,obs_struct
 lat=obs_struct.latitude
 lon=obs_struct.longitude
 ; get the phase and azimuth
 ; get the airmass
 moonpos, JD, RAmoon, DECmoon
 am = airmass(JD, RAmoon*!dtor, DECmoon*!dtor, lat*!dtor, lon*!dtor)
 return
 end
 
PRO get_filter_from_JD,JD,filterstr,filternumber
filternames=['B','V','VE1','VE2','IRCUT'] 
filternumbers=indgen(n_elements(filternames))
file='JD_and_filter.txt'
spawn,"grep "+string(JD,format='(f15.7)')+" "+file+" > hkjgvghjkv"
openr,22,'hkjgvghjkv'
str=''
readf,22,str
close,22
bits=strsplit(str,' ',/extract)
JDfound=double(bits(0))
filterstr=bits(1)
if (JD ne JDfound) then stop
filternumber=filternumbers(where(filternames eq filterstr))
return
end
 
 
 ;---------------------------------------------------
 data=get_data('JDandalbedos.dat')
 alb1=reform(data(1,*))
 alb2=reform(data(2,*))
 pct=(alb1-alb2)/(0.5*(alb1+alb2))*100.
 idx=where(abs(pct) lt 20 and alb1 ne 0 and alb2 ne 0)
 data=data(*,idx)
 datanew=[]
 for k=0,n_elements(data(0,*))-1,1 do begin
     get_am_fromJD,reform(data(0,k)),amitem
     get_filter_from_JD,reform(data(0,k)),filtername,filternum
     datanew=[[datanew],[data(*,k),amitem,filternum]]
     endfor
 data=datanew
 JD=reform(data(0,*))
 alb1=reform(data(1,*))
 alb2=reform(data(2,*))
 am=reform(data(3,*))
 pct=(alb1-alb2)/(0.5*(alb1+alb2))*100.
 pcolor=!P.color
 set_plot,'ps'
 device,/color
 decomposed=0
 device,filename='pct_vs_frJD_2.ps'
 plot,JD mod 1,pct,psym=7,xtitle='Fractional JD',ytitle='% change in albedo',xstyle=3,ystyle=3
 oplot,[!X.crange],[0,0],linestyle=1
 idx=where((jd mod 1) lt 0.5)
 oplot,jd(idx) mod 1,pct(idx),psym=7,color=fsc_color('red')
 print,'SD of morning: ',stddev(pct(idx))
 idx=where((JD  mod 1) ge 0.5)
 oplot,jd mod 1,pct,psym=7,color=fsc_color('blue')
 print,'SD of evening: ',stddev(pct(idx))
 device,/close
 spawn,'ps2pdf pct_vs_frJD_2.ps &'
 set_plot,'ps'
 device,/color
 decomposed=0
 device,filename='pct_histo_2.ps'
 !P.color=pcolor
 cgHistoplot,thick=3, pct, BINSIZE=0.096543,/line_fill,orientation=45,polycolor='black',xtitle='!7D!3 Albedo [%]'
 idx=where((jd mod 1) gt 0.5)
 cgHistoplot,pct(idx),BINSIZE=0.051543,/oplot,/fill,polycolor='blue'
 idx=where((JD mod 1) lt 0.5)
 cgHistoplot,pct(idx),BINSIZE=0.065543,/oplot,/fill,polycolor='red'
 oplot,[0,0],[!Y.crange],linestyle=2
 print,'Number of duplicates: ',n_elements(pct)
 print,float(n_elements(where(pct gt 0)))/n_elements(pct)*100.,' % have positive change'
 print,'Median change: ',median(pct)
 print,'SD           : ',stddev(pct)
 print,float(n_elements(where(pct gt 0.2)))/n_elements(pct)*100.,' % have change gt 0.2%'
 xyouts,0.6,30,'Median : '+string(median(pct),format='(f5.2)'),charsize=1.4
 xyouts,0.6,28,'SD : '+string(stddev(pct),format='(f5.1)'),charsize=1.4
 signature,pos=[0.6,-0.7],'made with /SCI/EARTHSHINE/make_histo.pro'
 device,/close
 spawn,'ps2pdf pct_histo_2.ps &'
 set_plot,'ps'
 device,/color
 decomposed=0
 device,filename='pct_vs_am.ps'
 ; morning
 idx=where((JD mod 1) lt 0.5)
 plot,/nodata,yrange=[-2,2],xstyle=3,ystyle=3,xrange=[1,8.5],am(idx),pct(idx),psym=7,xtitle='Airmass',ytitle='% albedo change'
 oplot,color=fsc_color('red'),am(idx),pct(idx),psym=7
 res=ladfit(am(idx),pct(idx))
 yhat=res(0)+res(1)*am(idx)
 oplot,am(idx),yhat,color=fsc_color('red')
 ; evening
 idx=where((JD mod 1) gt 0.5)
 oplot,color=fsc_color('blue'),am(idx),pct(idx),psym=7
 res=ladfit(am(idx),pct(idx))
 yhat=res(0)+res(1)*am(idx)
 oplot,am(idx),yhat,color=fsc_color('blue')
 device,/close
 spawn,'ps2pdf pct_vs_am.ps'
 set_plot,'ps'
 device,/color,filename='albedo_vs_fracJD.ps'
 decomposed=0
 plot,xstyle=3,ystyle=3,JD mod 1,(alb1+alb2)/2.,psym=7,xtitle='Fractional JD',ytitle='Albedo'
 idx=where(data(4,*) eq 0.0)
 oplot,JD(idx) mod 1,(alb1(idx)+alb2(idx))/2.,psym=7,color=fsc_color('blue')
 idx=where(data(4,*) eq 1.0)
 oplot,JD(idx) mod 1,(alb1(idx)+alb2(idx))/2.,psym=7,color=fsc_color('green')
 idx=where(data(4,*) eq 2.0)
 oplot,JD(idx) mod 1,(alb1(idx)+alb2(idx))/2.,psym=7,color=fsc_color('orange')
 idx=where(data(4,*) eq 3.0)
 oplot,JD(idx) mod 1,(alb1(idx)+alb2(idx))/2.,psym=7,color=fsc_color('red')
 idx=where(data(4,*) eq 4.0)
 oplot,JD(idx) mod 1,(alb1(idx)+alb2(idx))/2.,psym=7,color=fsc_color('brown')
 device,/close
 spawn,'ps2pdf albedo_vs_fracJD.ps &'
 end
