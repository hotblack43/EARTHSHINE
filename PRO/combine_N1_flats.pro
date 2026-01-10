loadct,13
device,decomposed=0
vararr=['IRCUT','VE1','VE2','_V.','_B.']
for istr=0,n_elements(vararr)-1,1 do begin
str=vararr(istr)
files=file_search('FLATFIELDS/'+'*'+str+'*',count=n)
print,'Found ',n,' files matching: ',str
if (n ne 0) then begin
print,'-------------------------------'
for i=0,n-1,1 do begin
print,'FRAME: ',i,' named:',files(i)
im=readfits(files(i),/sil)
if (where(finite(im) ne 1) ne -1) then stop
s=sfit(im,1,kx=co)
mean_s=mean(s)
print,'Linear surface coefficients:'
print,co
print,'Min,max and median:'
print,'min,max,median:',min(im),max(im),median(im)
im=im-s+mean_s
s=sfit(im,1,kx=co)
print,'Removing linear surface.'
print,'Linear surface coefficients:'
print,co
print,'Min,max and median:'
print,min(im),max(im),median(im)
if (i eq 0) then sum=im
if (i gt 0) then sum=sum+im
print,'-------------------------------'
endfor
; average
sum=sum/float(n)
print,'Before removing spikes:'
print,'Min: ',min(sum)
print,'Max: ',max(sum)
; get rid of spikes
idx=where(abs(sum-mean(sum)) gt 5.*stddev(sum) )
if (idx(0) ne -1) then sum(idx)=median(sum)
print,'After removing spikes:'
print,'Min: ',min(sum)
print,'Max: ',max(sum)
print,'Median: ',median(sum)
print,'SD: ',stddev(sum)
print,'SD of noisy part: ',stddev(sum-rebin(rebin(sum,64,64),512,512))
; contour
loadct,13
decomposed=0
levs=(findgen(21)/10.-1.0)/30.+1.0
contour,histomatch(sum,findgen(256)*0+1),/cell_fill,nlevels=11,/isotropic,xstyle=3,ystyle=3,title='Combined, flattened '+str+' flat field.'
contour,c_thick=1,/overplot,c_charsize=1.2,c_labels=findgen(21)*0+1,rebin(rebin(sum,64,64),512,512),levels=levs,/downhill
;write_jpeg,'im.jpeg',tvrd()
name=strcompress('CFN1_'+str+'.fits',/remove_all)
writefits,name,sum
print,'Result saved as : ',name
endif
endfor
end
