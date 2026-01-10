spawn,"cut -c10-230 grimaldi.data > tablein"
titnam=['i','j','lon_i','lat_j','iout','jout','antilon','antilat','Terr. Phase','2/3/fL','p!dbs!n','p!dds!n','pbs/pds','fbs/fds','DS','BS','DS/BS']
data=get_data('tablein')
i=reform(data(0,*))
j=reform(data(1,*))
lon_i=reform(data(2,*))
lat_j=reform(data(3,*))
iout=reform(data(4,*))
jout=reform(data(5,*))
lon_iout=reform(data(6,*))
lat_jout=reform(data(7,*))
ph=reform(data(8,*))/!dtor
fl=reform(data(9,*))
pbs=reform(data(10,*))
pds=reform(data(11,*))
pboverpa=reform(data(12,*))
fboverfa=reform(data(13,*))
ds=reform(data(14,*))
BS=reform(data(15,*))
dsbs=reform(data(16,*))
!P.MULTI=[0,4,4]
!P.charsize=1.9
for imnum=0,16,1 do begin
if (imnum ne 8) then plot,data(8,*),data(imnum,*),psym=1,xstyle=3,ystyle=3,$
xtitle=titnam(8),ytitle=titnam(imnum)
endfor
end
