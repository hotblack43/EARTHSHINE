filternames=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
file='JD2456075_fluxes.dat'
for i=0,4,1 do begin
str='grep '+filternames(i)+' '+file+" | awk '{print $1}' > aha"
spawn,str
data=get_data('aha')
data=-2.5*alog10(data)+23.953217
print,filternames(i),mean(data),' +/- ',stddev(data)
endfor
end
