data=get_data('new.collected_Lap_signature_results.txt')
LAPalb=reform(data(0,*))
Albedo_lap=reform(data(1,*))
;
clemfile='CLEM.testing_JAN_21_2015.txt'
n=n_elements(LAPalb)
get_lun,ufydex
openw,ufydex,'lap_vs_JAN.dat'
for i=0,n-1,1 do begin
spawn,'rm hejsa'
str="grep "+string(LAPalb(i),format='(f15.7)')+" "+clemfile+" | awk '{print $2}'  > hejsa"
spawn,str
if ((file_info('hejsa')).(20) gt 0) then print,format='(i4,1x,f15.7,10(1x,f9.5))',i,LAPalb(i),Albedo_lap(i),get_data('hejsa')
if ((file_info('hejsa')).(20) gt 0) then printf,ufydex,format='(f15.7,10(1x,f9.5))',LAPalb(i),Albedo_lap(i),get_data('hejsa')
endfor
close,ufydex
free_lun,ufydex
data=get_data('lap_vs_JAN.dat')
l=size(data,/dimensions)
ncols=l(0)-2
nrows=l(1)
JD=reform(data(0,*))
LAPalb=reform(data(1,*))
JANalb=reform(data(2:ncols+1,*))
;
plot,/isotropic,LAPalb,avg(JANalb,0),xtitle='Albedo from Laplacian',ytitle='Albedo from fits',charsize=1.9,psym=7,title='Demo of method-dependency'
xra=[max([!x.crange(0),!y.crange(0)]),min([!x.crange(1),!y.crange(1)])]
yra=xra
oploterr,LAPalb,avg(JANalb,0),STDDEV(JANalb,dimension=1)
oplot,xra,yra,linestyle=2
str=strcompress('Mean and SD of difference: '+string(mean(LAPalb-avg(JANalb,0)),format='(f9.4)')+' +/- '+string(stddev(LAPalb-avg(JANalb,0)),format='(f9.4)'))
print,str
xyouts,/normal,0.3,0.2,str
end
