files=file_search('bias_gain_*.fits',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i),/sil)
q=stddev(im(*,*,2),/nan)/mean(im(*,*,2),/Nan)
print,q
if (q lt 0.01) then begin
print,q,' ',files(i)
writefits,strcompress('norm_'+files(i),/remove_all),im(*,*,2)/mean(im(*,*,2),/Nan)
endif
endfor
end
