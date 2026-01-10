file='zombeck.tab'
data=get_data(file)
z=reform(data(0,*))
OneMinusAg=double(reform(data(1,*)))
z=z(0:4)
OneMinusAg=OneMinusAg(0:4)
;
Ag=1.0d0-OneMinusAg
;Ag=OneMinusAg
;
for i=0,n_elements(z)-1,1 do begin
print,i,z(i),ag(i)
endfor
plot_io,z,Ag,psym=7
res=linfit(alog(Ag),z,/double,yfit=yhat)
oplot,Ag,yhat,color=fsc_color('red')
end
