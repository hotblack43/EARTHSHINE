!P.MULTI=[0,1,2]
!P.CHARSIZE=1.7
;---------------B----------------
Spawn,"awk '{print $6,$2}' red_star_B.dat > red.dat"
Spawn,"awk '{print $6,$2}' blue_star_B.dat > blue.dat"
red=get_data('red.dat')
blue=get_data('blue.dat')
plot,xrange=[1.0,2.0],xtitle='Airmass',ytitle='Machine mags',title='NGC6633, pair of red/blue stars',ystyle=3,yrange=[-6.5,-5.5],red(0,*),red(1,*),psym=7
oplot,red(0,*),red(1,*),psym=7,color=fsc_color('red')
res=ladfit(red(0,*),red(1,*))
print,'Red stars slope: ',res(1)
yhat_red=res(0)+res(1)*red(0,*)
oplot,red(0,*),yhat_red
xyouts,/normal,0.3,0.92,'B filter'
xyouts,/normal,0.3,0.8,'Red stars slope: '+string(res(1),format='(f5.3)')+' mags/Z'
oplot,blue(0,*),blue(1,*),psym=7,color=fsc_color('green')
res=ladfit(blue(0,*),blue(1,*))
xyouts,/normal,0.3,0.65,'Blue stars slope: '+string(res(1),format='(f5.3)')+' mags/Z'
yhat_blue=res(0)+res(1)*blue(0,*)
print,'Blue stars slope: ',res(1)
oplot,blue(0,*),yhat_blue
;---------------V----------------
Spawn,"awk '{print $6,$2}' red_star_V.dat > red.dat"
Spawn,"awk '{print $6,$2}' blue_star_V.dat > blue.dat"
red=get_data('red.dat')
blue=get_data('blue.dat')
plot,xrange=[1.0,2],xtitle='Airmass',ytitle='Machine mags',title='NGC6633, pair of red/blue stars',ystyle=3,yrange=[-7.2,-6.7],red(0,*),red(1,*),psym=7
oplot,red(0,*),red(1,*),psym=7,color=fsc_color('red')
res=ladfit(red(0,*),red(1,*))
print,'Red stars slope: ',res(1)
yhat_red=res(0)+res(1)*red(0,*)
oplot,red(0,*),yhat_red
xyouts,/normal,0.3,0.92-0.5,'V filter'
xyouts,/normal,0.3,0.8-0.5,'Red stars slope: '+string(res(1),format='(f5.3)')+' mags/Z'
oplot,blue(0,*),blue(1,*),psym=7,color=fsc_color('green')
res=ladfit(blue(0,*),blue(1,*))
xyouts,/normal,0.3,0.65-0.5,'Blue stars slope: '+string(res(1),format='(f5.3)')+' mags/Z'
yhat_blue=res(0)+res(1)*blue(0,*)
print,'Blue stars slope: ',res(1)
oplot,blue(0,*),yhat_blue
end
