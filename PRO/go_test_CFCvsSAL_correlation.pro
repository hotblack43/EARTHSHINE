set_plot,'ps'
device,filename='/cmsaf/cmsaf-cld3/pthejll/CMSAF_OUTPUTS/CFCvsSAL_correlation.ps',/landscape,/color,decomposed=0
openw,5,'test.txt'
.r get_lsmask_gridded
.r CM_SAF_include
.r get_one_file
.r test_CFCvsSAL_correlation.pro
close,5
device,/close
exit
