PRO mingoochoi,im,BLURratio
 l=size(im,/dimensions)
 ncol=l(0)
 nrow=l(1)
 ; First horizontally
 Dh=abs(shift(im,0,1)-shift(im,0,-1))
 Dh_mean=mean(Dh)
 Ch=im*0.0
 idx=where(DH gt DH_mean)
 if (idx(0) ne -1) then Ch(idx)=Dh(idx)
 Eh=im*0.0
 idx=where(Ch gt shift(Ch,0,1) and Ch gt shift(Ch,0,-1)) 
 if (idx(0) ne -1) then Eh(idx)=1
 Ah=avg([[[shift(im,0,1)]],[[shift(im,0,-1)]]],2)
 BRh=abs(im-Ah)/Ah
 ;the vertically 
 Dv=abs(shift(im,1,0)-shift(im,-1,0))
 Dv_mean=mean(Dv)
 Cv=im*0.0
 idx=where(Dv gt Dv_mean)
 if (idx(0) ne -1) then Cv(idx)=Dv(idx)
 Ev=im*0.0
 idx=where(Cv gt shift(Cv,1,0) and Cv gt shift(Cv,-1,0)) 
 if (idx(0) ne -1) then Ev(idx)=1
 Av=avg([[[shift(im,1,0)]],[[shift(im,-1,0)]]],2)
 BRv=abs(im-Av)/Av
 ;
 B=im*0
 idx=where((BRv > BRh) gt (im*0.0+0.1))
 if (idx(0) ne -1) then B(idx)=1
 
 BLURcnt=n_elements(where(b eq 1))
 EDGEcnt=n_elements(where((eh and ev) eq 1))
 BLURratio=float(BLURcnt)/float(EDGEcnt)
 
 return
 end
