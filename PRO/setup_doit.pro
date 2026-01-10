openw,1,'doit.bat'
for i=1,255,1 do begin
printf,1,strcompress('ping 192.168.1.'+string(i))
endfor
close,1
print,'Done!'
end
