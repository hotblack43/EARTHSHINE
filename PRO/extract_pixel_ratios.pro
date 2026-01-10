PRO get_photometric_ratio,im,ratio
ratio=im(41,234)/im(447,330)
return
end
;
openw,5,'BSoverDS_ratio.dat'
files=file_search('C:\Documents and Settings\Daddyo\Skrivebord\ASTRO\OUTPUT\IDEAL\*.fit',count=nfiles)
for ifile=0,nfiles-1,1 do begin
		im=(readfits(files(ifile)))
		get_photometric_ratio,im,ratio
		print,ratio,ifile
		printf,5,ratio
endfor
close,5
end