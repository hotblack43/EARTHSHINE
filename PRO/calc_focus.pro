!P.MULTI=[0,4,5]
bigfile='all_moffat_fitted.dat'
filters=['B','V','VE1','VE2','IRCUT']
for i=0,n_elements(filters)-1,1 do begin
filter=filters(i)
pname=strcompress('p'+filter,/remove_all)
spawn,"grep "+filter+" "+bigfile+" | sed 's/FOCUS/ /g' | sed 's/.fits//g' |  awk '{print $1,$2,$3,$4,$5,$6,$7,$8,$9,$11}' > "+pname
data=get_data(strcompress(pname,/remove_all))
offs=reform(data(0,*))
fact=reform(data(1,*))
sigx=reform(data(2,*))
sigy=reform(data(3,*))
x0=reform(data(4,*))
y0=reform(data(5,*))
tilt=reform(data(6,*))
power=reform(data(7,*))
sd=reform(data(8,*))
focusnum=reform(data(9,*))
ff=23000+(focusnum-80)*500.
ff=ff/1000
xmin=min(ff)
xmax=max(ff)
r=sqrt(sigx^2+sigy^2)
!P.CHARSIZE=1.1
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.CHARTHICK=1.2
plot,yrange=[0,max(r)],xrange=[xmin,xmax],xstyle=3,ystyle=3,ff,r,title='Focus in '+filter+' filter.',$
psym=1,xtitle='Focus position [1000 counts]',ytitle='Moffat radius [pixel]'
oplot,[!X.crange],[min(r),min(r)],linestyle=1
;
plot,yrange=[0,max(sd)],xrange=[xmin,xmax],psym=1,xstyle=3,ystyle=3,ff,sd,title=filter,xtitle='Focus position [1000 counts]',$
ytitle='SD'
oplot,[!X.crange],[max(sd),max(sd)],linestyle=1
;
plot,yrange=[0,max(power)],xrange=[xmin,xmax],psym=1,xstyle=3,ystyle=3,ff,power,title=filter,xtitle='Focus position [1000 counts]',$
ytitle='Moffat exponent'
oplot,[!X.crange],[min(power),min(power)],linestyle=1
;
plot,yrange=[0,max(fact)],xrange=[xmin,xmax],psym=1,xstyle=3,ystyle=3,ff,fact,title=filter,xtitle='Focus position [1000 counts]',$
ytitle='Moffat factor'
oplot,[!X.crange],[max(fact),max(fact)],linestyle=1
;
;histo,r^2*(fact-offs),0,max(r^2*(fact-offs)),(max(r^2*(fact-offs)))/15.
print,format='(a10,1x,f9.1)',filter,median(r^2*(fact-offs))
endfor
end
