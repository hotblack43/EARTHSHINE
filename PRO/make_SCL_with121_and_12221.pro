;----------
file='Solar.Maxima.weights'
string=' Solar Maxima - Rz'
type='M'
;----------
file='Solar.Minima.weights'
string=' Solar Minima - Rz'
type='m'

;----------
data=get_data(file)
date_extr=reform(data(0,*))
uncert=reform(data(1,*))
nmax=n_elements(date_extr)
;---------------------------
; do 121
n121=nmax-3
date121=fltarr(n121)
SCL_121=fltarr(n121)
deltaSCL121=fltarr(n121)
j=0
openw,3,strcompress('SCL_121'+string+'.data',/remove_all)
openw,4,'tab.tex'
	fmt='(3a,f5.1,a,f7.1,a,f5.2,a,f5.2,a)'
for i=1,n121-1,1 do begin
	l1=date_extr(i+1)-date_extr(i)
	l2=date_extr(i+2)-date_extr(i+1)
	l3=date_extr(i+3)-date_extr(i+2)
	SCL_121(j)=(1.0*l1+2.0*l2+1.0*l3)/(1.+2.+1.)
	deltaSCL121(j)=sqrt(uncert(i)^2+uncert(i+1)^2+uncert(i+2)^2+uncert(i+3)^2)/4.
	date121(j)=(date_extr(i+1)+date_extr(i+2))/2.0
 	print,format='(f6.1,1x,a,1x,f3.1)',date_extr(i+1),type,uncert(i+1)
	print,format='(a28,f5.2,1x,f7.2,1x,f5.2,1x,f5.2,1x,a)','                          ',l2,date121(j),round(SCL_121(j)*100.0)/100.0,deltaSCL121(j);,strcompress(string+' 121')
	printf,3,format='(f6.1,1x,a,1x,f3.1)',date_extr(i+1),type,uncert(i+1)
	printf,3,format='(a28,f5.2,1x,f7.2,1x,f5.2,1x,f5.2,1x,a)','                          ',l2,date121(j),round(SCL_121(j)*100.0)/100.0,deltaSCL121(j);,strcompress(string+' 121')
	printf,4,format='(f6.1,a,a,a,f3.1,5a)',round(date_extr(i+1)*10.)/10.,' & ',type,' & ',round(uncert(i+1)*10.)/10.,' & ',' & ',' & ',' & ','\\'
	printf,4,format=fmt,' & ',' & ',' & ',round(l2*10)/10.0,' &',round(date121(j)*10.)/10.,' &',round(SCL_121(j)*100.0)/100.0,' & ',round(deltaSCL121(j)*100.)/100.,'\\'

	j=j+1
end
close,3
close,4
end
