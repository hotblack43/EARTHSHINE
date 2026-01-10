files=file_search('profile_*.sav',count=n)
sum=[]
for i=0,n-1,1 do begin
restore,files(i)
if (i eq 0) then plot_io,profile
if (i ne 0) then oplot,profile
sum=[[sum],[profile]]
;if (i eq 0) then sum=profile
;if (i gt 0) then sum=sum+profile
;if (i gt 0) then sum=sum+profile
endfor
sum=transpose(sum)
profile=median(sum,dimension=1)
save,filename='summed_laserprofle.sav',profile
oplot,profile,color=fsc_color('red')
end

