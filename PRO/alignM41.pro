files=file_search('FLATTEN/DARKCURRENTREDUCED/*.fits',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i))
stack=[[[stack]],[[im]]]
endfor
;
a=50
b=511-50
c=40
d=511-50
for itry=1,10,1 do begin
for i=0,n-1,1 do begin
if (itry eq 1) then ref=reform(stack(*,*,0))
im=reform(stack(*,*,i))
subref=ref(a:b,c:d)
subim=im(a:b,c:d)
shifts=alignoffset(subim,subref)
print,shifts
stack(*,*,i)=shift_sub(im,-shifts(0),-shifts(1))
endfor
ref=avg(stack,2)
tvscl,adapt_hist_equal(ref)
endfor
;
for k=0,10,1 do begin
tvscl,adapt_hist_equal(stack(*,*,k))
a=get_kbrd()
endfor
end
