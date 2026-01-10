PRO get_pdf_CIE,l,pdf,scale
common skybias,bias
; allows for a bias
pdf=dblarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r= sqrt((i-l(0)/2)^2+(j-l(1)/2.)^2)
		pdf(i,j)=exp(-abs(r/scale))
	endfor
endfor
; add the bias
pdf=pdf+bias
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
return
end

PRO get_pdf_King,l,pdf,power
pdf=dblarr(l(0),l(1))
pp=abs(power)
half_i=l(0)/2.
half_j=l(1)/2.
for i=0,l(0)-1,1 do begin
	for j=0,l(1)-1,1 do begin
		r= sqrt((abs(i-half_i))^2+(abs(j-half_j))^2)
		if (r gt 1.0) then pdf(i,j)=1.0d0/r^pp else pdf(i,j)=1.0d0
	endfor
endfor
; shift the pdf to the origin
pdf=shift(pdf,l(0)/2,l(1)/2.)
; normalize it
pdf=pdf/total(pdf,/double)
return
end

PRO get_imin2,imin,l
common paths,path
imin=readfits(path+'LunarImg_0001.fts')
;imin=readfits(path+'ANDREW/DATA/moon20060731.00000168.FIT')
imin=congrid(imin,400,400)
l=size(imin,/dimensions)
writefits,path+'EX2_ideal_image_input_400x400.fit',imin
writefits,path+'EX2_ideal_image_input_400x400_LONG.fit',long(imin)
return
end

PRO fold_image_with_pdf,imin,l,folded_image,pdf
folded_image=fft(fft(imin,-1,/double)*fft(pdf,-1,/double),1,/double)
folded_image=sqrt(folded_image*conj(folded_image))
folded_image=double(folded_image)
folded_image=folded_image/total(folded_image)*total(imin)
return
end

common moonres,im1,im2,im3
common uselater,im4,difference
common type,typeflag
common method,method_str
common describstr,exp_str
common vizualise,viz
common paths,path
common problem,if_generate_problem
common skybias,bias
;----------------------------------------------------------
bias=0.0        ; set the bias that will be added to the fake image
;----------------------------------------------------------
; select the operating system
path=':\Documents and Settings\Peter Thejll\Desktop\ASTRO\'     ; Windows at home
path='./'       ; i.e. Unix at work
;---------------------------------------------------
; Select the type of imposed profile
typeflag='GAUSSIAN'
typeflag='CIE'
typeflag='KING'
;----------------------------------------------------------
; select the type of scattered-light removal
method_str='linear'
method_str='forward'
;----------------------------------------------------------
; Set a descriptive experiment string
other_str='sydney'
other_str='IDEALIZED'
exp_str=strcompress(typeflag+method_str+other_str,/remove_all)
;..........................
get_imin2,imin,l
; save the input image for processing stage
mkhdr,header,imin
writefits,'ideal_starting_image.fit',imin,header
; add some Poisson like bias level to the image
imin=imin+randomu(seed,l(0),l(1),poisson=1000.)/100.
;----------------------------------------------------------
; Get the right PDF in order to convolve the ideal image and get your fake oberveed image
example=20.
example_power=example/10.
trial_sigma=(50.0d0)^2  ; for Gaussian profile
scale=15.0d0           ; for exp(-abs(scale*radius)) profile
if (STRUPCASE(typeflag) eq "KING") then get_pdf_King,l,pdf,example_power
if (STRUPCASE(typeflag) eq "GAUSSIAN") then get_pdf_Gaussian,l,pdf,trial_sigma
if (STRUPCASE(typeflag) eq "CIE") then get_pdf_CIE,l,pdf,scale
;----------------------------------------------------------
; Now convolve the image with the PDF
fold_image_with_pdf,imin,l,folded_image,pdf
weight=0.01
combined_image=imin/mean(imin)*(1.0-weight)+weight*folded_image/mean(folded_image)
observed_image=combined_image/mean(combined_image)*mean(imin)
writefits,strcompress('simulated_observed_image_'+string(fix(example))+'.fit',/remove_all),observed_image,header
print,'Done!'
end
