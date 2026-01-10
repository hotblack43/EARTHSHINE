filters=['B','V','VE1','VE2','IRCUT']
for ifilter=0,4,1 do begin
filter=filters(ifilter)
str="grep "+filter+" alfas_allfilters.dat | awk '{print $1,$2}' > data_"+filter+".dat"
print,str
spawn,str
endfor
end
