ref=readfits('deal_albedo_0p1_alfa_1p8.fits')
for i=2,9,1 do begin
str=string(i)
im1=readfits(strcompress('deal_albedo_0p'+str+'_alfa_1p8.fits',/remove_all))
w=5
ratio=im1/ref
DS=mean(ratio(126-w:126+w,248-w:248+w))
BS=mean(ratio(369-w:369+w,312-w:312+w))
print,i,'DS BS ratios: ',DS,BS
endfor
end
