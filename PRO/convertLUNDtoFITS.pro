PRO find_names_all_darkframes,darknames
common paths,path
darknames=file_search(path+'Dark*',count=n)
return
end

PRO find_names_all_sciframes,scinames
common paths,path
scinames=file_search(path+'Sci*',count=n)
return
end

PRO write_all_frames_as_fits,names
n=n_elements(names)
for i=0,n-1,1 do begin
print,' Trying to rewrite file ',names(i),' as FITS.'
data=get_data(names(i))
col=reform(data(0,*))
row=reform(data(1,*))
int=reform(data(2,*))
frame=lonarr(max(col),max(row))
frame(col,row)=int
writefits,strcompress(names(i)+'.fits'),frame
print,'Wrote ',strcompress(names(i)+'.fits')
endfor
return
end

;============================
common paths,path
path='\\Dadslaptop\my documents\LundCAMtest\091119-v14\'
find_names_all_darkframes,darknames
find_names_all_sciframes,scinames
write_all_frames_as_fits,darknames
write_all_frames_as_fits,scinames
end