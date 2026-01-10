PRO pad_image,in,out,nx,ny
; will take an array 'in' and pad it on all sides
; with equal sized arrays so that it becomes
; the middle of 9 such arrays.
z=in*0.0d0+min(in)
top=[z,z,z]
bottom=top
middle=[z,in,z]
out=[[top],[middle],[bottom]]
l=size(out,/dimensions)
nx=l(0)
ny=l(1)
return
end

;
FUNCTION fitVoigtprofile,rr,pars
common imdims,obs,mdl,lobs
common keeps,folded
common masks,mask
; Voigt profile
impact=pars(0)
factor=pars(1)
bias=pars(2)
pinheight=factor
; evaluate a rectangular array V
; e.g. the Vogt profile
V=voigt(impact,rr)
V=V/total(V)
; pad V and mdl to avoid edge effects
pad_image,v,v_padded,nx,ny
v_padded(where(v_padded eq max(v_padded)))=pinheight
pad_image,mdl,mdl_padded,nx,ny
;
shftmdl=shift(mdl_padded,nx/2.,ny/2.)
; fold padded model image with padded PSF
folded=double(fft(fft(V_padded,-1,/DOUBLE)*fft(shftmdl,-1,/DOUBLE),1,/DOUBLE))+bias
; clip out the middle 9th
out1=folded[lobs(0):2*lobs(0)-1,*]
folded=out1(*,lobs(1):2*lobs(1)-1)
;
contour,bytscl(mask*(obs/obs-folded/obs)),/cell_fill,nlevels=31,xstyle=1,ystyle=1,/isotropic
kdx=where(folded le 0)
if (kdx(0) ne -1) then folded(where(folded le 0))=1.e-9
return,alog10(folded/obs)*mask
;return,folded/obs*mask
end

; code to generate a best-fitting PSF by minimising on the bright-side aureole
; using a model lunar disc and an observed image of the moon
;
loadct,19
decomposed=0
common imdims,obs,mdl,lobs
common keeps,folded
common masks,mask
obs=readfits('obs.fit')