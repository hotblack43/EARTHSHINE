set_plot,'ps'
device,filename='/cmsaf/cmsaf-cld3/pthejll/CMSAF_OUTPUTS/TRSoverTIS_vs_combined_SALcorr_CFC_Model1or2_LANDonly.ps',/landscape,/color,decomposed=0
openw,5,'test7.txt'
;.r go_interpolate.pro
;.r get_landsurface_type.pro
;.r get_cossza_file.pro
;.r get_lsmask_gridded
.r CM_SAF_include
;.r get_one_file
.r example8
close,5
device,/close
exit
