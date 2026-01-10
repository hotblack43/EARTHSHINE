j=2
openw,32,'testout.txt'
for i=0,9,1 do begin
name=strcompress('out'+string(j^i)+'.fits',/remove_all)
spawn,'./syntheticmoon onehundred.fits '+name+' 1.8 '+string(j^i)+' 7854'
im=readfits(name,/sil)
printf,32,j^i,stddev(im(100:200,100:200)),stddev(im(309-15:309+15,184-15:184+15))
print,j^i,stddev(im(100:200,100:200)),stddev(im(309-15:309+15,184-15:184+15))
endfor
close,32
!P.MULTI=[0,1,2]
!x.style=3
!y.style=3
data=get_data('testout.txt')
x=reform(data(0,*))
y=reform(data(1,*))
z=reform(data(2,*))
plot_oo,x,y,psym=7,xtitle='# of images coadded',ytitle='SD',title='100x100 square on sky'
plot_oo,x,z,psym=7,xtitle='# of images coadded',ytitle='SD',title='11x11 square on even Moon'
end
