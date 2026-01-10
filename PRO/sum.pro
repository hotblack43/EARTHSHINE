path='/data/pth/DATA/ANDOR/Test_26May2011/'
str='ra_17_32_30_dec_m27_55_23'
str='19_38_dec_m18_12_24'
files=file_search(strcompress(path+'*'+str+'.fits',/remove_all),count=n)
for i=0,n-1,1 do begin
im=readfits(files(i))
if (i eq 0) then sum=im
if (i gt 0) then sum=sum+im
endfor
writefits,strcompress(strcompress('SUMMED_'+str+'.fits',/remove_all)),sum
end
