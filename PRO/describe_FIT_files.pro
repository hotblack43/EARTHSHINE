PRO remove_bias,image,bias
bias=readfits('Bias_frame.FIT')
image=float(image)-float(bias)
print,'Removed bias'
return
end

!P.multi=[0,1,2]
path='.dmismb/i/Home/FK/THEJLL/CCD/'
files=file_search(path,'*.FIT')
openw,13,'files_described.txt'
for i=0,n_elements(files)-1,1 do begin
im=readfits(files(i),header)
remove_bias,im,bias
l=size(im,/dimensions)
plot,total(im,1),ystyle=1
plot,total(im,2),ystyle=1
exptime=float(strmid(header(40),10,100))
printf,13,format='(a,2(1x,g10.5))',files(i),exptime,mean(im)
print,format='(a,2(1x,g10.5))',files(i),exptime,mean(im)
a=get_kbrd()
endfor
close,13
end
