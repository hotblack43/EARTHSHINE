ideal=readfits('ideal_2455945.1776847.fits',h)
nrepeat=10
for irepeat=0,nrepeat-1,1 do begin
outname=strcompress('../2455945.1776847_noise'+string(fix(irepeat))+'.fits',/remove_all)
print,outname
str='./syntheticmoon ideal_2455945.1776847.fits '+outname+' 1.7 100 '+string(fix(randomu(seed)*10000))
spawn,str
im=readfits(outname)
writefits,outname,im,h
endfor
end

