PRO redistribute,im,errlim
common sizes,l
N=l(0)*l(1)
im_in=im
idx=where(im lt 0)
err=1000
if (idx(0) ne -1) then err=abs(total(im(idx)))
count=0
energy=total(im_in)/N	; mean pixel value
while (idx(0) ne -1 and abs(err) gt errlim and count lt 1000) do begin
;while (idx(0) ne -1 and abs(err/energy) gt errlim and count lt 1000) do begin
  	im(idx)=0.0 ; set all negative pixels to zero
  	negs2=total(im_in-im) ; calculate the total of the negs
  	err=negs2/N   ; E/N the average pixel error
	im=im+err	; eqn 3
	idx=where(im lt 0)
	count=count+1
endwhile
  	if (idx(0) ne -1) then im(idx)=0.0 ; set all negative pixels to zero
return
end
