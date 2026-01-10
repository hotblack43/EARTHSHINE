set_plot,'ps'
device,filename='/cmsaf/cmsaf-cld3/pthejll/CMSAF_OUTPUTS/residuals_on_maps.ps',/landscape
device,decomposed=0,/color
openw,5,'test.txt'
.r get_lsmask_gridded
.r CM_SAF_include
.r get_one_file
.r example6
close,5
device,/close
exit
