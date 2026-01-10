;files=file_search('C:\Documents and Settings\Peter Thejll\My Documents\My Pictures\','*.jpg',count=n)
files=file_search('/home/pth/','*.jpg',count=n)
openw,33,'List_of_colour_jpgs.dat'
for i=0,n-1,1 do begin
;openr,11,'List_of_colour_jpgs.dat'
;i=0
;while not eof(11) do begin
;namefil=''
;readf,11,namefil
read_jpeg,files(i),im
;read_jpeg,namefil,im
l=size(im,/dimensions)
if (n_elements(l) eq 2) then print,'B&W image: ',files(i)
if (n_elements(l) eq 3) then begin
	print,'Colour image: ',files(i)
	;print,'Colour image: ',namefil
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
		;name=namefil
		name=files(i)
	endif
	if (i gt 0 ) then begin
		r_g=[r_g,r-g]
		r_b=[r_b,r-b]
		g_b=[g_b,g-b]
		lightness=[lightness,li]
		;name=[name,namefil]
		name=[name,files(i)]
	endif
	if (finite(r-g)*finite(g-b)*finite(r-b)*finite(li) ne 1) then stop
	printf,33,files(i)
	endif
endfor
;i=i+1
;endwhile
close,11
close,33
!P.MULTI=[0,1,4]
histo,lightness,0,260,10,xtitle='mean pixel value'
idx=where(lightness gt -100)
plot,r_g(idx),r_b(idx),psym=3,xtitle='R - G',ytitle='R - B',charsize=2
plot,r_g(idx),g_b(idx),psym=3,xtitle='R - G',ytitle='G - B',charsize=2
plot,r_b(idx),g_b(idx),psym=3,xtitle='R - B',ytitle='G - B',charsize=2
;
array=[transpose(lightness),transpose(r_g),transpose(r_b),transpose(g_b)]
;array=standardize(array)
array(0,*)=(array(0,*)-mean(array(0,*)))/stddev(array(0,*))
; compute the weights
for vari=10,3,-1 do begin
Weights = Clust_Wts(array,n_clusters=vari)
;
;       Compute the classification of each sample.
result = CLUSTER(array, Weights)
;
;       Print each sample (each row) of the array and its corresponding
;       cluster assignment.
;for k = 0, N_ELEMENTS(result)-1 do PRINT, result(k),name(k),  FORMAT = '(i3,1x,a)'
openw,11,'results.cluster'
for k = 0, N_ELEMENTS(result)-1 do PRINTf,11, result(k),name(k),  FORMAT = '(i3,1x,a)'
close,11
;
result_sorted=result(sort(result))
clusters=result_sorted(uniq(result_sorted))
n_cl=n_elements(clusters)
print,'There are ',n_cl,' clusters.'
for i=0,n_cl-1,1 do begin
idx=where(result eq clusters(i))
openw,12,strcompress(string(fix(clusters(i)))+'.members',/remove_all)
print,'In cluster ',clusters(i),' there are ',n_elements(idx),' members.'
for k=0,n_elements(idx)-1,1 do begin
printf,12,name(idx(k))
endfor
close,12
endfor
endfor
end
