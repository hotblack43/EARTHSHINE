; IDL code to align the synthetic models with the file findamodelforthisimage.fits
;
; get the observed image
im=readfits('findamodelforthisimage.fits',header)
;---------------------------------------------------------------------------- 
; get the synthetic images
syn0p000=readfits('veryspcialimageSSA0p000.fits')
syn0p300=readfits('veryspcialimageSSA0p300.fits')
syn1p000=readfits('veryspcialimageSSA1p000.fits')
;---------------------------------------------------------------------------- 
; set up 4 versions of syn
syn=syn0p300
syn1=syn
syn2=reverse(syn,1)
syn3=reverse(syn,2)
syn4=reverse(reverse(syn,1),2)
; then test which has the best alignemnt
offset1 = alignoffset(syn1, im, corr1)
offset2 = alignoffset(syn2, im, corr2)
offset3 = alignoffset(syn3, im, corr3)
offset4 = alignoffset(syn4, im, corr4)
if (corr1 eq max([corr1,corr2,corr3,corr4])) then flagvalue=1 
if (corr2 eq max([corr1,corr2,corr3,corr4])) then flagvalue=2
if (corr3 eq max([corr1,corr2,corr3,corr4])) then flagvalue=3 
if (corr4 eq max([corr1,corr2,corr3,corr4])) then flagvalue=4 
;
if (flagvalue eq 1) then begin
	offset=offset1
	syn=syn0p300
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA0p300.fits',syn
	syn=syn0p000
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA0p000.fits',syn
	syn=syn1p000
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA1p000.fits',syn
endif
if (flagvalue eq 2) then begin
	offset=offset2
	syn=reverse(syn0p300,1)
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA0p300.fits',syn
	syn=reverse(syn0p000,1)
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA0p000.fits',syn
	syn=reverse(syn1p000,1)
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA1p000.fits',syn
endif
if (flagvalue eq 3) then begin
	offset=offset3
	syn=reverse(syn0p300,2)
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA0p300.fits',syn
	syn=reverse(syn0p000,2)
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA0p000.fits',syn
	syn=reverse(syn1p000,2)
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA1p000.fits',syn
endif
if (flagvalue eq 4) then begin
	offset=offset4
	syn=reverse(reverse(syn0p300,1),2)
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA0p300.fits',syn
	syn=reverse(reverse(syn0p000,1),2)
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA0p000.fits',syn
	syn=reverse(reverse(syn1p000,1),2)
	syn=shift_sub(syn,-offset(0),-offset(1))
	writefits,'veryspcialimageSSA1p000.fits',syn
endif
end
