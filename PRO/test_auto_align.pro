FUNCTION peters,pars
common ims,reference,im,diff
lim=10000.0
maskref=reference*0+1
idx=where(reference lt lim)
maskref(idx)=0.0
maskim=im*0+1
idx=where(im lt lim)
maskim(idx)=0.0
diff=maskref*(reference-pars(2)*shift_sub(im,pars(0),pars(1)))
;diff=reference*maskref-pars(2)*shift_sub(maskim*im,pars(0),pars(1))
goal=total((diff/reference)^2)
print,format='(3(1x,f9.4),1x,g10.4)',pars,goal
return,goal
end

common ims,reference,im,diff
loadct,13
decomposed=0
files=file_search('DATA/im*',count=n)
reference=readfits(files(n/2))
openw,44,'aligned.dat'
for i=0,n-1,1 do begin
im=readfits(files(i))
a=[0.0,0.0,1.0]
xi=[[1,0,0],[0,1,0],[0,0,1]]
ftol=1.e-8
POWELL,a,xi,ftol,fmin,'peters',iter=iter,/double
print,'Done: a=',a,files(i),fmin
printf,44,format='(4(1x,f9.4),1x,a)',a,fmin,files(i)
surface,rebin(diff,64,64)
endfor
close,44
end
