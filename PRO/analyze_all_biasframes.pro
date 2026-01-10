PRO getJDfromheader,l,header,JD
print,l
idx=where(strpos(header,'DATE') ne -1)
line=header(idx)
line=strmid(line,11,strlen(line)-1)
line=strmid(line,0,19)
yyyy=fix(strmid(line,0,4))
mm=strmid(line,5,2)
dd=strmid(line,8,2)
hh=strmid(line,11,2)
mi=strmid(line,14,2)
ss=strmid(line,17,2)
JD=double(julday(mm,dd,yyyy,hh,mi,ss))
if (l(0) eq 3) then JD=replicate(jd,l(3))
return
end

PRO getallbiasframenames_fromlist,files,n
listname='allBIAS'
get_lun,w
openr,w,listname
name=''
i=0
while not eof(w) do begin
    readf,w,name
    if (i eq 0) then files=name
    if (i gt 0) then files=[files,name]
    i=i+1
    endwhile
close,w
free_lun,w
return
end


PRO goformstack,files,stack,JD
common stuff,imsize
n=n_elements(files)
for i=0,n-1,1 do begin
    im=readfits(files(i),header,/sil)
    print,'Read ',i,' of ',n,' Fits images.'
    l=size(im)
    getJDfromheader,l,header,JDnum
    if (l(0) eq 2) then begin
        if (imsize ne 512) then im=rebin(im,imsize,imsize)
        if(i eq 0) then stack=im
        if(i gt 0) then stack=[[[stack]],[[im]]]
        endif
    if (l(0) eq 3) then begin
        if (imsize ne 512) then im=rebin(im,imsize,imsize,l(3))
        if(i eq 0) then stack=im
        if(i gt 0) then stack=[[[stack]],[[im]]]
        endif
    if(i eq 0) then JD=JDnum
    if(i gt 0) then JD=[JD,JDnum]
    endfor
return
end

PRO godescribestats,stack,files,JD
l=size(stack,/dimensions)
n=l(2)
get_lun,w
openw,w,'List_of_BIAS_frames_and_mean_values.txt'
for i=0,n-1,1 do begin
    if (i eq 0) then list=mean(stack(*,*,i),/double)
    if (i gt 0) then list=[list,mean(stack(*,*,i),/double)]
    printf,w,format='(f20.8,1x,f9.4)',jd(i),mean(stack(*,*,i))
    endfor
plot,list,xtitle='Seq. #',ytitle='Mean BIAS level',ystyle=1,xstyle=3,psym=-7
plot,jd-jd(0),list,xtitle='days since first',ytitle='Mean BIAS level',ystyle=1,xstyle=3,psym=-7
close,w
free_lun,w
print,'Wrote a list of mean values to "List_of_BIAS_frame_mean_values.txt".'
return
end

PRO gettheFITofmodel2,stack,bestfitted_bias,SD_model2
; Model is BIAS=bestfitted_bias+offset
; will use the suggested best BIAS, subtract it from the actual bias
; add an offset based on the residuals
; will report back on the stats of the residuals that result
l=size(stack,/dimensions)
nbias=l(2)
im2=bestfitted_bias(*,*)
for i=0,nbias-1,1 do begin
    im1=reform(stack(*,*,i))
    diff=im1-im2
    offset=median(diff)
    model=im2+offset
    residuals=im1-model
    if (i eq 0) then SDstack=stddev(residuals,/double)
    if (i gt 0) then SDstack=[SDstack,stddev(residuals,/double)]
    endfor
SD_model2=[mean(SDstack),stddev(SDstack,/double)]
return
end

PRO gettheFITofmodel1,stack,bestfitted_bias,SD_model1
; Model is BIAS=f*bestfitted_bias
; will use the suggested best BIAS frame and scale it to the actual bias
; will report back on the stats of the residuals that result
l=size(stack,/dimensions)
nbias=l(2)
im2=bestfitted_bias(*,*)
for i=0,nbias-1,1 do begin
    im1=reform(stack(*,*,i))
    f=im1/im2
    f=median(f)
    residuals=im1-f*im2
    if (i eq 0) then SDstack=stddev(residuals,/double)
    if (i gt 0) then SDstack=[SDstack,stddev(residuals,/double)]
    endfor
