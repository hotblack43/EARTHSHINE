im1=readfits('stacked_CoADD_Mode_Moon_ANDOR.FIT')
im2=readfits('stacked_LundMode_Moon_ANDOR.FIT')
a=''
rl_shift=-25
ud_shift=27
od=3500.0
exp_1=0.009d0
exp_2=30.0d0
while (a ne 'q') do begin
ratio_image=(im1/exp_1)/(im2/exp_2)
ratio_image(180:511,0:511)=ratio_image(180:511,0:511)/od
window,1,xsize=512,ysize=512
tvscl,ratio_image
a=get_kbrd()
if (a eq 'f') then od=od/1.02
if (a eq 'F') then od=od*1.02
if (a eq 'r') then rl_shift=rl_shift-1
if (a eq 'l') then rl_shift=rl_shift+1
if (a eq 'u') then ud_shift=ud_shift-1
if (a eq 'd') then ud_shift=ud_shift+1
if (a eq 'r') then im2=shift(im2,[-1,0])
if (a eq 'l') then im2=shift(im2,[+1,0])
if (a eq 'u') then im2=shift(im2,[0,-1])
if (a eq 'd') then im2=shift(im2,[0,+1])
print,'Shifts, OD so far:',rl_shift,ud_shift,od
line=ratio_image(*,256)
window,3,xsize=512,ysize=512
plot,line
oplot,[!X.crange],[1.0,1.0]
endwhile
end
