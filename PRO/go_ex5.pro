set_plot,'ps'
;device,filename='/cmsaf/cmsaf-cld3/pthejll/CMSAF_OUTPUTS/SALplusCFC_fractioned_vs_TRSoverTIS_LANDonly.ps',/landscape
device,filename='/cmsaf/cmsaf-cld3/pthejll/CMSAF_OUTPUTS/SALplusCFC_VS_TRSoverTIS_LANDonly.ps',/landscape,/color,decomposed=0
openw,5,'test.txt'
.r get_lsmask_gridded
.r CM_SAF_include
.r get_one_file
.r example5
close,5
device,/close
exit
