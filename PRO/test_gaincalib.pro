if_restore=0
its=50 ; number of iterations
if (if_restore eq 1) then begin
restore,'results.sav' 
endif else begin
files=file_search('/media/SAMSUNG/MOONDROPBOX/MOONDROPBOX/JD2455461/DoubleStar-WAnd/00000_2455461_*',count=nfiles)
ic=0
for ifil=0,nfiles-1,1 do begin
images=readfits(files(ifil))
l=size(images,/dimensions)
nf=1
if (n_elements(l) eq 3) then nf=l(2)
for iim=0,nf-1,1 do begin
subim=images(*,*,iim)
;subim=rebin(subim,128,128)
if (ic eq 0) then logimages=alog10(subim)
if (ic gt 0) then logimages=[[[logimages]],[[alog10(subim)]]]
help,logimages
ic=ic+1
endfor
endfor
l=size(logimages,/dimensions)
x=findgen(l(2))*0.0
y=findgen(l(2))*0.0
endelse
;
;
!P.MULTI=[0,1,1]
set_plot,'X
logflat = gaincalib(logimages, x, y, object=object,c=c,maxiter=its,shift_flag=1)
;logflat = gaincalib(logimages, x, y, object=object,c=c,maxiter=its,shift_flag=0,mask=mask)
!P.MULTI=[0,2,2]
set_plot,'ps'
device,/landscape,filename=strcompress('idl_'+string(its)+'.ps',/remove_all)
surface,logflat,title='logflat at N='+string(its)+' iterations.'
surface,object,title='log object at N='+string(its)+' iterations.'
plot,c,xtitle='Iterations',ytitle='C',title='at N='+string(its)+' iterations.'
plot,x,y,psym=7,xtitle='Shifts in X',ytitle='Shifts in Y'
device,/close
;-------------
save,logflat,object,logimages,x,y,c,filename='results.sav'
end
