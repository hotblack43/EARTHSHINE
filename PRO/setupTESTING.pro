for offset=0.0,0.4,0.1 do begin
for angle=-180.9,180.9,2*36. do begin

print,strcompress('SETKNIFEEDGE,SKE,'+string(angle)+','+string(offset)+',,,,',/remove_all)
print,strcompress('SHOOTSINGLES,1,1,512,512,TESTINGSKE,,,,',/remove_all)
endfor
endfor
end
