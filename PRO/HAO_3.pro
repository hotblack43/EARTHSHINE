FUNCTION generate_image,critical
im=readfits('ANDREW/DATA/moon20060731.00000326.FIT')
dark=readfits('ANDREW/DATA/sydneydark.fit')
im=long(im)-long(dark)
idx=where(im lt critical)
im(idx)=critical
return,im
end

PRO build_unshifted_cube,nimages
common images,cube
common ref,reference
common mask,loff
; will generate nimages in a cube - not shifted
critical=40.0d0
for i=0,nimages-1,1 do begin
    im=double(generate_image(critical))
    if (i eq 0) then begin
        l=size(im,/dimensions)
        cube=im
        reference=mean(im(loff:l(0)-1-loff,loff:l(1)-1-loff),/double)
    endif
    if (i gt 0) then cube=[[[cube]],[[im]]]
endfor
return
end

PRO divide_cube_bygain,gain
common images,cube
common mask,loff
l=size(cube,/dimensions)
;for i=0,l(2)-1,1 do cube(*,*,i)=cube(*,*,i)/gain(*,*)
for i=0,l(2)-1,1 do cube(loff:l(0)-1-loff,loff:l(1)-1-loff,i)=cube(loff:l(0)-1-loff,loff:l(1)-1-loff,i)/gain(loff:l(0)-1-loff,loff:l(1)-1-loff)
print,'Divided images in cube by gain'
return
end

PRO find_gain_relative_mean
common images,cube
common saved,mean_line,n_pixels,gain_in_line
common mask,loff
l=size(cube,/dimensions)
n=l(2)
gain_in_line=dblarr(l)
;for i=0,l(0)-1,1 do begin
 ;   for j=0,l(1)-1,1 do begin
for i=loff,l(0)-1-loff,1 do begin
    for j=loff,l(1)-1-loff,1 do begin
      line=reform(cube(i,j,*))
;print,line
      gain_in_line(i,j,*)=mean(line,/double)/line
    endfor
endfor
return
end

PRO shift_images_in_cube,offsets
common images,cube
; shift  images
l=size(cube,/dimensions)
nimages=l(2)
for imnum=0,nimages-1,1 do cube(*,*,imnum)=shift(reform(cube(*,*,imnum)),offsets(imnum,0),offsets(imnum,1))
return
end

PRO shift_images_back,offsets
common images,cube
; shift shifted images back
l=size(cube,/dimensions)
nimages=l(2)
for imnum=0,nimages-1,1 do cube(*,*,imnum)=shift(cube(*,*,imnum),-offsets(imnum,0),-offsets(imnum,1))
return
end

PRO estimate_gain,newgain
common images,cube
common saved,mean_line,n_pixels,gain_in_line
common mask,loff
; compute new gain surface
l=size(cube,/dimensions)
nimages=l(2)
newgain=dindgen(l(0),l(1))*0.0d0
;for i=0,l(0)-1,1 do begin
 ;   for j=0,l(1)-1,1 do begin
    for i=loff,l(0)-1-loff,1 do begin
    for j=loff,l(1)-1-loff,1 do begin
	line=reform(gain_in_line(i,j,*))
        newgain(i,j)=mean(line,/double)
    endfor
endfor
return
end

PRO pretend_observation,nimages,offsets,gain
common images,cube
common actgain,actual_gain
build_unshifted_cube,nimages
l=size(cube,/dimensions)
actual_gain=((findgen(l(0),l(1)))/(l(0)*l(1))+100.d0)/100.d0
actual_gain=actual_gain-mean(actual_gain,/double)+1.0d0
surface,actual_gain,title='Actual gain',charsize=2
shift_images_in_cube,offsets
gain=findgen(l(0),l(1))*0.0d0+1.0d0   ; this is the current guess of the gain
return
end

PRO make_random_prime_offsets,offsets,nimages
list=prime(nimages*2)
nums=randomu(seed,nimages*2)
idx=where(nums lt 0.5)
jdx=where(nums gt 0.5)
sign=nums*0.0
sign(idx)=-1
sign(jdx)=1
list=list*sign
idx=sort(nums)
list=list(idx)
offsets=reform(list,nimages,2)/3.
openw,11,'offsets.lis'
for i=0,nimages-1,1 do printf,11,offsets(i,0),offsets(i,1)
close,11
return
end

PRO normalize_images
common images,cube
common ref,reference
common mask,loff
l=size(cube,/dimensions)
print,'reference: ',reference
for i=1,l(2)-1,1 do cube(loff:l(0)-1-loff,loff:l(1)-1-loff,i)=cube(loff:l(0)-1-loff,loff:l(1)-1-loff,i)/mean(cube(loff:l(0)-1-loff,loff:l(1)-1-loff,i),/double)*reference
return
end

PRO report_stats,l,loff,gain,actual_gain,iter
    diff=total((gain(loff:l(0)-1-loff,loff:l(1)-1-loff)-actual_gain(loff:l(0)-1-loff,loff:l(1)-1-loff))^2)
    std=stddev(gain(loff:l(0)-1-loff,loff:l(1)-1-loff)-actual_gain(loff:l(0)-1-loff,loff:l(1)-1-loff) )
    print,iter,sqrt(diff),std,mean(gain)
    surface,gain,title='Iteration '+string(iter),min=0.001,charsize=2
return
end

;=====================================================
; HAO.pro
;
; An implementation of an algorithm by Meizner, rast and Holzer, HAO, Boulder
;
;=====================================================
common images,cube
common actgain,actual_gain
common mask,loff
nimages=9
niter=30
;------------------
make_random_prime_offsets,offsets,nimages
loff=max(abs(offsets))
print,'Largest offset=',loff,' sets the data-mask.'
pretend_observation,nimages,offsets,gain    
l=size(cube,/dimensions)
for iter=0,niter-1,1 do begin
    report_stats,l,loff,gain,actual_gain,iter
; step 5
    divide_cube_bygain,gain
    normalize_images
    shift_images_in_cube,-offsets	; aligned on obejcts
;---------
    find_gain_relative_mean
    shift_images_in_cube,offsets   ; aligned on pixels
    estimate_gain,newgain
    gain=gain*newgain
endfor
writefits,'gain.fits',gain
end
