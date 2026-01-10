mnames=['January','February','March','April','May','June','July','August','September','October','November','December']
file='Chris_list_good_images.txt'
openr,1,file
openw,2,'Good_images_DATES.txt'
while not eof(1) do begin
str=0.0d0
readf,1,str
caldat,str,mm,dd,yy,hh
printf,2,yy,' ',mnames(mm),dd,hh
endwhile
close,1
close,2
end
