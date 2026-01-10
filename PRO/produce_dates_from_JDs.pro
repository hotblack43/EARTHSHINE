close,/all
openw,44,'dates.out'
openr,1,'all_fitted_JDs.txt'
while not eof(1) do begin
str=0.0d0
readf,1,str
caldat,str,mm,dd,yy,hh
printf,44,mm,dd,yy,hh
endwhile
close,1
close,44
end
