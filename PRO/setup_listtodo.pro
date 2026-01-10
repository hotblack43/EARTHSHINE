 fnamestouse=['B','V','VE1','VE2','IRCUT']
openw,2,'listtodo_fn'
openr,1,'infiles_fn'
while not eof(1) do begin
name=''
readf,1,name
for i=0,n_elements(fnamestouse)-1,1 do begin
printf,2,format='(a,a,a)',name,' ',fnamestouse(i)
print,name,' ',fnamestouse(i)
endfor
endwhile
close,1
close,2
end
