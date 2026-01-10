rn=[15,10,10,6,2.5]
dc=[9,0.5,0.1,0.001,0.0005]
n=350
name=['STL1001E','512B','U-77','iXon','iKon']
t=0.15
ncams=n_elements(rn)
for i=0,ncams-1,1 do begin
print,'Camera: ',name(i)
rms_one_pixel=sqrt((t*dc(i))^2 +rn(i)^2)
print,'RMS error for one pixel in one image:',rms_one_pixel
print,'RMS error for one pixel in ',N,' images:',rms_one_pixel/sqrt(n)
pixels_needed_for_1pct_error=(rms_one_pixel/sqrt(n)/0.01)^2
print,'Need to average over ',pixels_needed_for_1pct_error,' pixels to get mean error of 1%.'
pixels_needed_for_point5pct_error=(rms_one_pixel/sqrt(n)/0.005)^2
print,'Need to average over ',pixels_needed_for_point5pct_error,' pixels to get mean error of 0.5%.'
endfor
for i=0,ncams-1,1 do begin
rms_one_pixel=sqrt((t*dc(i))^2 +rn(i)^2)
pixels_needed_for_1pct_error=(rms_one_pixel/sqrt(n)/0.01)^2
pixels_needed_for_point5pct_error=(rms_one_pixel/sqrt(n)/0.005)^2
print,format='(a10,1x,2(f8.2,1x),2(i6,1x))',name(i),rms_one_pixel,rms_one_pixel/sqrt(n),pixels_needed_for_1pct_error,pixels_needed_for_point5pct_error
endfor
end
