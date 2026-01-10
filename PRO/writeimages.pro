for i=1,156,1 do begin
path1='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON'
path2='\May25\May25\'
name=strcompress('IMG'+string(i)+'.FIT',/remove_all)
filename=strcompress(path1+path2+name)
image=readfits(filename)
l=size(image,/dimensions)
tvscl,image
xyouts,/normal,0.1,0.1,strcompress(path2+name),charsize=0.9
endfor
end