SD_model1=[mean(SDstack),stddev(SDstack,/double)]
return
end


PRO getthebestfittedsurface,bias_mhm,bestfitted_bias,bestorder,bestcoeffs
maxerror=2e33
bestorder=-911
for iorder=1,5,1 do begin
    surf=sfit(bias_mhm,iorder,kx=coeffs)
    residuals=bias_mhm-surf
    SD=stddev(residuals)
    if (sd lt maxerror) then begin
        maxerror=sd
        bestorder=iorder
        bestcoeffs=coeffs
        bestfitted_bias=surf
        !P.MULTI=[0,1,2]
        plot,avg(residuals,0),title='Column AVG. order '+string(iorder)
        plot,avg(residuals,1),title='Row AVG. order '+string(iorder)
        writefits,'Fitted_Surface_BIAS.fits',bestfitted_bias
        writefits,'Residuals_Fitted_Surface_BIAS.fits',bias_mhm-bestfitted_bias
        endif
    print,iorder,sd,bestorder
    endfor
return
end


PRO getallbiasframenames,path,files,n
files=file_search(path,'*bias*.fits',/fold_case,count=n)
get_lun,w
openw,w,'Names_of_detected_BIAS_frames.txt'
for i=0,n-1,1 do begin
    printf,w,files(i)
    endfor
close,w
free_lun,w
print,'List of all detected BIAS frames written to "Names_of_detected_BIAS_frames.txt".'
end

PRO go_mean_half_median,im,dark
l=size(im,/dimensions)
dark=fltarr(l(0),l(1))
for i=0,l(0)-1,1 do begin
    for j=0,l(1)-1,1 do begin
        line=im(i,j,*)
        line=line(sort(line))
        low=l(2)*0.25
        high=l(2)*0.75
        middlehalf=line(low:high)
        dark(i,j)=mean(middlehalf)
        endfor
    endfor
return
end




;================================================================
; Code to find and analyze BIAS frames
; The frames are fitted with a model of the bias
; and evaluative statistics printed out
; Version 1.
;================================================================
common stuff,imsize
imsize=512/2	; to accomodate MANY BIAS frames, set imsize to something less than 512
!P.MULTI=[0,1,1]
; First get the names of all reachable BIAS frames on the path
ifwant_search=0	; 1 if want fresh search, 0 if want use list
path='/media/LaCie/ASTRO/ANDOR/'
if (ifwant_search eq 1) then getallbiasframenames,path,files,n
if (ifwant_search ne 1) then getallbiasframenames_fromlist,files,n
; then form a giant stack of them
goformstack,files,stack,JD
; describe the statistics of that stack
godescribestats,stack,files,JD
; Go and form the 'mean half-median frame
print,'Forming the mean half-median image ...'
go_mean_half_median,stack,bias_mhm
; then go and fit a surface to the frame
print,'Estimating the order of the best polynomial surface that can be fitted ...'
getthebestfittedsurface,bias_mhm,bestfitted_bias,bestorder,bestcoeffs
; plot it
surface,[bestfitted_bias,bias_mhm]
; Now go and use that 'best estimated BIAS frame', to see if is proportional
; or additively related to the actual bias frames
print,'Now evaluating model 1: purely multiplicative ..'
gettheFITofmodel1,stack,bestfitted_bias,SD_model1
print,'Model 1: mean(SD,residuals)=',SD_model1(0),' SD(SD,residuals)=',SD_model1(1)
print,'Now evaluating model 2: constant frame plus offset..'
gettheFITofmodel2,stack,bestfitted_bias,SD_model2
print,'Model 2: mean(SD(residuals))=',SD_model2(0),' SD(SD(residuals))=',SD_model2(1)
end

