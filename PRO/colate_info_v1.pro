openr,1,'uniqJDs'
openw,33,'changeinAlbedofit_negativeZLSL.dat'
while not eof(1) do begin
line=''
readf,1,line
bits=strsplit(line,' ',/extract)
JD=double(bits(1))
str="grep "+bits(1)+" CLEM.profiles_fitted_results_Aug_2014_TEST5_negativeANDzeroZLSL.txt | awk '{print $2,$13}' > whatwehaveforthisJD.txt"
spawn,str
data=get_data('whatwehaveforthisJD.txt')
idx=where(data(1,*) eq 0)
jdx=where(data(1,*) ne 0)
if (idx(0) ne -1 and jdx(0) ne -1) then begin
albedO_negZLSL=mean(data(0,jdx))
albedO_zerZLSL=mean(data(0,idx))
print,(albedO_negZLSL-albedO_zerZLSL)/albedO_zerZLSL*100.0
printf,33,(albedO_negZLSL-albedO_zerZLSL)/albedO_zerZLSL*100.0
endif
endwhile
close,1
close,33
;
data=get_data('changeinAlbedofit_negativeZLSL.dat')
histo,data,-1.0,1.5,0.03,xtitle='!7D!3 Albedo [%]',ytitle='N',/abs
oplot,[median(data),median(data)],[!Y.crange],linestyle=2
oplot,[0,0],[!Y.crange],linestyle=1
kdx=where(data lt 0)
print,'% below 0: ',n_elements(kdx)/n_elements(data)*100.
end
