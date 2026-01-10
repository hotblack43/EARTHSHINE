PRO getnametext,nametext,file,blockswantedfromend
len=strlen(file)
pos=intarr(1000)+9999
j=0
for i=0,len-1,1 do begin
;if (strmid(file,i,1) eq '\') then begin
if (strmid(file,i,1) eq '/') then begin
	pos(j)=i
	j=j+1
endif
endfor
idx=where(pos ne 9999)
pos=pos(idx)
npos=n_elements(pos)
; blockswantedfromend is a counter, counting from the end
; of the filename, numbering the backslashes. The first one
; from the end is number 0, the second one from the end is number 1
; and so on...
nametext=strmid(file,pos(npos-blockswantedfromend-1)+1,len-pos(blockswantedfromend))
fixbackslash,nametext,nametext
fixunderscore,nametext,nametext
return
end

PRO fixbackslash,instring,outstring
dummy=instring
while (strpos(dummy,'\') ne -1) do begin
	pos=strpos(dummy,'\')
	strput,dummy,'/',pos
	outstring=dummy
endwhile
return
end

PRO stripfilename,str,filename
pos=strpos(str,'\',/REVERSE_SEARCH)
if (pos(0) eq -1) then pos=strpos(str,'/',/REVERSE_SEARCH)
filename=strmid(str,pos+1,strlen(str))
return
end

PRO fixunderscore,str,newstr
oldstr=str
while (strpos(oldstr,'_') ne -1) do begin
	pos=strpos(oldstr,'_')
	strput,oldstr,'-',pos
	newstr=oldstr
endwhile
return
end

PRO fixunderscore_andcopy,destdir,str,newstr
oldstr=str
stripfilename,str,filename
	newstr=filename
while (strpos(filename,'_') ne -1) do begin
	pos=strpos(filename,'_')
	strput,filename,'-',pos
	newstr=filename
endwhile
newfilename=strcompress(destdir+newstr)
file_copy,oldstr,destdir+newstr,/overwrite
return
end

PRO writeincludegraphics,destdir,localdirname,texfilename,file
fixunderscore_andcopy,destdir,file,newfilename
blockswantedfromend=3
getnametext,nametext,file,blockswantedfromend
print,'File=',file
read_JPEG,file,img
l=size(img,/dimensions)
if (n_elements(l) eq 3) then begin
width=l(1)
height=l(2)
endif
if (n_elements(l) eq 2) then begin
width=l(0)
height=l(1)
endif
aspect=float(width)/float(height)
;---------------
 openw,11,texfilename,/append
 printf,11,'        '
 printf,11,'\begin{figure}[p]'
 printf,11,'\centering{'
 if (aspect gt 0.78) then printf,11,'\includegraphics[width=13.5cm]{'+localdirname+newfilename+'}'
 if (aspect le 0.78) then printf,11,'\includegraphics[height=18cm]{'+localdirname+newfilename+'}'
 printf,11,'\caption{\AA rstal. Teknik. BreddxH\"{o}jd. Noter.}'
 printf,11,''+nametext+'}'
 printf,11,'\end{figure}'
 printf,11,'\clearpage         '
 close,11
return
end

PRO writeender,texfilename
; read in the ender block of tex commands
openr,12,'enderblock.tex'
counter=0
nbig=1000
line=strarr(nbig)
while not eof(12) do begin
	dummy=''
	readf,12,format='(a)',dummy
	line(counter)=dummy
	counter=counter+1
endwhile
close,12
nlines=counter
; and now write them into the named file
openw,11,texfilename,/append
for iline=0,nlines-1,1 do begin
	printf,11,line(iline)
endfor
close,11
return
end

PRO writeheader,texfilename
; read in the header block of tex commands
openr,12,'introblock.tex'
counter=0
nbig=1000
line=strarr(nbig)
while not eof(12) do begin
dummy=''
readf,12,format='(a)',dummy
line(counter)=dummy
counter=counter+1
endwhile
close,12
nlines=counter
; and now write them into the named file
openw,11,texfilename
for iline=0,nlines-1,1 do begin
printf,11,line(iline)
endfor
close,11
return
end

filters = ['*.jpg']
basepath='/home/pth/Desktop/Dokumenter/TEXSTUFF/BOOKS/TRYSUNDA/'
files=file_search(basepath+'fig/',filters)
nfiles=n_elements(files)
localdirname='allfigs/'
destdir=basepath+localdirname
texfilename=basepath+'allpictures.tex'
writeheader,texfilename
for ifile=0,nfiles-1,1 do begin
writeincludegraphics,destdir,localdirname,texfilename,files(ifile)
endfor
writeender,texfilename
end

