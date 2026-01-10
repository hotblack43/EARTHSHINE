PRO fix_identical,ilat,ilon
n=n_elements(ilat)
for i=0,n-2,1 do begin
for j=i+1,n-1,1 do begin
if (ilat(i) eq ilat(j) and (ilon(i) eq ilon(j))) then begin
ilat(i)=fix(ilat(i)/2)
print,'Fixed problem'
endif
endfor
endfor
return
end
