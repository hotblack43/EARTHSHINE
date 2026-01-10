PRO get_filter_from_JD,JD,filterstr,filternumber
filternames=['B','V','VE1','VE2','IRCUT']
filternumbers=indgen(n_elements(filternames))
file='JD_and_filter.txt'
spawn,"grep "+string(JD,format='(f15.7)')+" "+file+" > hkjgvghjkv"
openr,22,'hkjgvghjkv'
str=''
readf,22,str
close,22
bits=strsplit(str,' ',/extract)
JDfound=double(bits(0))
filterstr=bits(1)
if (JD ne JDfound) then stop
filternumber=filternumbers(where(filternames eq filterstr))
return
end

data=get_data('BBSO_FM.dat')
jd=reform(data(0,*))
ph=reform(data(1,*))
log=reform(data(2,*))
d_log=reform(data(3,*))
FM=reform(data(4,*))
d_FM=reform(data(5,*))
am=reform(data(6,*))
filterstr=[]
for iJD=0,n_elements(JD)-1,1 do begin
get_filter_from_JD,JD(iJD),str
filterstr=[filterstr,str]
endfor
!P.MULTI=[0,2,5]
!P.charsize=1.4
!P.thick=4
!P.charthick=3
idx=where(filterstr eq 'B' and am lt 3)
yra=[0,1]
xra=[min(ph),max(ph)]
plot,xrange=xra,ystyle=3,yrange=yra,xtitle='Lunar phase [F=0]',ytitle='A',ph(idx),log(idx),psym=1,title='B'
oplot,ph(idx),FM(idx),psym=1,color=fsc_color('red')
plot,yrange=[0,1],am(idx),log(idx),psym=7,xtitle='Airmass',ytitle='A',title='B'
oplot,am(idx),FM(idx),psym=7,color=fsc_color('red')

idx=where(filterstr eq 'V' and am lt 3)
yra=[0,1]
plot,xrange=xra,ystyle=3,yrange=yra,xtitle='Lunar phase [F=0]',ytitle='A',ph(idx),log(idx),psym=1,title='V'
oplot,ph(idx),FM(idx),psym=1,color=fsc_color('red')
plot,yrange=[0,1],am(idx),log(idx),psym=7,xtitle='Airmass',ytitle='A',title='V'
oplot,am(idx),FM(idx),psym=7,color=fsc_color('red')

idx=where(filterstr eq 'VE1' and am lt 3)
yra=[0,1]
plot,xrange=xra,ystyle=3,yrange=yra,xtitle='Lunar phase [F=0]',ytitle='A',ph(idx),log(idx),psym=1,title='VE1'
oplot,ph(idx),FM(idx),psym=1,color=fsc_color('red')
plot,yrange=[0,1],am(idx),log(idx),psym=7,xtitle='Airmass',ytitle='A',title='VE1'
oplot,am(idx),FM(idx),psym=7,color=fsc_color('red')

idx=where(filterstr eq 'IRCUT' and am lt 3)
yra=[min([log(idx),FM(idx)]),max([log(idx),FM(idx)])]
yra=[0,1]
plot,xrange=xra,ystyle=3,yrange=yra,xtitle='Lunar phase [F=0]',ytitle='A',ph(idx),log(idx),psym=1,title='IRCUT'
oplot,ph(idx),FM(idx),psym=1,color=fsc_color('red')
plot,yrange=[0,1],am(idx),log(idx),psym=7,xtitle='Airmass',ytitle='A',title='IRCUT'
oplot,am(idx),FM(idx),psym=7,color=fsc_color('red')

idx=where(filterstr eq 'VE2' and am lt 3)
yra=[min([log(idx),FM(idx)]),max([log(idx),FM(idx)])]
yra=[0,1]
plot,xrange=xra,ystyle=3,yrange=yra,xtitle='Lunar phase [F=0]',ytitle='A',ph(idx),log(idx),psym=1,title='VE2'
oplot,ph(idx),FM(idx),psym=1,color=fsc_color('red')
plot,yrange=[0,1],am(idx),log(idx),psym=7,xtitle='Airmass',ytitle='A',title='VE2'
oplot,am(idx),FM(idx),psym=7,color=fsc_color('red')
end
