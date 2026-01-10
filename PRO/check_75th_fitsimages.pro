files=file_search('VALIDATION_EXPT/NOISEADDED/LunarImg_00*.fit',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i),/SILENT)
totflux=total(im)
flx75=total(im(where(im gt max(im)/75)))
print,totflux,flx75,(totflux-flx75)/totflux*100.0,' %'
endfor
end
