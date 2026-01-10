files=file_search('/media/thejll/OLDHD/UNIVERSALSETOFMODELS/','*.fits',count=n)
line=[]
for i=0,n-1,1 do begin
im=readfits(files(i))
line=[[line],[im(*,256)]]
endfor
help,line
for i=0,n-1,1 do begin
if (i eq 0) then plot,/ylog,line(*,i)/interpol(line(*,i),findgen(512),256)
if (i gt 0) then oplot,line(*,i)/interpol(line(*,i),findgen(512),256),color=fsc_color('red')
endfor
end
