PRO gofindshifts,cube,offsets
l=size(cube,/dimensions)
offsets=fltarr(l(2),2)
offsets(0,0)=0.0
offsets(0,1)=0.0
ref=reform(cube(*,*,0))
for i=1,l(2)-1,1 do begin
coo=alignoffset(reform(cube(*,*,i)), ref, corr)
offsets(i,0)=-coo(0)
offsets(i,1)=-coo(1)
endfor
return
end

PRO divide_cube_bygain,gain
common images,cube,offsets
common mask,loff
l=size(cube,/dimensions)
;for i=0,l(2)-1,1 do cube(*,*,i)=cube(*,*,i)/gain(*,*)
for i=0,l(2)-1,1 do cube(loff:l(0)-1-loff,loff:l(1)-1-loff,i)=cube(loff:l(0)-1-loff,loff:l(1)-1-loff,i)/gain(loff:l(0)-1-loff,loff:l(1)-1-loff)
print,'Divided images in cube by gain'
return
end

PRO find_gain_relative_mean
common images,cube,offsets
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
      gain_in_line(i,j,*)=line/mean(line,/double)
      ;gain_in_line(i,j,*)=mean(line,/double)/line
    endfor
endfor
return
end

PRO shift_images_in_cube,sign
common images,cube,co_offsets
offsets=co_offsets*sign
; shift  images
l=size(cube,/dimensions)
nimages=l(2)
for imnum=0,nimages-1,1 do cube(*,*,imnum)=shift(reform(cube(*,*,imnum)),offsets(imnum,0),offsets(imnum,1))
return
end

PRO estimate_gain,newgain
common images,cube,offsets
common saved,mean_line,n_pixels,gain_in_line
common mask,loff
; compute new gain surface
l=size(cube,/dimensions)
nimages=l(2)
newgain=dindgen(l(0),l(1))*0.0d0+1.0
    for i=loff,l(0)-1-loff,1 do begin
    	for j=loff,l(1)-1-loff,1 do begin
		line=reform(gain_in_line(i,j,*))
        	newgain(i,j)=mean(line,/double)
    endfor
endfor
surface,newgain
return
end

PRO get_real_images,nimages,gain
common images,cube,offsets
common actgain,actual_gain
files=file_search('/media/SAMSUNG/CLEANEDUP2455923/*_VE2_*',count=nimages)
nimages=10
for i=0,nimages-1,1 do begin
im=readfits(files(i))+100.0
tvscl,im
l=size(im,/dimensions)
if (i eq 0) then cube=im
if (i gt 0) then cube=[[[cube]],[[im]]]
endfor	
; go find the shifts
gofindshifts,cube,offsets
l=size(cube,/dimensions)
actual_gain=fltarr(l(0),l(1))*0.0+1.0
shift_images_in_cube,1.0
gain=findgen(l(0),l(1))*0.0d0+1.0d0   ; this is the current guess of the gain
return
end


PRO normalize_images
common images,cube,offsets
common ref,reference
common mask,loff
l=size(cube,/dimensions)
for i=1,l(2)-1,1 do cube(loff:l(0)-1-loff,loff:l(1)-1-loff,i)=cube(loff:l(0)-1-loff,loff:l(1)-1-loff,i)/mean(cube(loff:l(0)-1-loff,loff:l(1)-1-loff,i),/double)*reference
return
end

PRO report_stats,l,loff,gain,actual_gain,iter
    diff=total((gain(loff:l(0)-1-loff,loff:l(1)-1-loff)-actual_gain(loff:l(0)-1-loff,loff:l(1)-1-loff))^2)
    std=stddev(gain(loff:l(0)-1-loff,loff:l(1)-1-loff)-actual_gain(loff:l(0)-1-loff,loff:l(1)-1-loff) )
    print,iter,' sqrt(diff): ',sqrt(diff),' std: ',std,' mean: ',mean(gain)
    surface,gain,title='Iteration '+string(iter),min=0.001,charsize=2
return
end

;=====================================================
; HAO.pro
;
; An implementation of an algorithm by Meizner, rast and Holzer, HAO, Boulder
;
;=====================================================
common images,cube,offsets
common actgain,actual_gain
common mask,loff
common ref,reference
;------------------
; step 1
get_real_images,nimages,gain
; step 2
loff=max(abs(offsets))
print,'Largest offset=',loff,' sets the data-mask.'
im=reform(cube(*,*,0))
l=size(im,/dimensions)
reference=mean(im,/double)
;reference=mean(im(loff:l(0)-1-loff,loff:l(1)-1-loff),/double)
l=size(cube,/dimensions)
niter=3
for iter=0,niter-1,1 do begin
    shift_images_in_cube,-1.0; aligned on obejcts
    report_stats,l,loff,gain,actual_gain,iter
; step 5
    divide_cube_bygain,gain
    normalize_images
; step 8
;---------
    find_gain_relative_mean
    shift_images_in_cube,1.0; aligned on pixels
    estimate_gain,newgain
print,n_elements(where(finite(gain) ne 1))
print,n_elements(where(finite(newgain) ne 1))
; step 10
    gain=gain*newgain
endfor
writefits,'gain.fits',double(gain)
end
