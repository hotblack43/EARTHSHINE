PRO bootstrap,arr_first,arr_second
n=n_elements(arr_first)
l=size(arr_first)
idx=fix(randomu(seed,n)*n)
if (l(0) eq 1) then begin
arr_first=arr_first(idx)
arr_second=arr_second(idx)
endif
if (l(0) eq 2) then begin
l2=size(arr_first,/dimensions)
arr2=rebin(arr_first,l2(0)*l2(1),1)
arr2=arr2(idx)
arr_first=rebin(arr2,l2(0),l2(1))
;
l2=size(arr_second,/dimensions)
arr2=rebin(arr_second,l2(0)*l2(1),1)
arr2=arr2(idx)
arr_second=rebin(arr2,l2(0),l2(1))
endif
if (l(0) gt 2) then stop
return
end

FUNCTION get_alfa_from_filename,filnam
a1=strmid(filnam,35,5)
strput,a1,'.',1
alfa=float(a1)
return, alfa
end

FUNCTION petersfunc2,pars
common stuff,ideal_in,im_in,a,b,c,d,e,f,DS_error
common bootstrap,if_boot,stack
offset=pars(0)
factor=pars(1)
;ideal=(ideal_in+offset)*factor
ideal=ideal_in*factor+offset
im=im_in
;
subim_ideal=ideal(*,200:300)
subim_ideal=avg(subim_ideal,1)
subim_im=im(*,200:300)
subim_im=avg(subim_im,1)
subim_im=alog10(subim_im)
subim_ideal=alog10(subim_ideal)
plot_io,subim_im,xtitle='Image column #',ytitle='log!d10!n(slice)'
oplot,subim_ideal,color=fsc_color('red')
value=total((subim_im(a:b)-subim_ideal(a:b))^2+(subim_im(c:d)-subim_ideal(c:d))^2)
plots,[a,a],[1,10]
plots,[b,b],[1,10]
plots,[c,c],[1,10]
plots,[d,d],[1,10]
DS_error=total((subim_im(e:f)-subim_ideal(e:f))^2)
plots,[e,e],[1,10],linestyle=2
plots,[f,f],[1,10],linestyle=2
if (if_boot eq 1) then begin
print,'Boostrapping ...'
nboot=50
for iboot=0,nboot-1,1 do begin
;print,'iboot:',iboot
ideal=ideal_in*factor+offset
;
thing1=ideal(*,200:300)
thing2=im_in(*,200:300)
bootstrap,thing1,thing2
subim_ideal=thing1
subim_ideal=avg(subim_ideal,1)
subim_im=thing2
subim_im=avg(subim_im,1)
subim_im=alog10(subim_im)
subim_ideal=alog10(subim_ideal)
DS_error_boot=total((subim_im(e:f)-subim_ideal(e:f))^2)
if (iboot eq 0) then stack=DS_error_boot
if (iboot gt 0) then stack=[stack,DS_error_boot]
endfor
endif
return,value
end



; code to scale a given ideal image to the observed
ON_ERROR,0
common stuff,ideal_in,im,a,b,c,d,e,f,DS_error
common bootstrap,if_boot,stack
if_boot=1	; turn on bootstrapping
a=30
b=70
c=340
d=390
e=130
f=210
offset=.3
factor=1357.8
pars=[offset,factor]
im=readfits('USINGnoFLAST/AVG_tau_TAURI0092.fits',/silent,header)
get_time_of_average,header,avtime
openw,55,'fitting_sol.dat'
files=file_search('../OUTPUT/IDEAL/ideal_LunarImg_SCA_*2455769.104*',count=n)
for ifil=0,n-1,1 do begin
alfa=get_alfa_from_filename(files(ifil))
print,files(ifil)
ideal_in=reverse(readfits(files(ifil),/silent))
shifts=alignoffset(ideal_in,im,corr)
im=shift(im,shifts(0),shifts(1))
xi=[[0,1],[1,0]]
ftol=1.e-9
POWELL,pars,xi,ftol,fmin,'petersfunc2',/double
fmt_str='(3(1x,f10.3),2(1x,f8.5))'
printf,55,format=fmt_str,alfa,pars,DS_error,stddev(stack)
print,format=fmt_str,alfa,pars,DS_error,stddev(stack)
endfor
close,55
end
