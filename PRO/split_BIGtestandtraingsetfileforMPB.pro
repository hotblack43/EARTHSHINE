PRO scalethedata,data
; will scale the data to the -1,1 range
; seperately for the inputs and the output
l=size(data,/dimensions)
; scale the inputs
data(0:l(0)-1,*)=data(0:l(0)-1,*)-min(data(0:l(0)-1,*))
data(0:l(0)-1,*)=data(0:l(0)-1,*)/max(data(0:l(0)-1,*))*2.-1.0
print,min(data(0:l(0)-1,*)),max(data(0:l(0)-1,*))
; scale the outputs
data(l(0)-1,*)=data(l(0)-1,*)-min(data(l(0)-1,*))
data(l(0)-1,*)=data(l(0)-1,*)/max(data(l(0)-1,*))*2.-1.0
print,min(data(l(0)-1,*)),max(data(l(0)-1,*))
return
end

trainpct=80
data=get_data('MPB.txt')
scalethedata,data
l=size(data,/dimensions)
ncols=l(0)
n=l(1)
print,l,n,n*float(trainpct)/100.,n*float(trainpct)/100.
openw,1,'train_input.dat'
openw,2,'train_target.dat'
openw,3,'test_input.dat'
openw,4,'test_target.dat'
fmt1='('+string(fix(l(0)-3))+'(1x,f10.7))'
fmt2='(3(1x,f10.7))'
print,fmt1
print,fmt2
for i=0,n-1,1 do begin
if (i le n*float(trainpct)/100.) then begin
print,'For training set'
printf,format=fmt1,1,data(0:l(0)-4,i)
printf,format=fmt2,2,data(l(0)-3:l(0)-1,i)
endif
if (i gt n*float(trainpct)/100.) then begin
print,'For testing set'
printf,format=fmt1,3,data(0:l(0)-4,i)
printf,format=fmt2,4,data(l(0)-3:l(0)-1,i)
endif
endfor
close,1
close,2
close,3
close,4
end
