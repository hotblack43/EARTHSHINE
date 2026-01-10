FUNCTION calculate_SSE_ND,X,Y,A
 common stuff,model_im,observed_in,subim,counter
 common ifgraphics,ifgraphicsflag
 observed=observed_in
 l=size(observed,/dimensions)
 ; apply pre-factor to observed image under the filtered part:
 pre_factor=25.0
 observed(*,0:590)=observed(*,0:590)*pre_factor
 y0=a(0)
 x0=a(1)
 rotangle=a(2)
 scale=a(3)
 factor=a(4)
 ND_OD=a(5)
 print,format='(a,8(1x,f10.4))','a:',a
 ; scale the part of the image behind the filter up
 upfactor=observed*0+1.0d0
 upfactor(*,0:600)=ND_OD
; rotate and stretch model image
 rotim= ROT(model_im, rotangle, scale,/INTERP)
; interpolate to right size
 subim= congrid(rotim,l(0),l(1))
; rotate it
 subim=shift_sub(subim, -x0, -y0)
; the make up a suitable mask
 mask=subim
 idx=where(mask gt 0)
 mask(idx)=1.0
 ; set mask to zero at the band covering the filter edge:
 mask(*,550:650)=0	; this is image specific so far
 scaled_subim=subim/float(factor)*upfactor
 resim=(scaled_subim-observed)*mask
 ; make residuals relative, avoid division with small numbers
 maxval=0.03
 comparative=maxval*max(abs(observed))
 kdx=where(abs(observed) gt comparative)
 resim(kdx)=resim(kdx)/observed(kdx)
 kdx=where(abs(observed) le comparative)
 resim(kdx)=0.0
 calculate_SSE=double(total(resim^2,/double)/(double(l(0)*l(1))))
 if (counter/25. eq fix(counter/25.) and ifgraphicsflag eq 1) then begin
     ;contour,congrid(resim,200,200),/cell_fill,xstyle=1,ystyle=1,/isotropic
     surface,congrid(resim,200,200)
     endif
 counter=counter+1
 return,calculate_SSE
 end
