plot,indgen(5),indgen(5),/nodata,xrange=[-10,40],yrange=[-1,1]
for jd=julday(5,15,2004,21,0,0),julday(6,27,2004,21,0,0),1 do begin
caldat,jd,a,b,c,d
 mphase,jd, k
plots,b,k,psym=7
 endfor
 end