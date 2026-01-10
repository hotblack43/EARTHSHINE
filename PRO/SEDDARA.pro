;==========================================================
; SeDDaRA for test images
; read in various images
for pwr=-5.,0.5,0.5 do begin
k=10^pwr
print,'k=',k
observed=readfits('observed.fit')
inspace=readfits('inspace.fit')
; pad images
observed=go_pad_image(observed)
inspace=go_pad_image(inspace)
;......... either
;ideal=maskoutsky(observed)
;......... or
ideal=inspace
;.....................
;
l=size(observed,/dimensions)
;
normit,observed
normit,ideal
normit,inspace
; correct
blind,(ideal),(observed),corrected,k
; unpad
observed=go_unpad(observed)
ideal=go_unpad(ideal)
inspace=go_unpad(inspace)
; fiddle
corrected=median(corrected,7)
corrected=go_unpad(corrected)
print,'Number of negatives in corrected image:',n_elements(where(corrected lt 0))
l=size(observed,/dimensions)
; display
!P.CHARSIZE=1.0
plot_io,ideal(*,l(0)/2.),yrange=[1,max(ideal)],xtitle='Column at middle row',ytitle='Flux',title=strcompress('Black - ideal, blue - observed, red - cleaned. K='+string(k)),psym=-7,xstyle=1
oplot,observed(*,l(0)/2.),color=fsc_color('blue')
oplot,corrected(*,l(0)/2.),color=fsc_color('red')
oplot,inspace(*,l(0)/2.),color=fsc_color('green')
;contour,[ideal,observed,corrected],levels=[-100,findgen(7)*1000.]
writefits,strcompress(string(K)+'_corrected.fit',/remove_all),corrected
endfor	; end pwr loop
end
