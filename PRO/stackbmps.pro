files=file_search('*.BMP',count=n)
IM=READ_BMP(FILES(0),R,G,B)
SUM=IM(0)
for i=0,4-1,1 do begin
IM=READ_BMP(FILES(0))
SUM=SUM+IM(0)
print,i
endfor
end
