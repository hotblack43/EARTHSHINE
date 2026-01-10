n=10000L
 x=fltarr(n)
 openw,11,'d.dat'
 for mu=100,1,-1 do begin
     for i=0L,n-1,1 do x(i)=fix(randomn(seed,poisson=mu))
     print,mu,(mu-mean(x))/float(mu)*100.,' %.'
     printf,11,mu,(mu-mean(x))/float(mu)*100.
     endfor
 close,11
 data=get_data('d.dat')
 x=reform(data(0,*))
 y=reform(data(1,*))
 plot,x,y,charsize=2,xtitle='!7l!3',ytitle='% error',title=strcompress('Error of mean of '+string(long(n))+' Poisson nos. with Pop. mean !7l!3'),yrange=[-1.5,1.5]
; now repeat
 nrepeat=10
 for irepeat=1,nrepeat,1 do begin
 x=fltarr(n)
     openw,11,'d.dat'
     for mu=100,1,-1 do begin
         for i=0L,n-1,1 do x(i)=fix(randomn(seed,poisson=mu))
         print,mu,(mu-mean(x))/float(mu)*100.,' %.'
         printf,11,mu,(mu-mean(x))/float(mu)*100.
         endfor
     close,11
     data=get_data('d.dat')
     x=reform(data(0,*))
     y=reform(data(1,*))
     oplot,x,y
     endfor
 end
