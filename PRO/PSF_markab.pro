PRO getit,file,DARKnamelist,DARKtimelist,n
path='/media/thejll/OLDHD/MOONDROPBOX/JD2455833/'
openr,1,file
ic=0
while not eof(1) do begin
str=''
readf,1,str
if (ic eq 0) then begin
	DARKnamelist=str
	DARKtimelist=double(strmid(str,0,15))
endif else begin
	DARKnamelist=[DARKnamelist,str]
	DARKtimelist=[DARKtimelist,double(strmid(str,0,15))]
endelse
ic=ic+1
endwhile
close,1
n=n_elements(DARKtimelist)
return
end

PRO findthenearestDARKS,MARKABnamelist,MARKABtimelist,DARKnamelist,DARKtimelist,LISTofbestDARKnames
; looking in MARKABtimelist will find closest two DARKS and place their names on a list
nTARGET=n_elements(MARKABtimelist)
ic=0
for i=1,nTARGET-1,1 do begin
d=(DARKtimelist-MARKABtimelist(i))
 lastone=where(d lt 0)
lastone=lastone(n_elements(lastone)-1)
firstone=where(d gt 0)
firstone=firstone(0)
d1=DARKtimelist(lastone)-MARKABtimelist(i)
d2=DARKtimelist(firstone)-MARKABtimelist(i)
if (abs(d1) gt 1./24./60.*4 or abs(d1) gt 1./24./60.*4) then stop
;print,format='(a,1x,f15.7,1x,a)',DARKnamelist(lastone),MARKABtimelist(i),DARKnamelist(firstone)
if (ic eq 0) then LISTofbestDARKnames=[DARKnamelist(lastone),MARKABnamelist(i),DARKnamelist(firstone)]
if (ic gt 0) then LISTofbestDARKnames=[[LISTofbestDARKnames],[DARKnamelist(lastone),MARKABnamelist(i),DARKnamelist(firstone)]]
ic=ic+1
endfor
return
end

; Code to carefully subtract scaled DARK frames from MARKAB frames
spawn,'grep DARK '+'MARKAB.list'+' > DARKS.txt'
spawn,'grep MARKAB '+'MARKAB.list'+' > TARGET.txt'
getit,'DARKS.txt',DARKnamelist,DARKtimelist,nDARKS
getit,'TARGET.txt',MARKABnamelist,MARKABtimelist,nTARGET
;
findthenearestDARKS,MARKABnamelist,MARKABtimelist,DARKnamelist,DARKtimelist,LISTofbestDARKnames
l=size(LISTofbestDARKnames,/dimensions)
n=l(1)
path='/media/thejll/OLDHD/MOONDROPBOX/JD2455833/'
for i=0,n-1,1 do begin
dark1=readfits(path+LISTofbestDARKnames(0,i),/silent)
im=readfits(path+LISTofbestDARKnames(1,i),/silent)
dark2=readfits(path+LISTofbestDARKnames(2,i),/silent)
im=im-(dark1+dark2)/2.0d0
nameout=strcompress('DS_'+LISTofbestDARKnames(1,i),/remove_all)
nameout=strmid(nameout,0,strlen(nameout)-3)
print,nameout
writefits,nameout,im
tvscl,hist_equal(im)
print,mean(im(0:100,0:100))
endfor
end
