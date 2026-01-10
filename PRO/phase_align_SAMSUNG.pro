 FUNCTION modifyheader,header,maxiter,niters,nims
 sxaddpar, header, 'NITERS',niters,'Maximum alignment iterations allowed'
 sxaddpar, header, 'MAXITERS',MAXITER,'Number of alignment iterations done'
 sxaddpar, header, 'NIMS',nims,'Number of images used in stack'
 return,header
 end 

 FUNCTION buildname,path,filnam
 plen=strlen(path)
 value=strmid(filnam,plen+10,strlen(filnam))
 value=strcompress('PAI_'+value)	; PAI = phase aligned integer shifts
 value=path+'NEWALIGNED/'+value
; snip off the '.gz'
 value=strmid(value,0,strlen(value)-3)
 return,value
 end

 PRO pickbestfromstack,ims
 l=size(ims)
 if (l(0) eq 2) then return
 n=l(3)
pile=[]
ic=0
for i=0,n-1,1 do begin
im=reform(ims(*,*,i))
if (max(im) gt 11000 and max(im) lt 56000) then begin
	pile=[[[pile]],[[im]]]
	ic=ic+1
endif
endfor
if (ic lt 5) then return
ims=pile
l=size(ims,/dimensions)
; now look at focus or SD/mean
stat=[]
for i=0,l(2)-1,1 do begin
image=reform(ims(*,*,i))
stat=[stat,stddev(image)/mean(image)]
endfor
idx=where((stat-median(stat))/robust_sigma(stat) lt 10)
ims=ims(*,*,idx)
print,'Selected ',n_elements(idx),' well focused images.'
 return
 end

 PRO FFTalignINTEGERonly,iflogswitch,orig_ims,avstack,maxiter
 common stuff,niters
 l=size(orig_ims,/dimensions)
 if (iflogswitch eq 1) then ims=alog10(orig_ims) else ims=orig_ims
 print,'Doing FFTs ...'
 for k=0,l(2)-1,1 do begin
;    print,k,' of ',l(2)
     if (k eq 0) then fftstck=fft(reform(ims(*,*,k)),/double)
     if (k gt 0) then fftstck=[[[fftstck]],[[fft(reform(ims(*,*,k)),/double)]]]
     endfor
;im1=reform(ims(*,*,0))
 im1=avg(ims,2,/nan)
 oldshift=intarr(2,l(2))+1e22
 newshift=intarr(2,l(2))
 for iter=0,niters,1 do begin
     print,'Iteration: ',iter
     if (iter eq 0) then begin
;        z1=fftstck(*,*,0)
         z1=fft(im1,-1,/double)
         astck=im1
         endif else begin
         z1=fft(avstack,-1,/double)
         astck=avstack
         endelse
     for iim=1,l(2)-1,1 do begin
         z2=fftstck(*,*,iim)
         R=z1*conj(z2)/(abs(z1)*abs(z2))
         inverse_r=fft(r,1,/double)
         jdx=where(finite(inverse_r) eq 1)
         idx=where(inverse_r(jdx) eq max(inverse_r(jdx)))
         if (idx(0) ne -1) then coords=array_indices(inverse_r,idx)
         if (idx(0) eq -1) then coords=[0,0]
;        print,'Shift was: ',coords
         newshift(0,iim)=coords(0)
         newshift(1,iim)=coords(1)
         im2=reform(orig_ims(*,*,iim))
         astck=[[[astck]],[[shift(im2,-coords(0),-coords(1))]]]
         endfor
	 totshifts=total(abs(oldshift-newshift))
         print,'Sum of all changes in shifts: ',totshifts
         oldshift=newshift
         avstack=avg(astck,2)
         maxiter=iter
         if (totshifts eq 0) then return
     endfor
     print,'Did not manage to converge inside ',niters,' iterations.'
     return
 end
 
common stuff,niters
niters=10	; max number of iterations to try
path='/data/pth/DATA/ANDOR/MOONDROPBOX/'
;files=file_search(path,'*MOON_*.fit*',count=nfiles)
openr,1,'allfiles'
while not eof(1) do begin
filename=''
readf,1,filename
print,filename
ims=1.0d0*readfits(filename,header,/sil)
if (max(ims) gt 11000 and max(ims) lt 56000) then begin
pickbestfromstack,ims
l=size(ims)
print,l
if (l(0) eq 3) then begin
iflogswitch=0
FFTalignINTEGERonly,iflogswitch,ims,avstack,maxiter
newname=buildname(path,filename)
newheader=modifyheader(header,maxiter,niters,l(3))
if (maxiter lt niters) then writefits,newname,avstack,newheader
endif
endif
endwhile
close,1
end
