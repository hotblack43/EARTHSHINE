PRO godostuff,im,mn,medi,stdd,numpix
l=size(im,/DIMENSIONS)
window,xsize=l(0),ysize=l(1)
tvscl,im
print,'One corner - click'
cursor,a,b
a=a*l(0)
b=b*l(1)
wait,.5
print,'Other  corner - click'
cursor,a2,b2
a2=a2*l(0)
b2=b2*l(1)
subim=im(a:a2,b:b2)
l=size(subim,/DIMENSIONS)
subim=rebin(subim,l(0)*5,l(1)*5)
l=size(subim,/DIMENSIONS)
window,xsize=l(0),ysize=l(1)
tvscl,subim
x=defroi(l(0),l(1),/RESTORE)
res=moment(subim(x))
print,'Stats in first definition of region:',res(0),'+/-',sqrt(res(1)),' S/N:',res(0)/ sqrt(res(1))
Result = REGION_GROW(subim, x , STDDEV_MULTIPLIER=2,/ALL_NEIGHBORS)

res=moment(subim(Result))
showim=subim
showim(Result)=max(subim)
tvscl,showim
print,'Stats in grown definition of region:',res(0),'+/-',sqrt(res(1)),' S/N:',res(0)/ sqrt(res(1))
mn=res(0)
medi=median(subim(Result))
stdd=sqrt(res(1))
numpix=n_elements(Result)
return
end

PRO feature,im_in,feature_name,pixel_stats
;
im=im_in
l=size(im,/dimensions)
if (feature_name eq 'Grimaldi') then begin

; display image and scale for vissibility if needed

window,/FREE,xsize=l(0),ysize=l(1)
tvscl,im
read,answer,prompt='Is feature '+feature_name+' in the bright side? (1/0)'
if (answer eq 0) then begin
    im=alog10(im_in) ; or rescale the faint side...
    tvscl,im
endif
godostuff,im,mn,medi,stdd,numpix
pixel_stats=[mn,medi,stdd,numpix]
;-------------------------------
endif
if (feature_name eq 'Crisium') then begin
; display image and scale for vissibility if needed

window,/FREE,xsize=l(0),ysize=l(1)
tvscl,im
read,answer,prompt='Is feature '+feature_name+' in the bright side? (1/0)'
if (answer eq 0) then begin
    im(0:l(0)*2./3.,*)= im(0:l(0)*2./3.,*)/10000.
    tvscl,im
endif
godostuff,im,mn,medi,stdd,numpix
pixel_stats=[mn,medi,stdd,numpix]

endif
return
end


FUNCTION removescattered,im_in
;
return,im_in
end

file='C:\Documents and Settings\Peter Thejll\Desktop\ASTRO\MOON\Moon_simulated_53.FIT'
im=readfits(file)

;==============================
; remove scattered light in sky
im=removescattered(im)

;==============================
; measure one feature
feature,im,'Grimaldi',pixel_stats1
;==============================
; measure other feature
feature,im,'Crisium',pixel_stats2
stop
;==============================
; formulate results
cal_results,pixel_stats1,pixel_stats2,result_stats

;==============================
; print results
print_results,result_stats


end