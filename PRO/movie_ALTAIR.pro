files=file_search('/media/OLDHD/ALTAIR/*.new',count=n)
for i=0,n-1,1 do begin
im=readfits(files(i),h)-397
tvscl,hist_equal(im)
endfor
end
