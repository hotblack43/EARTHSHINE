n=100
bias=100.0
org=readfits('idel_to_use_for_simulated_stack.fits')
for i=0,n-1,1 do begin
dx=randomn(seed)
dy=randomn(seed)
im=shift_sub(org,dx,dy)
writefits,'thiswasidealshifted.fits',im
seednum=long(randomu(seed)*10000)
str='./syntheticmoon thiswasidealshifted.fits out.fits 1.73 1 '+string(seednum)
spawn,str
RON=randomn(seed,512,512)*2.14	; this is the read outnoise
im=long(readfits('out.fits')+bias+RON)
tvscl,hist_equal(im)
if (i eq 0) then stack=im
if (i gt 0) then stack=[[[stack]],[[im]]]
endfor
writefits,'ideal_stack_jiggled.fit',stack
end
