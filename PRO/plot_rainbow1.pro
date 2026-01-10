FILNAMS=['B','V','VE1','VE2','IRCUT']
for ifilter=0,n_elements(FILNAMS)-1,1 do begin
file='rainbow1.dat'
openr,1,file
jd=0.0d0
ds=0.0
dserr=0.0
bs=0.0
ratio=0.0
name=''
ic=0
while not eof(1) do begin
readf,1,jd,ds,dserr,bs,ratio,name
name=strcompress(name,/remove_all)
if (name eq filnams(ifilter)) then begin
if (ic eq 0) then line=[jd,ds,dserr,bs,ratio]
if (ic gt 0) then line=[[line],[jd,ds,dserr,bs,ratio]]
ic=ic+1
endif
endwhile
close,1
l=size(line,/dimensions)
openw,23,strcompress(filnams(ifilter)+'_rainbow.dat',/remove_all)
for i=0,l(1)-1,1 do begin
printf,23,format='(f15.7,4(1x,g15.7))',line(*,i)
endfor
close,23
endfor
;................
data=get_data('V_rainbow.dat')
jd0=min(data(0,*))
plot,xtitle='JD fraction on Dec 20 2011',ytitle='total/mean(DS)',/nodata,data(0,*)-jd0,data(4,*)
oplot,data(0,*)-jd0,data(4,*),color=fsc_color('blue')
oploterr,data(0,*)-jd0,data(4,*),data(2,*)
;
data=get_data('VE2_rainbow.dat')
oplot,data(0,*)-jd0,data(4,*),color=fsc_color('red')
oploterr,data(0,*)-jd0,data(4,*),data(2,*)
;
data=get_data('B_rainbow.dat')
oplot,data(0,*)-jd0,data(4,*),color=fsc_color('cyan')
oploterr,data(0,*)-jd0,data(4,*),data(2,*)
;
data=get_data('VE1_rainbow.dat')
oplot,data(0,*)-jd0,data(4,*),color=fsc_color('orange')
oploterr,data(0,*)-jd0,data(4,*),data(2,*)
;
data=get_data('IRCUT_rainbow.dat')
oplot,data(0,*)-jd0,data(4,*),color=fsc_color('yellow')
oploterr,data(0,*)-jd0,data(4,*),data(2,*)
end
