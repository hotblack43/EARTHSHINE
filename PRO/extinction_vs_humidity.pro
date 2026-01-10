PRO get_water,yearin,dayin,hourin,waterout,pout
common flags,iflag,fr,p,t,rhum
if (iflag ne 314) then begin
file='/data/pth/DATA/METFILES/camc_cleaned.dat'
data=get_data(file)
fr=reform(data(0,*))
p=reform(data(1,*))
t=reform(data(2,*))
rhum=reform(data(3,*))
iflag=314
endif
;----------------
timein=yearin+(dayin-1.)/365.25+(hourin/24./365.25)
waterout=INTERPOL(rhum,fr,timein)
pout=INTERPOL(p,fr,timein)
return
end



common flags,iflag,fr,p,t,rhum
iflag=999
openw,12,'p'
; get all extinctions from La Palma
file='/data/pth/DATA/CAMC/all_observational_nights_La_Palma.noheader'
data=get_data(file)
yy=reform(data(0,*))
mm=reform(data(1,*))
dd=reform(data(2,*))
ext=reform(data(5,*))
err=reform(data(6,*))
; plot
lonin=18.0
latin=28.0
for i=0,n_elements(yy)-1,1 do begin
yearin=yy(i)
dayin=julday(mm(i),dd(i),yy(i))-julday(1,1,yy(i))+1
print,dayin
hourin=0.1
get_water,yearin,dayin,hourin,waterout,pout
printf,12,ext(i),waterout,pout
endfor
close,12
data=get_data('p')
ext=reform(data(0,*))
water=reform(data(1,*))
pout=reform(data(2,*))
!P.MULTI=[0,1,3]
plot,ext,water,xtitle='Extinction',ytitle='Relative Humidity at telescope',charsize=1.7,title='La Palma',psym=7
plot_io,ext,water,xtitle='Extinction',ytitle='Relative Humidity at telescope',charsize=1.7,title='La Palma',psym=7,yrange=[0.01,15]
plot_oi,ext,pout,xtitle='Extinction',ytitle='Pressure',charsize=1.7,title='La Palma',psym=7,ystyle=1
end

