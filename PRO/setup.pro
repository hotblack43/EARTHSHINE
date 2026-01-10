PRO find_model_radius,im,radius
row=total(im,1)
help,row
for i=0,510,1 do begin
if (row(i) eq 0 and row(i+1) gt 0.0) then guess1=256-i
endfor
for i=511,1,-1 do begin
if (row(i) eq 0 and row(i-1) gt 0.0) then guess2=i-256
endfor
print,guess1,guess2
radius=mean([guess1,guess2])
return
end

PRO get_actual_filename,name,actualname
bits=strsplit(name,'/',/extract)
actualname=bits(3)
return
end

files=file_search('/media/SAMSUNG/TESTMODS/','ideal*',count=n)
for i=0,n-1,1 do begin
name=files(i)
get_actual_filename,name,actualname
im=readfits(name,header)
sxaddpar, header, 'DISCX0', 256, 'Disc center x coordinate'
sxaddpar, header, 'DISCY0', 256, 'Disc center y coordinate'
find_model_radius,im,radius
sxaddpar, header, 'RADIUS', radius, 'Disc radius'
im=im/max(im)*53000.0d0
writefits,'aha.fits',im,h
str="./syntheticmoon aha.fits "+"synth_"+actualname+" 1.71 100 "+string(fix(randomu(seed)*10000))
spawn,str
im2=readfits("synth_"+actualname,hh)
sxaddpar, hh, 'DISCX0', 256, 'Disc center x coordinate'
sxaddpar, hh, 'DISCY0', 256, 'Disc center y coordinate'
sxaddpar, hh, 'RADIUS', radius, 'Disc radius'
writefits,strcompress("synth_"+actualname,/remove_all),im2+400.0,hh
print,'Writing: '+strcompress("synth_"+actualname,/remove_all)
endfor
end


