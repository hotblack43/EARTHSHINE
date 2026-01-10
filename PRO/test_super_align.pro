
;===============================================================================
;
; FUNCTION super_align
;
; PURPOSE:
;      Determine the offsets of an image with respect to a reference image,
;
; CALLING SEQUENCE:
;      offset = super_align(image, reference, corr)
;
; INPUTS:
;      image            the object image
;      reference        the reference image
;
; OUTPUT:
;     offset         a two-element array of the offset values defined
;                    by  offset=(i,j)-(l,m)  where (i,j) is the object
;                    image coordinates of a feature and (l,m) its
;                    reference image coordinates.
;
;
; OPTIONAL OUTPUT:
;       corr         the maximum correlation coefficient
;
; REMARK:
;            Correlation method is used based on image sub-shifting
;
; HISTORY:
;	     October 2008, Peter Thejll
;===============================================================================


FUNCTION  super_align,image, reference, corr

;---------------------------------------------------------------------------------
; Test for whether images are the same size
;---------------------------------------------------------------------------------
l=size(image,/dimensions)
m=size(reference,/dimensions)
;help,l,m
if (l(0) ne m(0) or l(1) ne m(1)) then begin
	print,'STOP in super_align.pro, image and reference are not same size."
	stop
endif

;---------------------------------------------------------------------------------
; Choose a suitable set of patches around the image to align on
;---------------------------------------------------------------------------------
npatch=1+4	; one in the middle and n surrounding it
patch_width=41	; make boxes that are patch_width x patch_width
patch_dist=l(0)/3. ; put the three off-center patches at this radius from the image center
patch_positions=fltarr(2,npatch)
startpos=360./(npatch-1.)/2.*!dtor	; don't start at 12 o'clock
;....
; concatenate the patches into a block - one for the reference image and one for the real image
;....
patch_positions(0,0)=l(0)/2.
patch_positions(1,0)=l(1)/2.
ref_im=reference(patch_positions(0,0)-patch_width/2.:patch_positions(0,0)+patch_width/2., $
                 patch_positions(1,0)-patch_width/2.:patch_positions(1,0)+patch_width/2.)
real_im=image(patch_positions(0,0)-patch_width/2.:patch_positions(0,0)+patch_width/2., $
              patch_positions(1,0)-patch_width/2.:patch_positions(1,0)+patch_width/2.)
for i=1,npatch-1,1 do begin
	patch_positions(0,i)=l(0)/2.+patch_dist*cos((360./(npatch-1.))*(i-1)*!dtor+startpos)
	patch_positions(1,i)=l(1)/2.+patch_dist*sin((360./(npatch-1.))*(i-1)*!dtor+startpos)
	ref_im=[ref_im,image(patch_positions(0,i)-patch_width/2.:patch_positions(0,i)+patch_width/2., $
       	                     patch_positions(1,i)-patch_width/2.:patch_positions(1,i)+patch_width/2.)]
	real_im=[real_im,image(patch_positions(0,i)-patch_width/2.:patch_positions(0,i)+patch_width/2., $
       	                       patch_positions(1,i)-patch_width/2.:patch_positions(1,i)+patch_width/2.)]
endfor
;---------------------------------------------------------------------------------
; By shifting at sub-pixel level, find the optimal shift
;---------------------------------------------------------------------------------
nsubs=91
r_max=-9e9
delta_k=3./float(nsubs)
delta_j=delta_k
for k=-nsubs/2,nsubs/2,1 do begin
for j=-nsubs/2,nsubs/2,1 do begin
r=correlate(ref_im,shift_sub(real_im, k*delta_k, j*delta_j))
if (r gt r_max) then begin
	r_max=r
	best_k_shift=k*delta_k
	best_j_shift=j*delta_j
endif
endfor
endfor
print,'Best subshifts: ',best_k_shift,best_j_shift,' r_max: ',r_max
get_lun,unit
openw,unit,'subshifts.dat'
for k=0,npatch-1,1 do print,patch_positions(0,k),patch_positions(1,k)
close,unit


return, [best_k_shift,best_j_shift]
end


