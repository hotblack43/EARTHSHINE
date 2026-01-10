PRO get_gainAV,stack,times,gainAV
; make an average of the fluxes
l=size(stack,/dimensions)
sum=0.0
if (n_elements(l) eq 2) then stop
for k=0,l(2)-1,1 do begin
sum=sum+reform(stack(*,*,k))/times(k)
endfor
gainAV=sum/mean(sum)
return
end

PRO stackdarks,bias
files=file_search('/media/SAMSUNG/LAMPFLATSND/*DARK*',count=n)
ic=0
for i=0,n-1,1 do begin
im=readfits(files(i))
print,mean(im)
if (mean(im) gt 370 and mean(im) lt 410) then begin
if (ic eq 0) then sum=im
if (ic gt 0) then sum=sum+im
ic=ic+1
endif
endfor
bias=sum/float(ic)
writefits,'newbias.fits',bias
return
end



PRO cleanupim,im,iflag,bias
iflag=314
lolim=9000
hilim=56000
l=size(im,/dimensions)
if (n_elements(l) eq 2) then begin
if (max(im) gt lolim and max(im) lt hilim) then iflag=1
endif
if (n_elements(l) eq 3) then begin
ic=0
for i=0,l(2)-1,1 do begin
subim=reform(im(*,*,i))
if (max(subim) gt lolim and max(subim) lt hilim) then begin
if (ic eq 0) then stack=subim;-bias
if (ic gt 0) then stack=[[[stack]],[[subim]]];-bias]]]
ic=ic+1
endif else begin
print,'It was no good max(subim): ',max(subim)
endelse
endfor
if (ic ne 0) then begin
iflag=1
im=stack
endif
endif
 return
 end

 PRO get_EXPOSURE,h,exptime
 ;EXPOSURE=                 0.02 / Total Exposure Time 
 ipos=where(strpos(h,'EXPOSURE') ne -1)
 date_str=strmid(h(ipos),11,21)
 exptime=float(date_str)
 return
 end

filter='_V_'
SKND='AIR'
SKND='ND2.0'
stackdarks,dummy
stackbias=readfits('newbias.fits')
night='2456033'
str=strcompress('/data/pth/DATA/ANDOR/MOONDROPBOX/JD'+night+'/*LAMP*'+filter+'*'+SKND+'*fit*',/remove_all)
;str=strcompress('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455916/*LAMP*'+filter+'*'+SKND+'*fit*',/remove_all)
;str=strcompress('/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456032/*LAMP*'+filter+'*'+SKND+'*fit*',/remove_all)
;str=strcompress('/media/SAMSUNG/LAMPFLATSND/*'+filter+'*'+SKND+'*fits',/remove_all)
print,'looking for ',str
files=file_search(str,count=n)
print,n
if (n eq 0) then stop
ic=0
for i=0,n-1,1 do begin
print,files(i)
im=readfits(files(i),h,/silent)
get_EXPOSURE,h,exptime
offset=-0.647294
exptime=exptime-offset
iflag=314
cleanupim,im,iflag,stackbias
l=size(im,/dimensions)
if (iflag ne 314) then begin
print,format='(f9.5,1x,f10.3)',exptime,mean(im)
if (ic eq 0) then times=exptime
if (ic gt 0) then times=[times,exptime]
if (ic eq 0 and n_elements(l) eq 3) then stack=avg(im,2)
if (ic gt 0 and n_elements(l) eq 3) then stack=[[[stack]],[[avg(im,2)]]]
if (ic eq 0 and n_elements(l) eq 2) then stack=im
if (ic gt 0 and n_elements(l) eq 2) then stack=[[[stack]],[[im]]]
ic=ic+1
endif
endfor
;
bias=fltarr(512,512)
gain=fltarr(512,512)
r=fltarr(512,512)
sigbias=fltarr(512,512)
siggain=fltarr(512,512)
for i=0,511,1 do begin
for j=0,511,1 do begin
res=linfit(times,reform(stack(i,j,*)),/double,sigma=sigs,yfit=yhat)
r(i,j)=correlate(reform(stack(i,j,*)),times)
bias(i,j)=res(0)
gain(i,j)=res(1)
sigbias(i,j)=sigs(0)
siggain(i,j)=sigs(1)
endfor
endfor
diffbias=(bias-stackbias)/stackbias*100.0
writefits,'diffbias_pct'+night+'.fits',diffbias
str=strcompress(filter+SKND,/remove_all)
get_gainAV,stack,times,gainAV
diffgain=(gain/mean(gain)-gainAV)/gainAV*100.0
writefits,'diffgain_pct'+night+'.fits',diffgain
writefits,'gain'+str+'_'+night+'ordinaryAverage.fits',gainAV
writefits,'gain'+str+'_'+night+'.fits',gain
writefits,'gain_normalized_to_one'+str+'_'+night+'.fits',gain/mean(gain)
writefits,'gain_sigma_pct'+str+'_'+night+'.fits',siggain/gain*100.0
writefits,'bias'+str+'_'+night+'.fits',bias
writefits,'bias_sigma_pct'+str+'_'+night+'.fits',sigbias/bias*100.0
writefits,'time_flux_correlation'+str+'_'+night+'.fits',r
print,'Done!'
;
print,'The user-inserted offset was at; ',offset
print,'Insert a new one after thinking about this information...'
offset=(bias-stackbias)/gain
print,'Shutter delay indicated by bias analysis: ',mean(offset),' +/- ',stddev(offset),' s.'
end
