openw,4,'aha'
openr,3,'extracted_AVTIME.dat'
while not eof(3) do begin
t=0.0d0 & s=''
readf,3,t
for alfa=0.10,0.90,0.05 do begin
print,'./go_a.scr '+string(alfa)+string(t,format="(f20.6)")
printf,4,'./go_a.scr '+string(alfa)+string(t,format="(f20.6)")
endfor
endwhile
close,3
close,4
print,' The file aha should now be renamed do_many.scr and executed'
end
