files=file_search('/media/thejll/OLDHD/MOONDROPBOX/JD2455938/','*MOON_*',count=n)
w=10
for i=0,n-1,1 do begin
    im=readfits(files(i),/silent)
    print,min(im),max(im)
    if (max(im) gt 1000 and max(im) lt 55000) then begin
    l=size(im)
    if (l(0) eq 3) then begin
        print,files(i)
        avim=avg(im,2)
        maxup=-1e22
        k_keep=-911
        for k=0,l(3)-1,1 do begin
            ;print,'subimage k=',k
            diffim=im(*,*,k)/mean(im(*,*,k))*mean(avim)-avim
;               l1=max([coords(0)-w,0])
;               l2=min([coords(0)+w,511])
;               u1=max([coords(1)-w,0])
;               u2=min([coords(1)+w,511])
;               mn=mean(avim(l1:l2,u1:u2))
                mnim=avg(im,2)
;               sd=stddev(avim(l1:l2,u1:u2))
                sdim=stddev(im,dimension=3)
;               d=(im(coords(0),coords(1),k)-mnim)/sdim
                dim=(im-mnim)/sdim
                idx=where(dim eq max(dim))
                coords=array_indices(diffim,idx)
                if (dim(idx) gt maxup) then begin
                    maxup=dim(idx)
                    k_keep=k
	            x0=coords(0)
	            y0=coords(1)
                    endif
            endfor
                if (k_keep ne -911) then begin
			print,maxup,' in subimage ',k_keep,' max at ',coords(0),coords(1)
			markedupim=reform(im(*,*,k_keep))

                        markedupim(x0-w > 0:x0+w < 511,y0-w > 0)=0 ; max(markedupim)
                        markedupim(x0-w > 0:x0+w < 511,y0+w < 511)=0 ; max(markedupim)

                        markedupim(x0-w > 0,  y0-w > 0:y0+w < 511)=0 ; max(markedupim)
                        markedupim(x0+w < 511,y0-w > 0:y0+w < 511)=0 ; max(markedupim)
			tvscl,hist_equal(markedupim)
                endif
        endif
endif
    endfor
end

