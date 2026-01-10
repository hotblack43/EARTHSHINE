files=file_search('.','tabulated_output.*')
npix=11
stdd=fltarr(npix)
nrun=n_elements(files)
array=fltarr(8,11,nrun)
for irun=0,nrun-1,1 do begin
spawn," awk 'NR > 1 ''' "+files(irun)+'> temp'
data=get_data('temp')
for ipix=0,npix-1,1 do array(*,ipix,irun)=data(*,ipix)

endfor	; end of irun loop
for ipix=0,npix-1,1 do begin
stdd(ipix)=stddev(array(4,ipix,*))
print,'Pix no.',ipix,' STD=',stdd(ipix)
endfor
print,'mean std for all pictures:',mean(stdd)
print,'std for all pictures:',stddev(array(4,*,*))
print,'mean ratio for all pictures:',mean(array(4,*,*))
surface,array(4,*,*),charsize=1.3,xtitle='Picture No.',ytitle='Run No.',ztitle='Ratio'
end
