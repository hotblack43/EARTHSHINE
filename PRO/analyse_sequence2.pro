PRO get_filename,path,imnum,file
base='NoName'
if (imnum le 9) then file=strcompress(path+base+'0'+string(imnum)+'.FIT',/remove_all)
if (imnum gt 9 and imnum le 99) then file=strcompress(path+base+string(imnum)+'.FIT',/remove_all)
;if (imnum gt 99 and imnum le 999) then file=strcompress(path+base+string(imnum)+'.FIT',/remove_all)
return
end

PRO get_time,header,dectime
;
idx=where(strpos(header, 'TIME-OBS') eq 0)
str='999'
if (idx(0) ne -1) then str=header(idx)
tstr=strmid(str,11,8)
hh=strmid(str,11,2)
mm=strmid(str,14,2)
ss=strmid(str,17,2)
dectime=float(hh)+float(mm)/60.+float(ss)/3600.
;print,tstr,hh,mm,ss,dectime
;stop
return
end

PRO get_exptime,header,exptime
idx=where(strpos(header, 'EXPTIME') eq 0)
idx=where(strpos(header, 'EXPOSURE') eq 0)
str='999'
if (idx(0) ne -1) then str=header(idx)
exptime=float(strmid(str,9,strlen(str)-1))
return
end

;===========================================
; get BIAS file
rdfits_struct, 'c:\rsi\work_idl\bias.fit' , struct,/silent
bias=struct.im0
;
path='C:\CCD\darks\'
path='C:\CCD\brights\'
path='C:\CCD\darklight\'
files=file_search(path,'*.fit')
nims=n_elements(files)
imstart=1
imstop=nims
x=fltarr(nims)
y=fltarr(nims)*0.0+99999.9999
d=fltarr(nims)
z=fltarr(nims)
mn=fltarr(nims)
imcount=0
fmt='(4(1x,f8.3),1x,f14.3)'
count=0
mnlist=fltarr(nims)
dectlist=fltarr(nims)
bias=rebin(bias,1392/4,1040/4)
for imnum=imstart,imstop,1 do begin
    file=files(imnum-imstart)
    rdfits_struct, file , struct,/silent
    header=struct.hdr0
    image=struct.im0
    image=rebin(image,1392/4,1040/4)
    get_exptime,header,exptime
    get_time,header,dectime
    if (imnum eq imstart)  then begin
        stack=[image]
        time_list=[dectime]
        exp_list=[exptime]
    endif
    if (imnum gt imstart)  then begin
        stack=[[[[stack]],[[image]]]]
        time_list=[time_list,dectime]
        exp_list=[exp_list,exptime]
    endif
    if (max(image) eq 2L^16-1) then stop
    mnlist(count)=mean(image)
    dectlist(count)=dectime
    print,format='(a,3(1x,f9.3))',file,mnlist(count),exptime,dectlist(count)
    count=count+1
endfor
l=size(image,/dimensions)
width=l(0)
height=l(1)
print,mnlist
;read,limit,prompt='What is the limit between a dark and a bright frame?'
limit=3000
darks=where(mnlist lt limit)
brights=where(mnlist gt limit)
nbrights=n_elements(brights)
delta=fltarr(nbrights)
for i=0,nbrights-1,1 do begin
; find pairs of darks surrounding the bright frame
d_time=abs(dectlist(brights(i))-dectlist)
sortlist=d_time(sort(d_time))
dummy1=where(d_time eq sortlist(1))
idx_dark1=dummy1(0)
dummy2=where(d_time eq sortlist(2))
idx_dark2=dummy2(0)
; form the mean dark frame from the two nearest dark frames
;print,mean(stack(*,*,brights(i))),mean(stack(*,*,idx_dark1)),mean(stack(*,*,idx_dark2))
meandark=mean((stack(*,*,idx_dark1)+stack(*,*,idx_dark2))/2.)
;meandark=meandark*0.0
;meandark=bias
image=stack(*,*,brights(i))-meandark
part1=image(0:width/2,0:height-1)
part2=image(width/2:width-1,0:height-1)
delta(i)=(mean(part1)-mean(part2))/(mean(image))*100.0
;surface,image
print,i,delta(i),mean(image)
endfor
etimes=exp_list(brights)
!P.MULTI=[0,1,3]
plot,delta,charsize=2,max=4,psym=-4,yrange=[1.6,2.9]
plot,etimes,charsize=2,psym=-7
plot,deriv(delta),charsize=2
select=delta(12:29)
print,stddev(select(where(select gt 1.5 and select lt 3)))
end