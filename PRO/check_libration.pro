 PRO gogetjulianday,header,jd
 idx=strpos(header,'JULIAN')
 str=header(where(idx ne -1))
 jd=double(strmid(str,15,15))
 return
 end

; cod eto check how much time can pass and the error not be too large if stacking images
openw,33,'dsbs_changes.dat'
files=file_search('OUTPUT/IDEAL/ideal_LunarImg_00*.fit',count=n)
print,'Found ',n,' files.'
for ifil=0,n-1,1 do begin
im=readfits(files(ifil),h)
gogetjulianday,h,jd
dsbs=im(128,277)/im(367,245)
im=im+100.
spawn,'./justconvolve '+files(ifil)+' out.fit 1.7'
out=readfits('out.fit')
if (ifil eq 0) then stack=out
if (ifil gt 0) then stack=[[[stack]],[[out]]]
printf,format='(f16.7,1x,f19.4,1x,f25.7)',33,jd,dsbs,total(im,/double)
print,format='(f16.7,1x,f19.4,1x,f25.7)',jd,dsbs,total(im,/double)
endfor
close,33
;
for ifil=1,n-1,1 do begin
if (ifil eq 1) then diffstack=(reform(stack(*,*,ifil))-reform(stack(*,*,0)))/reform(stack(*,*,0))*100.
if (ifil gt 1) then diffstack=[[[diffstack]],[[(reform(stack(*,*,ifil))-reform(stack(*,*,0)))/reform(stack(*,*,0))*100.]]]
print,max((reform(stack(*,*,ifil))-reform(stack(*,*,0)))/reform(stack(*,*,0))*100.),' %'
endfor
writefits,'diffstack.fits',diffstack
end


