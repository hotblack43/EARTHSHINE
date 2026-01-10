set_plot,'ps'
device,filename='/cmsaf/cmsaf-cld3/pthejll/CMSAF_OUTPUTS/dataproperties_cross_correlations.ps',/landscape
openw,5,'test.txt'
.r get_lsmask_gridded
.r CM_SAF_include
.r get_one_file
.r test_data_properties
close,5
device,/close
exit
