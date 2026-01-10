nn=fix(512/4)
fixed_pattern=randomn(seed,nn,nn)*0.3
print,'log1o(STD) of fixed pattern frame: ',alog10(stddev(fixed_pattern))
 openw,5,'data.dat'
 for i=10,1000,10 do begin
     x=fltarr(nn,nn,i)
     for j=0,i-1,1 do x(*,*,j)=1.0d0*randomn(seed,nn,nn)+fixed_pattern
     sum=total(x,3,/double)
     printf,5,i,stddev(sum/double(i+1))
     endfor
 close,5
 data=get_data('data.dat')
 n=reform(data(0,*))
 std=reform(data(1,*))
 logn=alog10(n)
 logstd=alog10(std)
 !P.CHARSIZE=2
 tstr=strcompress('Adding randomn frames of size '+string(nn)+' by '+string(nn))
 plot,psym=-7,logn,logstd,xtitle='log!d10!n(N)',ytitle='log!d10!n(!7r!3)',$
 title=tstr,yrange=[min([alog10(stddev(fixed_pattern)),logstd]),max(logstd)]
 res=linfit(logn,logstd,yfit=yhat,sigma=sigs,/double)
 oplot,logn,yhat
 print,'LINFIT Res: ',res
 print,'LINFIT Err: ',sigs
 res=ladfit(logn,logstd,/double)
 yhat=res(0)+res(1)*logn
 oplot,logn,yhat,color=fsc_color('red')
 plots,[!X.CRANGE],[alog10(stddev(fixed_pattern)),alog10(stddev(fixed_pattern))],linestyle=2
 print,'LADFIT Res: ',res
 end
 
