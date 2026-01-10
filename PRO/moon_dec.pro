largestdec=-1e22
smallestdec=1e22
for jd=julday(1,1,2011),julday(1,1,2020),1.0d0 do begin
moonpos,jd,ra,dec
if (dec lt smallestdec) then smallestdec=dec
if (dec gt largestdec) then largestdec=dec
print,jd,dec,smallestdec,largestdec
a=get_kbrd()
endfor
end
