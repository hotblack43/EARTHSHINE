FUNCTION hmm,im
l=size(im,/dimensions)
avim=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
print,'In hmm',i
for j=0,l(1)-1,1 do begin
line=reform(im(i,j,*))
line=line(sort(line))
line=line(0.25*l(2):0.75*l(2))
avim(i,j)=mean(line,/double,/nan)
endfor
endfor
return,avim
end

PRO cleanstack,im
l=size(im,/dimensions)
ic=0
for i=0,l(2)-1,1 do begin
if (max(im(*,*,i)) gt 5000) then begin
if (ic eq 0) then stack=reform(im(*,*,i))
if (ic gt 0) then stack=[[[stack]],[[reform(im(*,*,i))]]]
ic=ic+1
endif else begin
print,'Frame ',i,' not good enough!.'
endelse
endfor
help,stack
im=stack
return
end

PRO get_exptime,header,exptime
 idx=where(strpos(header, 'EXPOSURE') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 exptime=float(strmid(str,9,strlen(str)-1))
 exptime=reform(exptime(0))
 return
 end
 
 PRO getit,file,DARKnamelist,DARKtimelist,n
 path='/media/thejll/OLDHD/MOONDROPBOX/JD2455947/'
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
 
 PRO findclosestDARKS,SIRIUSnamelist,SIRIUStimelist,DARKnamelist,DARKtimelist,LISTofbestDARKnames
 ; looking in SIRIUStimelist will find closest two DARKS and place their names on a list
 nTARGET=n_elements(SIRIUStimelist)
 ic=0
 for i=1,nTARGET-1,1 do begin
     d=(DARKtimelist-SIRIUStimelist(i))
     lastone=where(d lt 0)
     lastone=lastone(n_elements(lastone)-1)
     firstone=where(d gt 0)
     firstone=firstone(0)
     d1=DARKtimelist(lastone)-SIRIUStimelist(i)
     d2=DARKtimelist(firstone)-SIRIUStimelist(i)
     print,'d1,d2: ',d1*24.*60.,d2*24.*60.,' minutes.'
     maxminutesold=6
     if (abs(d1) gt 1./24./60.*maxminutesold or abs(d1) gt 1./24./60.*maxminutesold) then stop
     ;print,format='(a,1x,f15.7,1x,a)',DARKnamelist(lastone),SIRIUStimelist(i),DARKnamelist(firstone)
     if (ic eq 0) then LISTofbestDARKnames=[DARKnamelist(lastone),SIRIUSnamelist(i),DARKnamelist(firstone)]
     if (ic gt 0) then LISTofbestDARKnames=[[LISTofbestDARKnames],[DARKnamelist(lastone),SIRIUSnamelist(i),DARKnamelist(firstone)]]
     ic=ic+1
     endfor
 return
 end
 
 ; Code to carefully subtract scaled DARK frames from SIRIUS frames
 spawn,'grep DARK '+'SIRIUS.list'+' > DARKS.txt'
 spawn,'grep SIRIUS '+'SIRIUS.list'+' > TARGET.txt'
 getit,'DARKS.txt',DARKnamelist,DARKtimelist,nDARKS
 getit,'TARGET.txt',SIRIUSnamelist,SIRIUStimelist,nTARGET
 ;
 findclosestDARKS,SIRIUSnamelist,SIRIUStimelist,DARKnamelist,DARKtimelist,LISTofbestDARKnames
 l=size(LISTofbestDARKnames,/dimensions)
 n=l(1)
 path='/media/thejll/OLDHD/MOONDROPBOX/JD2455947/'
 print,'-----------------------------------------------------'
 for i=0,n-1,1 do begin
     print,'Reading: ',path+LISTofbestDARKnames(1,i)
     dark1=double(readfits(path+LISTofbestDARKnames(0,i),/silent))
     im=double(readfits(path+LISTofbestDARKnames(1,i),h,/silent))
     cleanstack,im
     idx=where(im gt 50000)
     if (idx(0) ne -1) then im(idx)=!values.f_nan
     get_exptime,h,exptime
     print,'Exposure time: ',exptime(0)
     l=size(im)
     if (l(0) eq 3) then im=hmm(im)
     dark2=double(readfits(path+LISTofbestDARKnames(2,i),/silent))
     im=im-(dark1+dark2)/2.0d0
     im=im/exptime(0)
     nameout=strcompress('DS_'+LISTofbestDARKnames(1,i),/remove_all)
     nameout=strmid(nameout,0,strlen(nameout)-3)
     print,nameout
     writefits,nameout,im
     tvscl,hist_equal(im)
     print,'-----------------------------------------------------'
     endfor
 end
