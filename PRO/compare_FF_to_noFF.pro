w=12
!P.MULTI=[0,2,3]
openr,1,'jointlist'
openw,55,'FFeffectonlinethroughcentre_mean_sd.dat'
while not eof(1) do begin
str=''
readf,1,str
fil1=file_search('/data/pth/DARKCURRENTREDUCED/SELECTED_4d/'+str+'*.fits*')
fil2=file_search('/data/pth/DARKCURRENTREDUCED/SELECTED_4c/'+str+'*.fits*')
im1=readfits(fil1,HyesFF)
            get_info_from_header,HyesFF,'X0',x0
             get_info_from_header,HyesFF,'Y0',y0
             get_info_from_header,HyesFF,'RADIUS',radius
print,x0,y0,radius
im2=readfits(fil2,HnoFF)
diff=im1-im2
reldiff=diff/(0.5*(im1+im2))
;tvscl,hist_equal(diff)
;histo,reldiff,-2,2,0.1
line1=avg(im1(*,y0-w:y0+w),1)
line2=avg(im2(*,y0-w:y0+w),1)
icols=findgen(512)
area1=where(icols lt x0-radius)
area2=where(icols gt x0-radius and icols lt x0+radius )
area3=where(icols gt x0+radius)
im1val=mean(line1(area1))
im2val=mean(line2(area1))
line2=line2+(im1val-im2val)
;line 2 now adjusted to levels of line1 in area1
;
DSidx=where(icols gt x0-radius and icols lt x0+radius and line1(icols) lt max(line1(icols))/1000.)
DSfrom=min(icols(DSidx))
DSto=max(icols(DSidx))
;
plot,xstyle=3,ytitle='absolute change along centre line',xtitle='column #',(line1-line2),title=str,yrange=[-0.1,0.1]
oplot,[x0-radius,x0-radius],[!Y.crange],linestyle=1
oplot,[x0+radius,x0+radius],[!Y.crange],linestyle=1
oplot,[DSfrom,DSfrom],[!Y.crange],linestyle=0,color=fsc_color('red')
oplot,[DSto,DSto],[!Y.crange],linestyle=0,color=fsc_color('red')
printf,55,format='(f15.7,5(1x,f10.5))',str,mean(line1(area1)-line2(area1)),mean(line1(area2)-line2(area2)),mean(line1(area3)-line2(area3)),mean(line1(DSidx))-mean(line2(DSidx)),(mean(line1(DSidx))-mean(line2(DSidx)))/mean(line1(DSidx))*100.
endwhile
close,1
close,55
;
data=get_data('FFeffectonlinethroughcentre_mean_sd.dat')
!P.charsize=1.9
histo,data(4,*),-.1,.1,0.01,xtitle='Change in DS mean counts after FF',/abs
histo,data(5,*),-2,2,0.1,xtitle='Change in DS mean [%] after FF',/abs
oplot,[median(data(5,*)),median(data(5,*))],[!Y.crange],linestyle=1
print,'Median change on DS: ',median(data(5,*))
end
