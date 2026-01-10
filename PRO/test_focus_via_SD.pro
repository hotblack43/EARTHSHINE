filter='_IRCUT_'
spawn,'grep '+filter+' allfocustofindfiles.txt | grep 2456045 > foundthese.txt'
get_lun,tth
openw,tth,'focusdat.txt'
openr,87,'foundthese.txt'
i=0
while not eof(87) do begin
str=''
readf,87,str
im=readfits(str)
print,i,stddev(im)/total(im),str
printf,tth,i,stddev(im)/total(im)
i=i+1
endwhile
close,87
close,tth
free_lun,tth
data=get_data('focusdat.txt')
i=reform(data(0,*))
f=reform(data(1,*))
plot,i,f,ystyle=3,xstyle=3,psym=7,yrange=[0,max(f)]
end

