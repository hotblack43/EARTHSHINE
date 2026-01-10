spawn,"awk 'NF == 10 ''' Desktop/Dropbox/sketchbook/BMP085_Plotter/logged.txt > ligged.txt"
data=get_data('ligged.txt')
mm=reform(data(0,*))
dd=reform(data(1,*))
yy=reform(data(2,*))
hh=reform(data(3,*))
mi=reform(data(4,*))
ss=reform(data(5,*))
T=reform(data(6,*))
p=reform(data(7,*))/100.
atm=reform(data(8,*))
alt=reform(data(9,*))
jd=double(julday(mm,dd,yy,hh,mi,ss))
hour=(jd-double(julday(mm,dd,yy,00,00,01)))*24.0
!P.CHARSIZE=2
!P.CHARthick=2
!P.THICK=2
!x.THICK=2
!y.THICK=2
!P.MULTI=[0,1,2]
plot,title='BMP085 pressure gauge',ystyle=3,hour,p,xtitle='Hours since last midnight',ytitle='Pressure [HPa]'
plot,title='BMP085 pressure gauge',ystyle=3,hour,T,xtitle='Hours since last midnight',ytitle='T [C]'
end

