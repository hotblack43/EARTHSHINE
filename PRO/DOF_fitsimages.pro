im=double(readfits('moon.fits'))
;
svdc,im,w,u,v,/double
;
print,'Singular values:',w
;
plot,w,/ylog
; now reconstruct the image 
for ndof=10,511,5 do begin
sv = im*0.0
FOR K = 0, ndof DO sv[K,K] = W[K]  
result = U ## sv ## TRANSPOSE(V)  
pct=(result-im)/im*100.0
tvscl,hist_equal(pct)
;pct=(result-im)
;surface,pct,charsize=2
print,ndof,sqrt(mean(pct^2))
writefits,'result.fits',result
writefits,'difference.fits',pct
endfor
end
