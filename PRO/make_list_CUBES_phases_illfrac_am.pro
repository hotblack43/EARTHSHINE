PRO get_JD_filter_from_filename,name,JD,filtername
liste=strsplit(name,'_',/extract)
idx=strpos(liste,'24')
ipoint=where(idx ne -1)
JD=double(liste(ipoint))
filtername=liste(ipoint+1)
return
end

; get chris list of good images
file='chris_list_good_images.txt'
openr,1,file
ic=0
while not eof(1) do begin
str=''
readf,1,str
if (ic eq 0) then goodlist=str
if (ic gt 0) then goodlist=[goodlist,str]
ic=ic+1
endwhile
close,1
;
file='list_CUBES.txt'
openr,1,file
openw,2,'CUBES_jd_illfrac.txt'
while not eof(1) do begin
str=''
readf,1,str
im=readfits(str,h,/silent)
get_JD_filter_from_filename,str,JD,filtername
mphase,jd,k
if (where(strpos(goodlist,string(jd,format='(f15.7)')) ne -1) ne -1) then begin
print,format='(f15.7,1x,f6.3,1x,a,1x,a)',jd,k,filtername,str
printf,2,format='(f15.7,1x,f6.3,1x,a,1x,a)',jd,k,filtername,str
endif else begin
print,'Skipping ',jd
endelse
endwhile
close,1
close,2
end
