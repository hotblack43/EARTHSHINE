restore,'darkstack.sav'
l=size(stack,/dimensions)
ncols=l(0)
nrows=l(1)
npix=l(2)
mn=fltarr(npix)
std=fltarr(npix)
for i=0,npix-1,1 do begin
mn(i)=mean(stack(*,*,i))
std(i)=stddev(stack(*,*,i))
endfor
ratio=std/mn
idx=where(ratio gt 0.19 and ratio lt 0.22 and std lt 213)
ratio=ratio(idx)
mn=mn(idx)
std=std(idx)
!p.multi=[0,1,3]
histo,mn,1020,1040,.2
histo,std,200,220,1
histo,ratio,0.13,0.25,0.0015
!p.multi=[0,1,1]
plot,mn(idx),std(idx),psym=7,xstyle=1,ystyle=1
stack=double(stack(*,*,idx))
writefits,'fixed-darkstack.fit',stack
; calculate median
median_dark=median(stack,/double,dimension=3)
idx=where(median_dark lt 990 or median_dark gt 1090)
median_dark(idx)=median(median_dark)
surface,median_dark,title='Median dark',charsize=2
median_dark=smooth(median_dark,5,/edge_truncate)
surface,median_dark,title='Smoothed'
writefits,'median_dark_smoothed.fit',median_dark
l=size(stack,/dimensions)
npix=l(2)
openw,4,'ron_std.dat'
for i=0,npix-2,2 do begin
	ron=stack(*,*,i)-stack(*,*,i+1)
	printf,4,stddev(ron)/sqrt(2)
endfor
close,4
stdron=get_data('ron_std.dat')
histo,stdron,min(stdron),max(stdron),.2,xtitle='RON'
print,'median std of RON=',median(stdron)
end