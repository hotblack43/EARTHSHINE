!P.MULTI=[0,1,2]
files=file_search('*.fits.slice',count=n)
data=get_data(files(0))
plot_io,xtitle='Column #',ytitle='Counts',data(0,*),data(1,*),xstyle=3,yrange=[0.1,1e5]
for i=1,n-1,1 do begin
data=get_data(files(i))
oplot,data(0,*),data(1,*)
endfor
origslice=get_data('infile.slice')
oplot,origslice(0,*),origslice(1,*),color=fsc_color('red')
oplot,[117,117],[1,70000L],linestyle=1
oplot,[397,397],[1,70000L],linestyle=1
;
files=file_search('*.fits.slice',count=n)
origslice=get_data('infile.slice')
data=get_data(files(0))
plot_io,yrange=[0.01,1e4],xtitle='Column #',ytitle='|%| change from ideal',data(0,*),abs(data(1,*)-origslice(1,*))/origslice(1,*)*100.0,xstyle=3
for i=1,n-1,1 do begin
data=get_data(files(i))
oplot,data(0,*),abs(data(1,*)-origslice(1,*))/origslice(1,*)*100.0
endfor
oplot,[117,117],[.01,1e6],linestyle=1
oplot,[397,397],[.01,1e6],linestyle=1
; detail
data=get_data(files(0))
plot_io,xrange=[130,170],yrange=[0.01,1e5],xtitle='Column #',ytitle='|%| change from ideal',data(0,*),abs(data(1,*)-origslice(1,*))/origslice(1,*)*100.0,xstyle=3
for i=1,n-1,1 do begin
data=get_data(files(i))
oplot,data(0,*),abs(data(1,*)-origslice(1,*))/origslice(1,*)*100.0
endfor

end

