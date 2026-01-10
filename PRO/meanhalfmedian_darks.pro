 PRO go_mean_half_median,im,dark
 l=size(im,/dimensions)
 dark=fltarr(l(0),l(1))
 for i=0,l(0)-1,1 do begin
     for j=0,l(1)-1,1 do begin
         line=im(i,j,*)
         line=line(sort(line))
         low=l(2)*0.25
         high=l(2)*0.75
         middlehalf=line(low:high)
         dark(i,j)=mean(middlehalf)
         endfor
     endfor
 return
 end
 
 
 
 
 
 
 path='/data/pth/DATA/ANDOR/MOONDROPBOX/JD2455643/'
 openr,1,'list'
 while not eof(1) do begin
infile=''
 readf,1,infile
 file=path+infile
 im=readfits(file)
 outfile=strcompress('meanhalfmedian_'+infile,/remove_all)
 l=size(im,/dimensions)
 go_mean_half_median,im,dark
     writefits,strcompress(path+outfile,/remove_all),dark
 print,'mean, S.D. and S.D_m: ',mean(dark),stddev(dark),stddev(dark)/sqrt(n_elements(dark))
 endwhile
 close,1
 end
