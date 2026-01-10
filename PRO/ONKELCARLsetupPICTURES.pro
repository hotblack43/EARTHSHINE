PRO stripfilename,str,filename
pos=strpos(str,'\',/REVERSE_SEARCH)
filename=strmid(str,pos+1,strlen(str))
;
pos=strpos(filename,'JPG')
	if (pos ne -1) then strput,filename,'jpg',pos
	return
end

PRO fixunderscore,destdir,str,newstr
oldstr=str
stripfilename,str,filename
while (strpos(filename,'_') ne -1) do begin
	pos=strpos(filename,'_')
	if (pos ne -1) then strput,filename,'-',pos
endwhile
	newstr=filename
newfilename=strcompress(destdir+newstr)
file_copy,oldstr,destdir+newstr,/overwrite
return
end

PRO writeincludegraphics,destdir,localdirname,texfilename,file
fixunderscore,destdir,file,newfilename
pos=strpos(file,'Æ')
dummy=file
strput,dummy,'A',pos
pos=strpos(dummy,'Aske')
captionname=strmid(dummy,pos,strlen(dummy)-pos)
while (strpos(captionname,'_') ne -1) do begin
	pos=strpos(captionname,'_')
	if (pos ne -1) then strput,captionname,'-',pos
endwhile
while (strpos(captionname,'\') ne -1) do begin
	pos=strpos(captionname,'\')
	if (pos ne -1) then strput,captionname,'/',pos
endwhile
;stop
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
;widthnum=string(fix(14.*width/760.))
;heightnum=string(fix(18.*height/1260.))
aspect=float(width)/float(height)
print,width,height,aspect,file
openw,11,texfilename,/append
printf,11,'        '
;if (width le height) then begin
printf,11,'\begin{figure}[p]'
printf,11,'\centering{'
if (aspect gt 0.78) then printf,11,'\includegraphics[width=13.5cm]{'+localdirname+newfilename+'}'
if (aspect le 0.78) then printf,11,'\includegraphics[height=18cm]{'+localdirname+newfilename+'}'
printf,11,'\caption{\AA rstal. Teknik. BreddxH\"{o}jd. Noter.}'
printf,11,''+captionname+'}'
printf,11,'\end{figure}'
;endif
printf,11,'\clearpage         '
close,11
return
end

PRO writeender,texfilename
; read in the ender block of tex commands
openr,12,'C:\Documents and Settings\Peter Thejll\Dokumenter\TEXSTUFF\BOOKS\ONKELCARL\enderblock.tex'
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
openr,12,'C:\Documents and Settings\Peter Thejll\Dokumenter\TEXSTUFF\BOOKS\ONKELCARL\introblock.tex'
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

filters = ['*.jpg', '*.tif', '*.png']
files=file_search('C:\Documents and Settings\Peter Thejll\Dokumenter\Billeder\Onkel Carl\','Plade*.*' )
nfiles=n_elements(files)
destdir='C:\Documents and Settings\Peter Thejll\Dokumenter\TEXSTUFF\BOOKS\ONKELCARL\fig\'
localdirname='fig/'
texfilename='C:\Documents and Settings\Peter Thejll\Dokumenter\TEXSTUFF\BOOKS\ONKELCARL\ONKELCARL.tex'
writeheader,texfilename
for ifile=0,nfiles-1,1 do begin
writeincludegraphics,destdir,localdirname,texfilename,files(ifile)
endfor
writeender,texfilename
end

