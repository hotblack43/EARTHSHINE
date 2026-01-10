files=file_search('C:\Documents and Settings\Peter Thejll\My Documents\My Pictures\','*.jpg',count=n)
for i=0,n-1,1 do begin
print,i,files(i)
read_jpeg,files(i),im
l=size(im,/dimensions)
if (n_elements(l) eq 3) then begin
r=mean(im(0,*))
g=mean(im(1,*))
b=mean(im(2,*))
li=mean(im)
	r=reform(r/(r+g+b))
	g=reform(g/(r+g+b))
	b=reform(b/(r+b+g))
	if (i eq 0 ) then begin
		r_g=r-g
		r_b=r-b
		g_b=g-b
		lightness=li
	endif

	if (i gt 0 ) then begin
		r_g=[r_g,r-g]
		r_b=[r_b,r-b]
		g_b=[g_b,g-b]
		lightness=[lightness,li]
	endif
		endif
endfor
!P.MULTI=[0,2,4]
histo,lightness,0,260,10,xtitle='mean pixel value'
idx=where(lightness gt -100)
plot,r_g(idx),r_b(idx),psym=4,xtitle='R - G',ytitle='R - B',charsize=2
plot,r_g(idx),g_b(idx),psym=4,xtitle='R - G',ytitle='G - B',charsize=2
plot,r_b(idx),g_b(idx),psym=4,xtitle='R - B',ytitle='G - B',charsize=2
;
array=[transpose(lightness),transpose(r_g),transpose(r_b),transpose(g_b)]
array=standardize(array)
Weights = Clust_Wts(array,n_clusters=2)
;
;       Compute the classification of each sample.
result = CLUSTER(array, Weights)
;
;       Print each sample (each row) of the array and its corresponding
;       cluster assignment.
for k = 0, N_ELEMENTS(result)-1 do PRINT, $
array(*,k), result(k), FORMAT = '(4(f8.3, 2x), 5x, i3)'
;
clusters=result(uniq(result(sort(result))))
n_clusters=n_elements(clusters)
print,'There are ',n_clusters,' clusters.'
for i=0,n_clusters-1,1 do begin
	idx=where(result eq clusters(i))
	for k=0,n_elements(idx)-1,1 do print,i,array(*,idx(k))
endfor
;
print,'The clusters are:'
print,'    Cl.#     light           R-G         R-B        G-B'
for l=0,n_clusters-1,1 do print,l,weights(*,l)

end
