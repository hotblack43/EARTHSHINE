PRO guess_start,file,x00,y00,radius
x000=-911
y000=-911
radius000=-911
fmt='(3(1x,f12.4),1x,a)'
openr,39,'moonfits.results'
while not eof(39) do begin
	str=''
	readf,39,str
	pos=strpos(str,file)
	if (pos(0) ne -1) then getstuff,str,dummystr,x000,y000,radius000
endwhile
close,39
x00=x000
y00=y000
radius=radius000
return
end
