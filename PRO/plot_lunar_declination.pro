listen=[]
for jd=julday(1,1,1976,0,0,0.0),julday(12,31,2000,0,0,0.0),1.387654786 do begin
MOONPOS, jd, ra_moon, DECmoon, dis
listen=[[listen],[jd,DECmoon,dis]]
endfor
jd0=julday(1,1,1976,0,0,0.0)
fracyear=(listen(0,*)-jd0)/365.25+1976.0
declination=reform(listen(1,*))
set_plot,'ps'
device,/landscape
!P.MULTI=[0,1,1]
!P.charsize=1.8
!P.thick=0.5
!P.charthick=2
!X.style=3
!Y.style=3
plot,fracyear,declination,xtitle='Year',title='Lunar declination'
oplot,[!X.crange],[0,0],thick=4,color=255
;plot,fracyear,listen(2,*)/384000.0,xtitle='Year',ytitle='R/Ro'
device,/close
end
