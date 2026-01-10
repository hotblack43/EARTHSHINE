files=file_search('2456073.7758928MOON_B_AIR_UNaligned_sum_of_100_*',count=n)
print,'Found ',n,' files.'
print,'         N                   SD            1/SD'
print,'------------------------------------------------'
for nsq=10,50,5 do begin
openw,33,'skysquare.dat'
for i=0,n-1,1 do begin
im=readfits(files(i),/silent)
printf,33,nsq,mean(im(0:nsq,511-nsq:511))
;print,nsq,mean(im(0:nsq,511-nsq:511))
endfor
close,33
data=get_data('skysquare.dat')
print,data(0,0),stddev(data(1,*)),abs(1/stddev(data(1,*)))
endfor
end
