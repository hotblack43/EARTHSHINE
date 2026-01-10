PRO get_lsmask_gridded,file,lsmask,lon,lat
common displays,if_display
print,'Infile : ',file
existflag=314
if (file_test(file) ne 1) then stop
if (file_test(file)) then begin
	print,'File exists'
;----------- start of funny code to set up lsmask-------------------
;ncdf_cat,file
id = NCDF_OPEN(file)
NCDF_VARGET, id, 'lon',    lon
NCDF_VARGET, id, 'lat',    lat
NCDF_VARGET, id, 'mask',    lsmask
NCDF_CLOSE,  id
;;
;; NOTE the following code is very hard-wired for the choice of grid !!! 
;; compare the below to code in e.g. example5.pro where dlon etc are set
;; ask Peter Thejll (pth@dmi.dk) about this.
; clip the mask so that it matches the -60/-60:60/60 choice elsewhere
lsmask=shift(lsmask,60,1)
lsmask=reverse(lsmask,2)
lsmask=lsmask(0:120-1,30:150)
lsmask=abs(1-lsmask)	; land is now =1, sea=0 
lon=findgen(120)-60
lat=findgen(121)-60
l=lon
for k=0,119,1 do l=[[l],[lon]]
lon=l
l=lat
for k=0,118,1 do l=[[l],[lat]]
lat=transpose(l)
;----------- end of funny code to set up lsmask-------------------
existflag=1
endif
return
end
