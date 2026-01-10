PRO goalignstack,stack,ref,sum_ord,sum_2nd
im_org=stack
; stack
sum_ord=ref
sum_2nd=ref
firstbest=0
secondbest=0
for i=0,99,1 do begin
im=reform(im_org(*,*,i))
;.................................................................
shifts=alignoffset(im,ref,corr)
imtot=total(im,/double)
im=shift_sub(im,-shifts(0),-shifts(1))
im=im/total(im,/double)*imtot
sum_ord=sum_ord+im
;.................................................................
shifts2=alignoffset((im)^2,(ref)^2,corr)
im2=shift_sub(im,-shifts2(0),-shifts2(1))
im2=im2/total(im2,/double)*imtot
sum_2nd=sum_2nd+im2
;.................................................................
;print,total(abs(ref-im),/double),total(abs(ref-im2),/double),total(abs(ref-im),/double) gt total(abs(ref-im2),/double),(total(abs(ref-im),/double)-total(abs(ref-im2),/double))/total(abs(ref-im2),/double)*100.0,shifts,shifts2
tvscl,[im-ref,im2-ref]
;plot,im-ref,im2-ref,psym=3
If (total(abs(ref-im),/double) lt total(abs(ref-im2),/double) eq 1) then firstbest=firstbest+1
If (total(abs(ref-im),/double) gt total(abs(ref-im2),/double) eq 1) then secondbest=secondbest+1
endfor
print,'Ordinary best: ',firstbest
print,'Special best : ',secondbest
sum_ord=sum_ord/100.0
sum_2nd=sum_2nd/100.0
return
end

file='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2456015/2456015.8379284MOON_IRCUT_AIR.fits.gz'
im=readfits(file)
ref=avg(im,2,/double)
goalignstack,im,ref,sum_ord,sum_2nd
print,mean(ref),mean(sum_ord),mean(sum_2nd)
; change the reference and go again
goalignstack,im,sum_ord,sum_ord,sum_2nd
print,mean(ref),mean(sum_ord),mean(sum_2nd)
end
