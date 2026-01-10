PRO redistribute2,im,errlim
common sizes,l
print,'Total image before:',total((im))
N=l(0)*l(1)
im_in=im
idx=where(float(im) lt 0)
err=1000
if (idx(0) ne -1) then err=abs(total(im(idx)))
count=0
energy=total(im_in)
;	help,idx(0),abs(err/energy)
while (idx(0) ne -1 and abs(err/energy) gt errlim) do begin
  	im(idx)=0.0 ; set all negative pixels to zero
  	negs2=total(im_in-im) ; calculate the total of the negs
  	err=negs2/N   ; E/N
	im=im+err	; eqn 3
	idx=where(float(im) lt 0)
;   		print,count, abs(err/energy)
	count=count+1
endwhile
; in the end just set all negative pixels to zero
idx=where(float(im) lt 0)
if (idx(0) ne -1) then im(idx)=0.0 ; set all negative pixels to zero
print,'Total image after:',total((im))
return
end
