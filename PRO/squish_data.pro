PRO squish,array,mingoal,maxgoal
l=size(array,/dimensions)
ncol=l(0)
nrows=l(1)
minval=min(array(0:ncol-2,*))
maxval=max(array(0:ncol-2,*))
print,'Original min,max: ',minval,maxval
;
scaledarray=array(0:ncol-2,*)
scaledarray=(scaledarray-minval)/(maxval-minval)
array(0:ncol-2,*)=scaledarray
minval=min(array(0:ncol-2,*))
maxval=max(array(0:ncol-2,*))
print,'Scaled min,max: ',minval,maxval
array(ncol-1,*)=fix(array(ncol-1,*)*1000)
col=array(0,*)*0+1
array=[col,array]
return
end

close,/all
n=25
nstrplus1=string(n*n+1)
data=get_data('/data/pth/TABLE_TOTRAIN.DAT')
squish,data,0,1
openw,2,'scaled_array.dat'
printf,2,format='('+nstrplus1+'(f12.5,","),i4)',data
close,2
end
