PRO powersp,im,ps
im=im/total(im,/double)
z=fft(im,-1,/double)
zz=z*conj(z)
ps=double(zz)
return
end

stack=readfits('/media/thejll/OLDHD/MOONDROPBOX/JD2456014/2456014.7192459MOON_V_AIR.fits.gz')
im_orig=reform(stack(*,*,0))
powersp,im_orig,ps_orig
for i=1,99,1 do begin
im=reform(stack(*,*,i))
dx=256*(randomu(seed)-0.5)
dy=256*(randomu(seed)-0.5)
im_shifted=shift(im,dx,dy)
powersp,im_shifted,ps_shifted
ratio=ps_orig/ps_shifted
diff=(ps_shifted-ps_orig)/ps_orig*100.0
;tvscl,hist_equal(diff)
plot,ratio(*,0),/ylog
;print,format='(2(1x,e20.10))',min(ratio),max(ratio)
endfor
end
