PRO stats,array_in,name,lowQ,med,hiQ
array=array_in
array=array(sort(array))
n=n_elements(array)
lowQ=array(n*0.25)
med=median(array)
hiQ=array(0.75*n)
print,format='(a6,3(1x,f9.3))',name,lowQ,med,hiQ
return
end

names=['B','V','VE1','VE2','IRCUT']
!P.MULTI=[0,1,5]
for i=0,4,1 do begin
file=strcompress('contrast.'+names(i),/remove_all)
data=get_data(file)
histo,data,0.2,1.2,0.025,xtitle='contrast in '+names(i),/abs
stats,data,names(i),lowQ,med,hiQ
oplot,[med,med],[!Y.crange],linestyle=2
oplot,[lowQ,lowQ],[!Y.crange],linestyle=1
oplot,[hiQ,hiQ],[!Y.crange],linestyle=1
endfor
end
