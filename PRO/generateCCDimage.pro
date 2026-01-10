PRO generateCCDimage,IN,OUT

common stuff,imsize,image,icount,x1,y1,x2,y2,if_show,device_str,if_poisson
LOCAL=double(IN)
; generates an image with counts between 0 and 60000, simulating a
; well exposed 16-bit exposed image, NB: 2^16 = 65536....
;
;  First scale the input image
maxval=60000.0d0
LOCAL=(LOCAL+min(LOCAL))      ; ; all values positive or 0
LOCAL=LOCAL/max(LOCAL)  ; all values between 0 and 1
LOCAL=LOCAL*maxval  ; all values between 0 and maxval
if (if_show eq 1) then begin
    window,1
    autohist,LOCAL;,xtitle='Pixel value (counts)', ytitle='N';,title='Simulated CCD image'
    ;wait,3
    window,0
endif
; then add Poison noise
old_LOCAL=LOCAL
l=size(LOCAL,/dimensions)
biaslevel=100.
skylevel=10.
bias=biaslevel
sky=skylevel
if (if_poisson eq 1) then begin
    for i=0,l(0)-1,1 do begin
    for j=0,l(1)-1,1 do begin

       if (LOCAL(i,j) ne 0.0) then local(i,j)=RANDOMU(seed,poisson=LOCAL(i,j))

    endfor
    endfor

; then set up the image as a sum of bias, sky background and readout noise...
bias=biaslevel
sky=randomu(seed,l,poisson=skylevel)
; readoutnoise=LOCAL*0.0+readoutnoiselevel
; finally make the image into a long integer file

endif
OUT=long(LOCAL+bias+sky)
; flatfield=LOCAL*0.0d0+1.0d0
; get_flatfield,OUT,flatfield
; OUT=long(flatfield*(LOCAL+sky)+bias)
return
end
