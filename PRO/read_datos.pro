file='hej.txt'
openr,1,file
head='' & str=''
readf,1,head
while not eof(1) do begin
	readf,1,str
	while strpos(str,' ') ne -1 do begin
	bit=strmid(str,0,strpos(str,' '))
	str=strmid(str,strpos(str,' '),strlen(str)-strpos(str,' '))
	help,bit,str

	endwhile
	print,str
endwhile
close,1
end