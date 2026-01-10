PRO getrobustslopeinloglog,data,slope,uncert,interc,xxx,yhat
x=alog10(reform(data(0,*)))
y=alog10(reform(data(1,*)))
n=n_elements(x)
nMC=1000
openw,55,'temp2.dat'
for iMC=0,nMC-1,1 do begin
idx=fix(randomu(seed,n)*n)
res=robust_linefit(x(idx),y(idx))
printf,55,res(0),res(1)
endfor
close,55
data=get_data('temp2.dat')
slope=median(data(1,*))
interc=median(data(0,*))
uncert=robust_sigma(data(1,*))
xxx=alog10(findgen(100))
yhat=10^(interc+slope*xxx)
xxx=10^(xxx)
return
end

;Analyses the halo profis on the dark and bright sides of the SKE
; the point being that one sees diffracted (and internally reflected light only) whereas the other sees that as well as scattered light in the atmsophere
!P.MULTI=[0,1,1]
!P.charsize=2
!P.charthick=3
!P.THICK=3
restore,'summed_laserprofle.sav'
profi=profile
x0=184.0d0
a=''
while (a ne 'q') do begin
line1=(profi(x0:*))
xx1=findgen(n_elements(line1))
line2=reverse(profi(0:x0))
xx2=findgen(n_elements(line2))
plot_oo,xx1,line1,xtitle='Distance from profi center [pixels]',title='Summed profi',xrange=[1,512],yrange=[1e-3,1e4],xstyle=3,ystyle=3
oplot,xx2,line2,color=fsc_color('red')
a=get_kbrd()
if (a eq 'l') then x0=x0-0.2345
if (a eq 'r') then x0=x0+0.32345
print,x0
endwhile
!P.MULTI=[0,1,1]
set_plot,'X'
;--- get the wing part of theprofi
print,'Now click on wings-part of that profi'
cursor,a1,b1
wait,0.3
oplot,[a1,a1],[2,200],linestyle=2
cursor,a2,b2
oplot,[a2,a2],[2,200],linestyle=2
wait,0.3
openw,44,'wings.dat'
idx=where(xx1 ge a1 and xx1 le a2)
for k=0,n_elements(idx)-1,1 do printf,44,xx1(idx(k)),line1(idx(k))
idx=where(xx2 ge a1 and xx2 le a2)
for k=0,n_elements(idx)-1,1 do printf,44,xx2(idx(k)),line2(idx(k))
close,44
data=get_data('wings.dat')
getrobustslopeinloglog,data,slope,uncert,interc,xxx,yhat
oplot,xxx,yhat,color=fsc_color('blue')
print,'Alfa = ',slope,' +/- ',uncert
xyouts,/data,20,3000,'!7a!3='+string(slope,format='(f6.2)')+' +/- '+string(uncert,format='(f4.2)')
write_png,'laserprofifigure.png',tvrd(/true)
set_plot,'ps'
plot_oo,xx1,line1,xtitle='Distance from profi center [pixels]',title='Summed profile',xrange=[1,512],yrange=[1e-3,1e4],xstyle=3,ystyle=3
oplot,xx2,line2,color=fsc_color('red')
oplot,[a1,a1],[2,200],linestyle=2
oplot,[a2,a2],[2,200],linestyle=2
oplot,xxx,yhat,color=fsc_color('blue')
xyouts,/data,20,3000,'!7a!3='+string(slope,format='(f6.2)')+' +/- '+string(uncert,format='(f4.2)'),charsize=1.1
device,/close
set_plot,'X'
end
