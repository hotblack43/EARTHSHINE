PRO get_mean_RON_forstack,dark,RON
RON=-911
l=size(im)
if (l(0) lt 3) then return
n=l(2)
for i=0,n-2,1 do begin
im1=im(*,*,i)
im2=im(*,*,i+1)
d=im1-im2
print,'RON = ',stddev(d)/sqrt(2),' ADU.'
if (i eq 0) then list=stddev(d)/sqrt(2)
if (i gt 0) then list=[list,stddev(d)/sqrt(2)]
endfor
RON=mean(list)
return
end

openr,1,'allDARKfiles'
openw,5,'rons.dat'
i=0
while not eof(1) do begin
name1=''
name2=''
readf,1,name1
readf,1,name2
dark1=readfits(name1,/silent)
dark2=readfits(name2,/silent)
d=dark1-dark2
ron=stddev(d)/sqrt(2.)
print,i,'RON mean: ',ron,' ADU'
printf,5,ron
i=i+1
endwhile
close,1
close,5
data=get_data('rons.dat')
histo,data,min(data),max(data),0.1
end
