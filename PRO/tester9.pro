PRO divide_by_flat,image
left_flat=readfits('mean_left_side_flat.FIT')
image(0:650,*)=image(0:650,*)/left_flat(0:650,*)
right_flat=readfits('Right_side_flat.FIT')
image(651:1391,*)=image(651:1391,*)/right_flat(651:1391,*)
return
end

PRO remove_bias,image
bias=readfits('one_median_bias_frame.FIT')
image=image-bias
print,'Removed bias'
return
end


PRO locate_filter_edge_mask,image,maskleft,maskright
contour,image
print,'Click slightly left of left edge of filter'
cursor,ml,dummy
wait,0.5
print,'Click slightly right of right edge of filter'
cursor,mr,dummy
wait,0.5
maskleft=ml
maskright=mr
return
end

PRO make_circle,x0,y0,r,x,y
angle=findgen(1000)/1000.*360.0
x=fix(x0+r*cos(angle*!dtor))
y=fix(y0+r*sin(angle*!dtor))
; make another layer outside first
ran=randomu(seed)
x=[x,fix(x0+(r+1)*cos(angle*!dtor+ran))]
y=[y,fix(y0+(r+1)*sin(angle*!dtor+ran))]
; make another layer inside other two
x=[x,fix(x0+(r-1)*cos(angle*!dtor-ran))]
y=[y,fix(y0+(r-1)*sin(angle*!dtor-ran))]
return
end


PRO generateJD,obsdate,obstime,JD
year=fix(strmid(strmid(obsdate,11,10),0,4))
month=fix(strmid(strmid(obsdate,11,10),5,2))
dd=fix(strmid(strmid(obsdate,11,10),8,2))
hh=fix(strmid(strmid(obstime,11,8),0,2))
mm=fix(strmid(strmid(obstime,11,8),3,2))
ss=fix(strmid(strmid(obstime,11,8),6,2))
JD=julday(month,dd,year,hh,mm,ss)
return
end

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;;;
;;;;             LUNAR FEATURE PHOTOMETRIC ANALYSER 
;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
common keep,bestcorr
common info,JD,imnum
common facts,probableradius,probablex00,probabley00
probableradius=212	; does depend on pixel size...
probablex00=429
probabley00=278
if_rebin=1	; set to 1 if rebinning of image is needed
rebin_factor=2
openw,75,'tabulated_output'
 fit_form=2	; fit Moon's rim with an ellipse
 fit_form=1	; fit Moon's rim with a circle
file='/home/pth/CCD/flat_removed/f_b_may27_obsrun1_IMG10.FIT'
file='/home/pth/CCD/flat_removed/f_b_may27_obsrun1_IMG11.FIT'
file='/home/pth/CCD/flat_removed/f_b_may27_obsrun1_IMG231.FIT'
file='/home/pth/CCD/flat_removed/f_b_may27_obsrun1_IMG55.FIT'
del1='/home/pth/CCD/flat_removed/f_b_may27_obsrun1_IMG'
del2='.FIT'
del1='C:\LaPalma\May27\obsrun1\IMG'
del2='.FIT'
del1='../LaPalmaBackup/lapalma/may27/obsrun1/IMG'
del2='.FIT'
del1='~/Desktop/ASTRO/MOON/May27/obsrun1/IMG'
del1='~/Desktop/ASTRO/MOON/May27/obsrun1/MOONIMAGES/'
printf,75,del1

;
;
;
openw,55,'Crisium_Grimaldi_fits.results'
imstart=164
imstop=164
;imstop=imstart+10
files=file_search(del1,'*.FIT')
nfiles=n_elements(files)
imstart=0
imstop=nfiles
for imnum=imstart,imstop-1,1 do begin
printf,55,'================================================================================='
printf,55,'  '
bestcorr=1e20
file=files(imnum)
;file=strcompress(del1+string(imnum)+del2,/remove_all)
rdfits_struct, file, struct, /silent
results=readfits(file,header)
obsdate=header(10)
obstime=header(11)
generateJD,obsdate,obstime,JD
ephem,JD,alt,az
printf,55,format='(a,1x,a,/,a,1x,a,1x,a,/,a,d20.6)','Fits file name:',file,' Observed at:',obsdate,obstime,' JD:',double(JD)
print,format='(a,1x,a,/,a,1x,a,1x,a,/,a,d20.6)','Fits file name:',file,' Observed at:',obsdate,obstime,' JD:',double(JD)
printf,55,format='(2(a,1x,f9.4,1x))','altitude=',alt,'Azimuth=',az
image=struct.im0
remove_bias,image
divide_by_flat,image
l=size(image,/dimensions)
writefits,strcompress('FLATTENED_BIASREMOVED/FLBI_'+string(imnum)+'.FIT',/remove_all),rebin(image,l/4)
if (imnum eq imstart) then print,'Dimensions of original image:',size(image,/dimensions)
if (imnum eq imstart) then locate_filter_edge_mask,image,maskleft,maskright
; now mask that part of the image
image(maskleft:maskright,*)=0.0
l=size(image,/dimensions)
ncols=l(0)
nrows=l(1)
if (if_rebin eq 1) then begin
	image=rebin(image,ncols/rebin_factor,nrows/rebin_factor)
	print,'REBIN on image has been performed. Dimensions are now:',size(image,/dimensions)
endif
tvscl,image
orgimage=image
; edge-enhance the image
image=sobel(image)
median_sobel=median(image)
std_sobel=stddev(image)
idx=where(image gt median_sobel+3.0*std_sobel)
jdx=where(image le median_sobel+3.0*std_sobel)
image(idx)=1.0
image(jdx)=0.0
l=size(image,/dimensions)

; contour,image
; guess at parameters...
x00=probablex00
y00=probabley00
radius=probableradius
radius1=probableradius
radius2=probableradius
; use last fit
if (fit_form eq 1 and file_test('lastfit_circle') eq 1) then get_lastfit_circle,file,x00,y00,radius
if (fit_form eq 2 and file_test('lastfit_ellipse') eq 1) then get_lastfit_ellipse,file,x00,y00,radius1,radius2
; guess by making row sum and looking for edge...
if (imnum eq imstart or x00 eq -911) then make_row_sum_plot,image,x00,y00,radius
;-------------------------------------------------------------------
; find center and rim by Powell's method....
;
if (fit_form eq 1) then begin
	letsdocircle,file,image,x00,y00,radius,x0,y0,r,bestcorr,orgimage,imnum,imstart
endif	; end of fitting circle
if (fit_form eq 2) then begin
	letsdoellipse,file,image,x00,y00,radius1,radius2,x0,y0,r1,r2,bestcorr,orgimage,imnum,imstart
endif	; end of fitting ellipse
endfor  ; end of imnum loop
close,55
close,75
end
