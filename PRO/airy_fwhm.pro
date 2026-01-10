files=file_search('*_airy_*.dat',count=n)
openw,44,'Airy_fwhm_objectdiameter.dat'
for i=0,n-1,1 do begin
data=get_data(files(i))
idx=where(data(1,*) gt max(data(1,*))*0.5)
fwhm=2.0*data(0,idx(-1))
printf,44,fwhm,' ',files(i)
endfor
close,44
print,'Done. Check out the file "Airy_fwhm_objectdiameter.dat"'
end
