set_plot,'ps'
device,filename='/cmsaf/cmsaf-cld3/pthejll/CMSAF_OUTPUTS/SAL_VS_TRSoverTIS_LANDonly_d_factor_correctionON_SAL.ps',/landscape,/color,decomposed=0
openw,5,'test7.txt'
.r go_interpolate.pro
.r get_landsurface_type.pro
.r get_cossza_file.pro
.r get_lsmask_gridded
.r CM_SAF_include
.r get_one_file
.r example7
close,5
device,/close
exit
