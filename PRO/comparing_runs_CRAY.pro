PRO extractbits,str,bit1,bit2,fn
;print,str
bit1=strmid(str,0,22)
;print,bit1
ipt=strpos(str,'24')
bit2='/'+strmid(str,ipt,strlen(str)-ipt-11)+'/'
print,bit2
spawn,"echo "+bit2+" | sed 's/_/ /g' | awk '{print $2}' > filtername12"
fn=''
openr,93,'filtername12' & readf,93,fn & close,93
print,'Filtername found: ',fn
;stop
return
end

PRO extractJD,str,JD
spawn,"echo "+str+" | sed 's/\// /g' | sed 's/MOON/ MOON/g' | awk '{print $6}' | sed 's/d/\./g' > aha"
JD=get_data('aha')
;print,format='(f20.10)',JD
return
end

PRO gofindDSBS,obs,im,x0,y0,radius,cg_x,cg_y,w,BS,DS
; determine if BS is to trhe right or the left of the center
if (cg_x gt x0) then begin
; BS is to the right
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0-radius*2./3.-w:x0-radius*2./3.+w,y0-w:y0+w))
endif
if (cg_x lt x0) then begin
; BS is to the left
BS=median(obs(cg_x-w:cg_x+w,cg_y-w:cg_y+w))
DS=median(im(x0+radius*2./3.-w:x0+radius*2./3.+w,y0-w:y0+w))
endif
return
end

PRO cgfinder,im,cg_x,cg_y
; find c.g.
 l=size(im,/dimensions)
 meshgrid,l(0),l(1),x,y
 cg_x=total(x*im)/total(im)
 cg_y=total(y*im)/total(im)
return
end

PRO getBINfile,name_in,im,obs
name=strcompress(name_in+'/output.raw',/remove_all)
;print,'name: ',name
ino=file_info(name)
n=ino.size
if(n eq 1048576L) then begin
nn=sqrt(n)/2
im=fltarr(nn,nn)
endif
if(n eq 2*1048576L) then begin
nn=sqrt(2097152L/2)/2
im=dblarr(nn,nn)
endif
openr,1,name
readu,1,im
close,1
; get the observed image
name=strcompress(name_in+'/target.raw',/remove_all)
;print,'name: ',name
ino=file_info(name)
n=ino.size
if(n eq 1048576L) then begin
nn=sqrt(n)/2
obs=fltarr(nn,nn)
endif
if(n eq 2*1048576L) then begin
nn=sqrt(2097152L/2)/2
obs=dblarr(nn,nn)
endif
openr,1,name
readu,1,obs
close,1
return
end

path='/data/pth/RESULTS/EFM/'
fils=file_search(path,'output.raw',count=n)
print,'Found ',n
openw,44,'compared_EFM_results.dat'
for inam=0,n-1,1 do begin
extractbits,fils(inam),bit1,bit2,fn
nam1=strcompress(bit1+'RUN1_CRAY'+bit2,/remove_all)
extractJD,nam1,JD
nam2=strcompress(bit1+'RUN2_CRAY'+bit2,/remove_all)
nam3=strcompress(bit1+'RUN3_CRAY'+bit2,/remove_all)
nam4=strcompress(bit1+'RUN4_CRAY'+bit2,/remove_all)
nam5=strcompress(bit1+'RUN5_CRAY'+bit2,/remove_all)
;
data=get_data(path+'/RUN1_CRAY/'+bit2+'/coords.dat')
x0=reform(data(0)) & y0=reform(data(1)) & radius=reform(data(2))
;
w=5
getBINfile,nam1,output1,ob1
cgfinder,ob1,cg_x,cg_y	; finding the photometric center of gravity from the observed image's BS
gofindDSBS,ob1,ob1,x0,y0,radius,cg_x,cg_y,w,BSorig,DSorig
getBINfile,nam2,output2,ob2
gofindDSBS,ob1,output1,x0,y0,radius,cg_x,cg_y,w,BS1,DS1
getBINfile,nam2,output2,ob2
gofindDSBS,ob2,output2,x0,y0,radius,cg_x,cg_y,w,BS2,DS2
getBINfile,nam3,output3,ob3
gofindDSBS,ob3,output3,x0,y0,radius,cg_x,cg_y,w,BS3,DS3
getBINfile,nam4,output4,ob4
gofindDSBS,ob4,output4,x0,y0,radius,cg_x,cg_y,w,BS4,DS4
getBINfile,nam5,output5,ob5
gofindDSBS,ob5,output5,x0,y0,radius,cg_x,cg_y,w,BS5,DS5
;print,'DS: ',DS1,DS2,DS3,DS4,DS5,stddev([DS1,DS2,DS3,DS4,DS5])/mean([DS1,DS2,DS3,DS4,DS5])*100.,' %',stddev([DS1,DS2,DS3,DS4,DS5])/median([DS1,DS2,DS3,DS4,DS5])*100.
;print,'BS: ',BS1,BS2,BS3,BS4,BS5,stddev([BS1,BS2,BS3,BS4,BS5])/mean([BS1,BS2,BS3,BS4,BS5])*100.,' %',stddev([BS1,BS2,BS3,BS4,BS5])/median([BS1,BS2,BS3,BS4,BS5])*100.
ratio=median([BS1,BS2,BS3,BS4,BS5])/median([DS1,DS2,DS3,DS4,DS5])
ratio_orig=BSorig/DSorig
;print,'   Cleaned BS/DS= ',ratio
;print,'un-Cleaned BS/DS= ',ratio_orig
print,format='(f16.7,7(1x,g12.8),2(1x,g10.6),1x,a)',JD,DS1,DS2,DS3,DS4,DS5,BS1,stddev([DS1,DS2,DS3,DS4,DS5])/median([DS1,DS2,DS3,DS4,DS5])*100.,ratio,ratio_orig,fn
printf,44,format='(f16.7,7(1x,g12.8),2(1x,g10.6),1x,a)',JD,DS1,DS2,DS3,DS4,DS5,BS1,stddev([DS1,DS2,DS3,DS4,DS5])/median([DS1,DS2,DS3,DS4,DS5])*100.,ratio,ratio_orig,fn
endfor
close,44
end
