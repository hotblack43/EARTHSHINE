file='OUTPUT/LunarImg_ideal_0000.fit'
im1=readfits(file,header1)
file='OUTPUT/LunarImg_ideal_0001.fit'
im2=readfits(file,header2)
ratio=im1/im2
plot,ratio(*,600),ystyle=1,charsize=2,yrange=[0.99,1.01],xtitle='Column number in row 600',xstyle=1,ytitle='Pixel intensity ratio',title='Image ratios at 1 min intervals'
nims=60
for i=2,nims-1,1 do begin
if (i le 9) then file=strcompress('OUTPUT/LunarImg_ideal_000'+string(i)+'.fit',/remove_all)
if (i ge 10) then file=strcompress('OUTPUT/LunarImg_ideal_00'+string(i)+'.fit',/remove_all)
im2=readfits(file,header2)
ratio=im1/im2
oplot,ratio(*,600)
endfor
end
