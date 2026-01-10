 PRO get_time,header,dectime
 ;
 idx=where(strpos(header, 'FRAME') eq 0)
 str='999'
 if (idx(0) ne -1) then str=header(idx)
 yy=fix(strmid(str,11,4))
 mm=fix(strmid(str,16,2))
 dd=fix(strmid(str,19,2))
 hh=fix(strmid(str,22,2))
 mi=fix(strmid(str,25,2))
 se=float(strmid(str,28,6))
 dectime=julday(mm,dd,yy,hh,mi,se)
 return
 end

PRO fit_2d_gauss,im_in,b
        im=im_in
        weights=1.0d0/im
;;	weights=im*0.0+1.0d0
        kdx=where(im le 0)
        if (kdx(0) ne -1) then weights(kdx)=0.0
yfit = mpfit2dpeak(im, B,/MOFFAT,weights=weights,estimates=b)
print,format='(10(1x,f20.8),1x,i3)',b,1
print,'Offset :',b(0)
print,'Scale  :',b(1)
print,'sigmas :',b(2),b(3)
print,'X0,Y0  :',b(4),b(5)
print,'tilt   :',b(6)
if (n_elements(b) gt 7) then print,'power  :',b(7)
return
end


openw,44,'fits_JUPITER.dat'
allfnames=['_B_','_V_','_VE1_','_VE2_','_IRCUT_']
for i=0,4,1 do begin
fname=allfnames(i)
;spawn,'grep '+fname+' JUPITER.2455855 > fnames'
;spawn,'grep '+fname+' allMARS> fnames'
;spawn,'grep '+fname+' allJUPITER > fnames'
;spawn,'grep '+fname+' allPLEIADES > fnames'
;spawn,'grep '+fname+' allSPICA > fnames'
;spawn,'grep '+fname+' allNGC6633 > fnames'
spawn,'grep '+fname+' allALTAIR > fnames'
openr,1,'fnames'
while not eof(1) do begin
str=''
readf,1,str
im=readfits(str,h,/sil)
idx=strpos(h,'DMI_MNT_DEC')
jdx=strpos(h,'DMI_MNT_RA')
print,h(where(idx ne -1)),h(where(jdx ne -1))
get_time,h,JD
l=size(im)
if (l(0) eq 3) then im=avg(im,2)
if (max(im) gt 5000 and max(im) lt 60000) then begin
smoim=smooth(im,3)
idx=where(smoim eq max(smoim))
coords=array_indices(im,idx)
w=50
if (coords(0)-w ge 0 and coords(0)+w le 511 and coords(1)-w ge 0 and coords(1)+w le 511) then begin
subim=im(coords(0)-w:coords(0)+w,coords(1)-w:coords(1)+w)
;subim=subim^2
tvscl,hist_equal(subim)
b=[400.,40000.,3.,3.,w,w,1.0d0,1.0d0]
fit_2d_gauss,subim,b
relvar=stddev(subim,/double)/mean(subim,/double)
printf,44,format='(f15.7,10(1x,f12.5),1x,i3)',JD,b,i
endif
endif
endwhile
close,1
endfor
close,44
end
