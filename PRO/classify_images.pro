path='LaPalmaBackup/lapalma/may25/obs'
path='LaPalmaBackup/lapalma/may26/'
path='LaPalmaBackup/lapalma/may27/'
path='LaPalmaBackup/lapalma/may28/'
path='LaPalmaBackup/lapalma/may29/'
path='LaPalmaBackup/lapalma/may30/'
path='LaPalmaBackup/lapalma/may31/'
files=file_search(path,'*.fit',FOLD_CASE=1)
print,files
maxstrlen=max(strlen(files))
openw,11,strcompress(path+'image_classification.txt',/remove_all)
n=n_elements(files)
for i=0,n-1,1 do begin
im=readfits(files(i),header)
date_str=strmid(header(10),11,10)
time_str=strmid(header(11),11,8)
expo_str=strmid(header(40),12,17)
tvscl,im
type=''
read,type
printf,11,format='(i3,1x,a'+string(maxstrlen)+',1x,a,2(1x,i4),1x,a,1x,a,1x,f8.3)',i,files(i),type,size(im,/dimensions),date_str,time_str,float(expo_str)
endfor
close,11
print,'Created file ',strcompress(path+'image_classification.txt',/remove_all)
end

